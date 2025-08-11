import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customers.dart';

class addcustomerpage extends StatefulWidget {
  const addcustomerpage({super.key});

  @override
  State<addcustomerpage> createState() => _addcustomerpageState();
}

class _addcustomerpageState extends State<addcustomerpage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _db = FirebaseFirestore.instance;

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      await _db.collection('customers').add({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully!')),
      );

      // Redirect to CustomersPage after saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomersPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter mobile number'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCustomer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
