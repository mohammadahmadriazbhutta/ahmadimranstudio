import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String searchQuery = '';

  // Toggle payment status in Firestore
  Future<void> togglePaymentStatus(String orderId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'paid': !currentStatus},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update payment status: $e')),
      );
    }
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments'), centerTitle: true),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Customer or Order Type',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading payments'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data!.docs;

                // Filter orders based on searchQuery
                final filteredOrders = orders.where((order) {
                  final data = order.data()! as Map<String, dynamic>;
                  final customerName = (data['customerName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final orderType = (data['orderType'] ?? '')
                      .toString()
                      .toLowerCase();

                  return customerName.contains(searchQuery) ||
                      orderType.contains(searchQuery);
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final data = order.data()! as Map<String, dynamic>;

                    final customerName = data['customerName'] ?? 'Unknown';
                    final orderType = data['orderType'] ?? '-';
                    final orderDate = data['orderDate'] as Timestamp?;
                    final deliveryDate = data['deliveryDate'] as Timestamp?;
                    final price = data['price'] ?? 0.0;
                    final paid = data['paid'] ?? false;

                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                _InfoChip(
                                  label: 'Order Type',
                                  value: orderType,
                                ),
                                _InfoChip(
                                  label: 'Order Date',
                                  value: formatDate(orderDate),
                                ),
                                _InfoChip(
                                  label: 'Delivery Date',
                                  value: formatDate(deliveryDate),
                                ),
                                _InfoChip(
                                  label: 'Price',
                                  value: '\Pkr ${price.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  paid ? 'Paid' : 'Pending',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: paid ? Colors.green : Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(paid ? Icons.undo : Icons.check),
                                  label: Text(
                                    paid ? 'Mark Unpaid' : 'Mark Paid',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: paid
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                  onPressed: () =>
                                      togglePaymentStatus(order.id, paid),
                                ),
                              ],
                            ),
                          ],
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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.grey.shade200,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    );
  }
}
