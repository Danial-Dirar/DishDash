import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user/user_dashboard_screen.dart';
import 'company/company_dashboard_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  String email = '';
  String password = '';
  bool isLoading = false;

  void _signInUser() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
        );
        return;
      }

      DocumentSnapshot companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(uid)
          .get();

      if (companyDoc.exists) {
        final companyData = companyDoc.data() as Map<String, dynamic>;
        String companyName = companyData['name'] ?? 'Company';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyDashboardScreen(companyName: companyName),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No associated user role found.")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: ${e.message}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your email' : null,
                onSaved: (val) => email = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your password' : null,
                onSaved: (val) => password = val!,
              ),
              CheckboxListTile(
                value: rememberMe,
                onChanged: (val) {
                  setState(() {
                    rememberMe = val ?? false;
                  });
                },
                title: const Text('Remember me'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : _signInUser,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
