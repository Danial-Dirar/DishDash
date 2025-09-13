import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  Future<void> _pickOfferImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _offerImage = File(pickedFile.path);
      });
    }
  }

  void _submitOffer() {
    if (_formKey.currentState!.validate() && _offerImage != null) {
      _formKey.currentState!.save();
      // TODO: Upload Offer (title, description, image) to backend

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer Posted Successfully!')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image'),
        ),
      );
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an offer title';
                  }
                  return null;
                },
                onSaved: (val) => title = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
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
                onPressed: _submitOffer,
                child: const Text('Post Offer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
