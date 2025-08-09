import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'company/company_dashboard_screen.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  State<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String about = '';
  double? latitude;
  double? longitude;
  bool isLoading = false;

  Future<void> _registerCompany() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid latitude and longitude."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCred.user!.uid;

      await FirebaseFirestore.instance.collection('companies').doc(uid).set({
        'name': name,
        'email': email,
        'about': about,
        'lat': latitude,
        'lon': longitude,
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompanyDashboardScreen(companyName: name),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.message}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Company')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter company name' : null,
                onSaved: (val) => name = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter email';
                  if (!val.contains('@') || !val.contains('.'))
                    return 'Enter valid email';
                  return null;
                },
                onSaved: (val) => email = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val == null || val.length < 6
                    ? 'Minimum 6 characters'
                    : null,
                onSaved: (val) => password = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'About'),
                onSaved: (val) => about = val ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                onSaved: (val) => latitude = double.tryParse(val ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                onSaved: (val) => longitude = double.tryParse(val ?? ''),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _registerCompany,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register Company'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
