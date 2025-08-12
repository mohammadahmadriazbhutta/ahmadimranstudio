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
        'color': Colors.deepPurple,
        'page': CustomersPage(),
      },
      {
        'title': 'Customer Sizes',
        'icon': Icons.straighten,
        'color': Colors.teal,
        'page': CustomerSizesPage(),
      },
      {
        'title': 'Payments',
        'icon': Icons.payment,
        'color': Colors.orange,
        'page': PaymentsPage(),
      },
      {
        'title': 'Phone Numbers',
        'icon': Icons.phone,
        'color': Colors.green,
        'page': PhoneNumbersPage(),
      },
      {
        'title': 'Add Order',
        'icon': Icons.shopping_cart,
        'color': Colors.indigo,
        'page': OrdersPage(),
      },
      {
        'title': 'Orders',
        'icon': Icons.add_shopping_cart,
        'color': Colors.redAccent,
        'page': orders(),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Heading with subtle shadow and custom font style
              Text(
                'Ahmad Imran Studio',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  shadows: [
                    Shadow(
                      color: const Color.fromARGB(
                        255,
                        0,
                        0,
                        0,
                      ).withOpacity(0.6),
                      offset: const Offset(2, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Logo with rounded corners & subtle shadow
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade100.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/logo.jpg',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Inspirational Quote with gradient text
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.deepPurple, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Fashion is an art',
                  style: const TextStyle(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // disable inner scrolling
                  shrinkWrap: true, // let it size itself
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width < 600
                        ? 2
                        : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];

                    Color iconColor;
                    Color textColor;

                    if (item['color'] is MaterialColor) {
                      iconColor = (item['color'] as MaterialColor).shade700;
                      textColor = (item['color'] as MaterialColor).shade900;
                    } else if (item['color'] is MaterialAccentColor) {
                      iconColor =
                          (item['color'] as MaterialAccentColor).shade700;
                      textColor =
                          (item['color'] as MaterialAccentColor).shade700;
                    } else {
                      iconColor = item['color'];
                      textColor = item['color'];
                    }

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
                          gradient: LinearGradient(
                            colors: [
                              item['color'].withOpacity(0.2),
                              item['color'].withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: item['color'].withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(4, 6),
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(-4, -6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item['color'].withOpacity(0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: item['color'].withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Icon(
                                item['icon'],
                                color: iconColor,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                shadows: [
                                  Shadow(
                                    color: textColor.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
