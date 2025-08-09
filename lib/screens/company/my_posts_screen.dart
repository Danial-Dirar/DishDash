import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  late final String companyId;
  late final CollectionReference offersRef;
  bool isLoading = true;
  List<DocumentSnapshot> offers = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      companyId = user.uid;
      offersRef = FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('offers');
      _loadOffers();
    }
  }

  Future<void> _loadOffers() async {
    final snapshot = await offersRef
        .orderBy('createdAt', descending: true)
        .get();
    setState(() {
      offers = snapshot.docs;
      isLoading = false;
    });
  }

  Future<void> _deleteOffer(String offerId) async {
    await offersRef.doc(offerId).delete();
    setState(() {
      offers.removeWhere((doc) => doc.id == offerId);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Offer deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : offers.isEmpty
          ? const Center(child: Text('No offers posted yet.'))
          : ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final data = offers[index].data() as Map<String, dynamic>;
                final offerId = offers[index].id;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(data['title'] ?? 'No title'),
                    subtitle: Text(data['description'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteOffer(offerId),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
