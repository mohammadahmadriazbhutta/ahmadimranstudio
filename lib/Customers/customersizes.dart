import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editcustomersizes.dart';

class CustomerSizesPage extends StatelessWidget {
  const CustomerSizesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Sizes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('customers').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading customers'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return const Center(child: Text('No customers found'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final customer = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(customer['name'] ?? ''),
                subtitle: Text(customer['phone'] ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCustomerSizesPage(
                        customerId: doc.id,
                        customerName: customer['name'] ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
