import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  final String? menuUrl;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const MenuWidget({
    super.key,
    required this.menuUrl,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Menu",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (menuUrl != null)
          Column(
            children: [
              Image.network(menuUrl!, height: 200),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete),
                label: const Text("Remove Menu"),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload),
            label: const Text("Upload Menu"),
          ),
      ],
    );
  }
}
