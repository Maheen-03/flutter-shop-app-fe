import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _barcodeController = TextEditingController();

  List<Map<String, dynamic>> cartItems = [];
  double total = 0;

  // ================= ADD ITEM FROM BACKEND =================
  Future<void> addItem(String barcode) async {
    if (barcode.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse("http://localhost:3000/products/barcode/$barcode"),
      );

      if (response.statusCode == 200) {
        final product = jsonDecode(response.body);

        setState(() {
          int index =
              cartItems.indexWhere((item) => item['id'] == product['id']);

          if (index != -1) {
            cartItems[index]['quantity'] += 1;
          } else {
            cartItems.add({
              'id': product['id'],
              'name': product['product_name'],
              'price': product['sale_price'],
              'quantity': 1,
            });
          }

          calculateTotal();
        });

        _barcodeController.clear();
      } else {
        showMessage("Product not found");
      }
    } catch (e) {
      showMessage("Error: $e");
    }
  }

  // ================= TOTAL =================
  void calculateTotal() {
    total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
  }

  // ================= REMOVE =================
  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
      calculateTotal();
    });
  }

  // ================= QUANTITY =================
  void changeQuantity(int index, int qty) {
    if (qty <= 0) return;

    setState(() {
      cartItems[index]['quantity'] = qty;
      calculateTotal();
    });
  }

  // ================= CLEAR =================
  void clearCart() {
    setState(() {
      cartItems.clear();
      total = 0;
    });
  }

  // ================= RECEIPT =================
  void printReceipt() {
    print("------ RECEIPT ------");
    for (var item in cartItems) {
      print(
          "${item['name']} x${item['quantity']} = ${item['price'] * item['quantity']}");
    }
    print("Total: $total");
  }

  // ================= SNACKBAR =================
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS / New Sale')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Barcode input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Scan or Enter Barcode',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: addItem,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => addItem(_barcodeController.text),
                  child: const Text('Add'),
                )
              ],
            ),

            const SizedBox(height: 20),

            // Cart list
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(child: Text("No items in cart"))
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index];
                        return Card(
                          child: ListTile(
                            title: Text(item['name']),
                            subtitle: Text('Price: ${item['price']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => removeItem(index),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: TextFormField(
                                    initialValue: item['quantity'].toString(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      int qty = int.tryParse(val) ?? 1;
                                      changeQuantity(index, qty);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Total
            Text(
              'Total: Rs ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),

            const SizedBox(height: 10),

            // Buttons
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                    onPressed: clearCart, child: const Text('Clear Cart')),
                ElevatedButton(
                    onPressed: printReceipt,
                    child: const Text('Print Receipt')),
                ElevatedButton(
                    onPressed: () {
                      showMessage("Cash Payment (next step)");
                    },
                    child: const Text('Cash')),
                ElevatedButton(
                    onPressed: () {
                      showMessage("Card Payment (next step)");
                    },
                    child: const Text('Card')),
                ElevatedButton(
                    onPressed: () {
                      showMessage("Online Payment (next step)");
                    },
                    child: const Text('Online')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
