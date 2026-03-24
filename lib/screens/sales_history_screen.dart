import 'package:flutter/material.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  // Dummy sales data
  List<Map<String, dynamic>> sales = [
    {
      "id": "1",
      "total_amount": 500,
      "payment_method": "Cash",
      "date": "2026-03-15",
    },
    {
      "id": "2",
      "total_amount": 1200,
      "payment_method": "Card",
      "date": "2026-03-14",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales History"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return Card(
              child: ListTile(
                title: Text("Sale ID: ${sale["id"]}"),
                subtitle: Text(
                    "Total: \$${sale["total_amount"]}\nPayment: ${sale["payment_method"]}\nDate: ${sale["date"]}"),
                trailing: IconButton(
                  icon: const Icon(Icons.receipt_long, color: Colors.teal),
                  onPressed: () {
                    // Show invoice or receipt detail later
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Invoice - Sale ${sale["id"]}"),
                        content: Text(
                            "Total Amount: \$${sale["total_amount"]}\nPayment: ${sale["payment_method"]}\nDate: ${sale["date"]}"),
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
