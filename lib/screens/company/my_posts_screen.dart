import 'package:flutter/material.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace dummy data with real posts from backend
    final List<Map<String, String>> myPosts = [
      {
        'title': '50% Off on Pasta!',
        'description': 'Delicious Pasta for half price.',
      },
      {'title': 'Buy 1 Get 1 Burger!', 'description': 'Limited time offer!'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      body: ListView.builder(
        itemCount: myPosts.length,
        itemBuilder: (context, index) {
          final post = myPosts[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(post['title'] ?? ''),
              subtitle: Text(post['description'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // TODO: Handle delete post
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted!')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
