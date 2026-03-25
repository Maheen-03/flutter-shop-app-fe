import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  List<Map<String, dynamic>> sales = [];
  bool isLoading = true;

  // ================= BASE URL =================
  bool useLocal = false;
  late final String baseUrl;

  @override
  void initState() {
    super.initState();
    baseUrl = useLocal
        ? "http://10.0.2.2:3000"
        : "https://flutter-shop-app-be.vercel.app";
    fetchSales();
  }

  // ================= FETCH SALES =================
  Future<void> fetchSales() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
          "$baseUrl/sales"); // You can implement GET /sales endpoint in backend
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          sales = data.map((sale) => sale as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        showMessage("Failed to load sales (${response.statusCode})");
        setState(() => isLoading = false);
      }
    } catch (e) {
      showMessage("Error fetching sales: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= SNACKBAR =================
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales History"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sales.isEmpty
              ? const Center(child: Text("No sales yet"))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Card(
                        child: ListTile(
                          title: Text("Sale ID: ${sale["id"]}"),
                          subtitle: Text(
                              "Total: Rs ${sale["total_amount"]}\nPayment: ${sale["payment_method"]}\nDate: ${sale["created_at"] ?? 'N/A'}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.receipt_long,
                                color: Colors.teal),
                            onPressed: () {
                              // Show invoice / receipt detail
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("Invoice - Sale ${sale["id"]}"),
                                  content: Text(
                                      "Total Amount: Rs ${sale["total_amount"]}\nPayment: ${sale["payment_method"]}\nDate: ${sale["created_at"] ?? 'N/A'}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
