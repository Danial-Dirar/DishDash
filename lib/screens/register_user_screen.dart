import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user/user_dashboard_screen.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  bool isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      print("Validation failed.");
      return;
    }

    _formKey.currentState!.save();
    print("Form data: name=$name, email=$email, password=$password");

    setState(() => isLoading = true);

    try {
      print("Creating Firebase user...");
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCred.user!.uid;
      print("User created with UID: $uid");

      print("Saving user data to Firestore...");
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      print("Firestore write successful. Navigating...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserDashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.message}")),
      );
    } catch (err) {
      print("Unexpected error: $err");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error: $err")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your name' : null,
                onSaved: (val) => name = val!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter your email';
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                onSaved: (val) => email = val!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val == null || val.length < 6
                    ? 'Minimum 6 characters'
                    : null,
                onSaved: (val) => password = val!.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _registerUser,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
