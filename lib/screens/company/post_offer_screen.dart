import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostOfferScreen extends StatefulWidget {
  const PostOfferScreen({super.key});

  @override
  State<PostOfferScreen> createState() => _PostOfferScreenState();
}

class _PostOfferScreenState extends State<PostOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  File? _offerImage;
  bool isLoading = false;

  Future<void> _pickOfferImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _offerImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate() || _offerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image'),
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final offerRef = FirebaseFirestore.instance
          .collection('companies')
          .doc(userId)
          .collection('offers')
          .doc();

      final filePath = 'offer_images/$userId-${offerRef.id}.jpg';
      print("Uploading to Firebase Storage at: $filePath");

      final storageRef = FirebaseStorage.instance.ref().child(filePath);

      final uploadTask = storageRef.putFile(_offerImage!);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
          'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}',
        );
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final imageUrl = await storageRef.getDownloadURL();
        print('Download URL: $imageUrl');

        await offerRef.set({
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer Posted Successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Upload failed.');
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading offer: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post an Offer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Offer Title'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
                onSaved: (val) => title = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
                onSaved: (val) => description = val!,
              ),
              const SizedBox(height: 20),
              _offerImage == null
                  ? ElevatedButton(
                      onPressed: _pickOfferImage,
                      child: const Text('Select Offer Image'),
                    )
                  : Column(
                      children: [
                        Image.file(_offerImage!),
                        TextButton(
                          onPressed: _pickOfferImage,
                          child: const Text('Change Image'),
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _submitOffer,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Post Offer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
