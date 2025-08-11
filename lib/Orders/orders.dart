import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class orders extends StatefulWidget {
  const orders({super.key});

  @override
  State<orders> createState() => _ordersState();
}

class _ordersState extends State<orders> {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmed Orders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by customer name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data!.docs.where((doc) {
                  final order = doc.data() as Map<String, dynamic>;
                  final customerName = (order['customerName'] ?? '')
                      .toString()
                      .toLowerCase();
                  return customerName.contains(searchQuery);
                }).toList();

                if (orders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final order = doc.data() as Map<String, dynamic>;

                    final customerName = order['customerName'] ?? 'Unknown';
                    final orderType = order['orderType'] ?? 'Unknown';
                    final price = order['price'] != null
                        ? order['price'].toString()
                        : 'N/A';

                    DateTime? orderDate;
                    DateTime? deliveryDate;
                    try {
                      orderDate = (order['orderDate'] as Timestamp).toDate();
                    } catch (_) {}
                    try {
                      deliveryDate = (order['deliveryDate'] as Timestamp)
                          .toDate();
                    } catch (_) {}

                    bool delivered = order['delivered'] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(customerName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order Type: $orderType'),
                            Text(
                              'Order Date: ${orderDate != null ? dateFormat.format(orderDate) : 'N/A'}',
                            ),
                            Text(
                              'Delivery Date: ${deliveryDate != null ? dateFormat.format(deliveryDate) : 'N/A'}',
                            ),
                            Text('Price: $price'),
                          ],
                        ),
                        trailing: Checkbox(
                          value: delivered,
                          onChanged: (bool? value) async {
                            if (value == null) return;
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(doc.id)
                                .update({'delivered': value});
                          },
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
    );
  }
}
