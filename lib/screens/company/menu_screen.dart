import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  File? _menuImage;

  Future<void> _pickMenuImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _menuImage = File(pickedFile.path);
      });
      // TODO: Upload this image to the backend
    }
  }

  void _removeMenuImage() {
    setState(() {
      _menuImage = null;
    });
    // TODO: Remove image from backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MENU')),
      body: Center(
        child: _menuImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No Menu Uploaded'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickMenuImage,
                    child: const Text('Upload Your Menu'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(_menuImage!),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _removeMenuImage,
                    child: const Text('Remove Menu'),
                  ),
                ],
              ),
      ),
    );
  }
}
