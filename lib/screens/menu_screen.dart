import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'receipt_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _barcodeController = TextEditingController();

  List<Map<String, dynamic>> cartItems = [];
  double total = 0;

  final String baseUrl = "https://flutter-shop-app-be.vercel.app";

  // ================= ADD ITEM =================
  Future<void> addItem(String barcode) async {
    if (barcode.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products/barcode/$barcode"),
      );

      if (response.statusCode == 200) {
        final product = jsonDecode(response.body);

        setState(() {
          int index = cartItems
              .indexWhere((item) => item['product_id'] == product['id']);

          if (index != -1) {
            cartItems[index]['quantity'] += 1;
          } else {
            cartItems.add({
              "product_id": product["id"],
              "name": product["product_name"],
              "price": product["sale_price"],
              "quantity": 1,
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

  // ================= CREATE SALE =================
  Future<void> createSale(String paymentMethod) async {
    if (cartItems.isEmpty) {
      showMessage("Cart is empty");
      return;
    }

    final url = Uri.parse("$baseUrl/create-sale");

    // 🔥 IMPORTANT: CLONE DATA
    final List<Map<String, dynamic>> itemsCopy =
        cartItems.map((item) => Map<String, dynamic>.from(item)).toList();

    final double totalCopy = total;

    Map<String, dynamic> saleData = {
      "items": itemsCopy.map((item) {
        return {
          "product_id": item["product_id"],
          "quantity": item["quantity"],
          "price": item["price"],
        };
      }).toList(),
      "total_amount": totalCopy,
      "payment_method": paymentMethod,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(saleData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        String saleId = resData["sale_id"];

        // ✅ NAVIGATE WITH SAFE DATA
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              saleId: saleId,
              items: itemsCopy,
              total: totalCopy,
              paymentMethod: paymentMethod,
            ),
          ),
        );

        // ✅ CLEAR AFTER NAVIGATION
        clearCart();
      } else {
        showMessage("Failed to create sale");
      }
    } catch (e) {
      showMessage("Error: $e");
    }
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
      appBar: AppBar(
        title: const Text('POS / New Sale'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // BARCODE INPUT
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Scan Barcode',
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

            // CART
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  var item = cartItems[index];

                  return Card(
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text('Rs ${item['price']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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

            // TOTAL
            Text(
              'Total: Rs ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),

            const SizedBox(height: 10),

            // BUTTONS
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                    onPressed: clearCart, child: const Text('Clear Cart')),
                ElevatedButton(
                    onPressed: () => createSale("Cash"),
                    child: const Text('Cash')),
                ElevatedButton(
                    onPressed: () => createSale("Card"),
                    child: const Text('Card')),
                ElevatedButton(
                    onPressed: () => createSale("Online"),
                    child: const Text('Online')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
