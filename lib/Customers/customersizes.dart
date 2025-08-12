import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editcustomersizes.dart';

class CustomerSizesPage extends StatefulWidget {
  const CustomerSizesPage({super.key});

  @override
  State<CustomerSizesPage> createState() => _CustomerSizesPageState();
}

class _CustomerSizesPageState extends State<CustomerSizesPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Sizes')),
      body: Column(
        children: [
          // 🔍 Search Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search Customer",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 📋 Customer List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('customers').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading customers'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allCustomers = snapshot.data!.docs;

                // 🔍 Filter by search query
                final filteredCustomers = allCustomers.where((doc) {
                  final customer = doc.data() as Map<String, dynamic>;
                  final name = (customer['name'] ?? '').toLowerCase();
                  final phone = (customer['phone'] ?? '').toLowerCase();
                  return name.contains(searchQuery) ||
                      phone.contains(searchQuery);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(
                    child: Text('No matching customers found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final doc = filteredCustomers[index];
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
                              customerPhone: customer['phone'] ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
