import 'package:ahmadimranclothing/Customers/addcustomer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _searchQuery = "";

  // Edit customer dialog
  Future<void> _editCustomer(
    String id,
    String currentName,
    String currentPhone,
  ) async {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Customer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db.collection('customers').doc(id).update({
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Customer list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('customers')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading customers'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.docs;

                // Filter by search query
                final filteredData = data.where((doc) {
                  final customer = doc.data() as Map<String, dynamic>;
                  final name = (customer['name'] ?? '').toLowerCase();
                  final phone = (customer['phone'] ?? '').toLowerCase();
                  return name.contains(_searchQuery) ||
                      phone.contains(_searchQuery);
                }).toList();

                if (filteredData.isEmpty) {
                  return const Center(child: Text('No customers found'));
                }

                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final doc = filteredData[index];
                    final customer = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(customer['name'] ?? ''),
                      subtitle: Text(customer['phone'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editCustomer(
                          doc.id,
                          customer['name'] ?? '',
                          customer['phone'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Add new customer
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => addcustomerpage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
