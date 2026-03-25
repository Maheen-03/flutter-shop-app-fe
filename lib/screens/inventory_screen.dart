import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List products = [];
  bool isLoading = true;
  final TextEditingController qtyController = TextEditingController();

  // ================= BASE URL =================
  // Toggle `useLocal` for testing on local Node backend
  bool useLocal = false; // true = local, false = deployed (Vercel)
  late final String baseUrl;

  @override
  void initState() {
    super.initState();
    baseUrl = useLocal
        ? "http://10.0.2.2:3000" // Android emulator
        : "https://flutter-shop-app-be.vercel.app";
    fetchProducts();
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse("$baseUrl/products");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        showMessage("Failed to load products (${response.statusCode})");
        setState(() => isLoading = false);
      }
    } catch (e) {
      showMessage("Error fetching products: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= STOCK IN =================
  Future<void> stockIn(int index) async {
    qtyController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Stock In"),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Quantity to Add",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              int qty = int.tryParse(qtyController.text) ?? 0;
              final productId = products[index]["id"];

              try {
                final url = Uri.parse("$baseUrl/stock-in");
                final response = await http.post(
                  url,
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "product_id": productId,
                    "stock_quantity": qty,
                  }),
                );

                if (response.statusCode == 200) {
                  showMessage("Stock updated successfully");
                  fetchProducts();
                } else {
                  showMessage(
                      "Failed to update stock (${response.statusCode})");
                }
              } catch (e) {
                showMessage("Error updating stock: $e");
              }

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ================= STOCK OUT =================
  Future<void> stockOut(int index) async {
    qtyController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Stock Out"),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Quantity to Remove",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              int qty = int.tryParse(qtyController.text) ?? 0;
              final productId = products[index]["id"];

              try {
                final url = Uri.parse(
                    "$baseUrl/stock-in"); // Use /stock-out if added later
                final response = await http.post(
                  url,
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "product_id": productId,
                    "stock_quantity": -qty, // negative for stock out
                  }),
                );

                if (response.statusCode == 200) {
                  showMessage("Stock updated successfully");
                  fetchProducts();
                } else {
                  showMessage(
                      "Failed to update stock (${response.statusCode})");
                }
              } catch (e) {
                showMessage("Error updating stock: $e");
              }

              Navigator.pop(context);
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  // ================= HELPER =================
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory / Stock"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    child: ListTile(
                      title: Text(product["product_name"] ?? "No Name"),
                      subtitle:
                          Text("Stock: ${product["stock_quantity"] ?? 0}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => stockIn(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () => stockOut(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
