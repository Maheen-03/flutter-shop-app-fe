import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  final String saleId;
  final List items;
  final double total;
  final String paymentMethod;

  const ReceiptScreen({
    super.key,
    required this.saleId,
    required this.items,
    required this.total,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= SHOP INFO =================
            const Text(
              "Eventify Store",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text("Party Decorations & Gifts"),
            const Text("Islamabad, Pakistan"),
            const Divider(thickness: 1),

            // ================= SALE INFO =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sale ID: $saleId"),
                Text(
                  "${DateTime.now().toString().substring(0, 16)}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            const Divider(),

            // ================= ITEMS HEADER =================
            Row(
              children: const [
                Expanded(
                    flex: 4,
                    child: Text("Item",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("Qty",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text("Price",
                        textAlign: TextAlign.end,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),

            const Divider(),

            // ================= ITEMS LIST =================
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Text(item["name"])),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item["quantity"].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Rs ${(item["price"] * item["quantity"]).toStringAsFixed(2)}",
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            // ================= TOTAL =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TOTAL",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rs ${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ================= PAYMENT =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Payment Method:"),
                Text(paymentMethod),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(),

            const Text(
              "Thank you for your purchase!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Visit Again 🎉"),

            const SizedBox(height: 20),

            // ================= BUTTONS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Back"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Future: connect thermal printer
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Printing not connected yet")),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text("Print"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
