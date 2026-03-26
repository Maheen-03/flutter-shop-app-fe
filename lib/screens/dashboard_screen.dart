import 'package:flutter/material.dart';
import 'add_product_screen.dart'; // POS screen
import 'products_screen.dart';
import 'categories_screen.dart';
import 'inventory_screen.dart';
import 'sales_history_screen.dart';
import 'menu_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget dashboardButton(
      BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop POS Dashboard"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Center(
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          padding: const EdgeInsets.all(40),
          children: [
            dashboardButton(
              context,
              "POS",
              Icons.point_of_sale,
              const PosScreen(),
            ),
            dashboardButton(
              context,
              "Products",
              Icons.inventory,
              const ProductsScreen(),
            ),
            dashboardButton(
              context,
              "Categories",
              Icons.category,
              const CategoriesScreen(),
            ),
            dashboardButton(
              context,
              "Inventory",
              Icons.warehouse,
              const InventoryScreen(),
            ),
            dashboardButton(
              context,
              "Sales",
              Icons.receipt_long,
              const SalesHistoryScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
