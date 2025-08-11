import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneNumbersPage extends StatefulWidget {
  const PhoneNumbersPage({super.key});

  @override
  State<PhoneNumbersPage> createState() => _PhoneNumbersPageState();
}

class _PhoneNumbersPageState extends State<PhoneNumbersPage> {
  final TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> allCustomers = [];
  List<QueryDocumentSnapshot> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterCustomers);
    searchController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCustomers = allCustomers.where((doc) {
        final name = (doc['name'] ?? '').toString().toLowerCase();
        final phone = (doc['phone'] ?? '').toString().toLowerCase();
        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Sanitize phone number by removing all chars except digits and leading '+'
    String sanitizedNumber = phoneNumber.trim();
    sanitizedNumber = sanitizedNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri url = Uri(scheme: 'tel', path: sanitizedNumber);

    debugPrint('Trying to launch dialer with URL: $url');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $sanitizedNumber')),
      );
    }
  }

  void _goToCallLog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CallLogPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Numbers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View Call Log',
            onPressed: _goToCallLog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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

            // Customer list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('customers')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading customers'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  allCustomers = snapshot.data!.docs;

                  // Filter customers based on search text
                  if (searchController.text.isEmpty) {
                    filteredCustomers = allCustomers;
                  } else {
                    filteredCustomers = allCustomers.where((doc) {
                      final name = (doc['name'] ?? '').toString().toLowerCase();
                      final phone = (doc['phone'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(
                            searchController.text.toLowerCase(),
                          ) ||
                          phone.contains(searchController.text.toLowerCase());
                    }).toList();
                  }

                  if (filteredCustomers.isEmpty) {
                    return const Center(child: Text('No customers found'));
                  }

                  return ListView.builder(
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final doc = filteredCustomers[index];
                      final name = doc['name'] ?? 'Unknown';
                      final phone = doc['phone'] ?? 'N/A';

                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(name),
                        subtitle: Text(phone),
                        trailing: IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () => _makePhoneCall(phone),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CallLogPage extends StatelessWidget {
  const CallLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Log')),
      body: const Center(
        child: Text(
          'Call Log Screen\n(Implement your call log here)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
