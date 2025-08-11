import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String? selectedCustomerId;
  String? selectedCustomerName;
  String? selectedOrderType;
  DateTime? orderDate;
  DateTime? deliveryDate;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final List<String> orderTypes = [
    'Shalwar Kameez',
    'Coat',
    'Waist Coat',
    'Kurta',
  ];

  List<QueryDocumentSnapshot> filteredCustomers = [];
  List<QueryDocumentSnapshot> allCustomers = [];

  @override
  void initState() {
    super.initState();
    filteredCustomers = [];
    searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterCustomers);
    searchController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // Show only latest customer
        filteredCustomers = allCustomers.isNotEmpty ? [allCustomers.last] : [];
      } else {
        filteredCustomers = allCustomers.where((doc) {
          final name = (doc['name'] ?? '').toString().toLowerCase();
          final phone = (doc['phone'] ?? '').toString().toLowerCase();
          return name.contains(query) || phone.contains(query);
        }).toList();
      }
    });
  }

  Future<void> saveOrder() async {
    if (selectedCustomerId == null ||
        selectedOrderType == null ||
        orderDate == null ||
        deliveryDate == null ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    await FirebaseFirestore.instance.collection('orders').add({
      'customerId': selectedCustomerId,
      'customerName': selectedCustomerName,
      'orderType': selectedOrderType,
      'orderDate': orderDate,
      'deliveryDate': deliveryDate,
      'price': double.tryParse(priceController.text) ?? 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context); // Go back after saving
  }

  Future<void> pickDate(BuildContext context, bool isOrderDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isOrderDate) {
          orderDate = picked;
        } else {
          deliveryDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Customer (Name or Phone)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Customer List filtered
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('customers')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading customers'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  allCustomers = snapshot.data!.docs;

                  // Apply filter on customers list based on search input
                  if (searchController.text.isEmpty) {
                    filteredCustomers = allCustomers.isNotEmpty
                        ? [allCustomers.last]
                        : [];
                  } else {
                    final query = searchController.text.toLowerCase();
                    filteredCustomers = allCustomers.where((doc) {
                      final name = (doc['name'] ?? '').toString().toLowerCase();
                      final phone = (doc['phone'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(query) || phone.contains(query);
                    }).toList();
                  }

                  if (filteredCustomers.isEmpty) {
                    return const Center(child: Text('No customers found'));
                  }

                  return ListView.builder(
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final doc = filteredCustomers[index];
                      final name = doc['name'] ?? '';
                      final phone = doc['phone'] ?? '';
                      final isSelected = doc.id == selectedCustomerId;

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(phone),
                        trailing: isSelected ? const Icon(Icons.check) : null,
                        onTap: () {
                          setState(() {
                            selectedCustomerId = doc.id;
                            selectedCustomerName = name;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Order Type
            DropdownButtonFormField<String>(
              value: selectedOrderType,
              decoration: const InputDecoration(labelText: 'Order Type'),
              items: orderTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedOrderType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Order Date
            ListTile(
              title: Text(
                orderDate == null
                    ? 'Select Order Date'
                    : 'Order Date: ${DateFormat('yyyy-MM-dd').format(orderDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => pickDate(context, true),
            ),
            const SizedBox(height: 8),

            // Delivery Date
            ListTile(
              title: Text(
                deliveryDate == null
                    ? 'Select Delivery Date'
                    : 'Delivery Date: ${DateFormat('yyyy-MM-dd').format(deliveryDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => pickDate(context, false),
            ),
            const SizedBox(height: 16),

            // Price
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: saveOrder,
              child: const Text('Save Order'),
            ),
          ],
        ),
      ),
    );
  }
}
