import 'package:flutter/material.dart';

class EditCompanyInfoScreen extends StatefulWidget {
  const EditCompanyInfoScreen({super.key});

  @override
  State<EditCompanyInfoScreen> createState() => _EditCompanyInfoScreenState();
}

class _EditCompanyInfoScreenState extends State<EditCompanyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Company Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Company Name'),
                onSaved: (val) => name = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (val) => address = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (val) => description = val!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  // TODO: Update Company Info in Database
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
