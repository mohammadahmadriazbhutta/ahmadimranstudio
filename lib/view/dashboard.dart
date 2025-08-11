import 'package:ahmadimranclothing/Customers/customers.dart';
import 'package:ahmadimranclothing/Customers/customersizes.dart';
import 'package:ahmadimranclothing/Orders/orders.dart';
import 'package:ahmadimranclothing/Orders/orderspage.dart';
import 'package:ahmadimranclothing/Payment/payments.dart';
import 'package:ahmadimranclothing/Phone/phone.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dashboardItems = [
      {
        'title': 'Customers',
        'icon': Icons.people,
        'color': Colors.black,
        'page': CustomersPage(),
      },
      {
        'title': 'Customer Sizes',
        'icon': Icons.straighten,
        'color': Colors.black,
        'page': CustomerSizesPage(),
      },
      {
        'title': 'Payments',
        'icon': Icons.payment,
        'color': Colors.black,
        'page': PaymentsPage(),
      },
      {
        'title': 'Phone Numbers',
        'icon': Icons.phone,
        'color': Colors.black,
        'page': PhoneNumbersPage(),
      },
      {
        'title': 'Add Order',
        'icon': Icons.shopping_cart,
        'color': Colors.black,
        'page': OrdersPage(),
      },
      {
        'title': 'Orders',
        'icon': Icons.add_shopping_cart,
        'color': Colors.black,
        'page': orders(),
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Heading
              Text(
                'Ahmad Imran Studio',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  'assets/logo.jpg',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Quote
              Text(
                'Fashion is an art',
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return GestureDetector(
                      onTap: () {
                        if (item['page'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => item['page'],
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: item['color'].withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: item['color'], width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: item['color'].withOpacity(0.15),
                              blurRadius: 5,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item['icon'], color: item['color'], size: 40),
                            const SizedBox(height: 10),
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: item['color'],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
