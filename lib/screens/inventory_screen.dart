import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Temporary product stock list
  List<Map<String, dynamic>> products = [
    {
      "id": "1",
      "name": "Balloon Pack",
      "stock_quantity": 50,
    },
    {
      "id": "2",
      "name": "LED Fairy Lights",
      "stock_quantity": 20,
    },
    {
      "id": "3",
      "name": "Gift Box",
      "stock_quantity": 100,
    },
  ];

  final TextEditingController qtyController = TextEditingController();

  // Stock In
  void stockIn(int index) {
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
            onPressed: () {
              int qty = int.tryParse(qtyController.text) ?? 0;
              setState(() {
                products[index]["stock_quantity"] += qty;
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // Stock Out
  void stockOut(int index) {
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
            onPressed: () {
              int qty = int.tryParse(qtyController.text) ?? 0;
              setState(() {
                products[index]["stock_quantity"] -= qty;
                if (products[index]["stock_quantity"] < 0) {
                  products[index]["stock_quantity"] = 0;
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory / Stock"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              child: ListTile(
                title: Text(product["name"]),
                subtitle: Text("Stock: ${product["stock_quantity"]}"),
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
