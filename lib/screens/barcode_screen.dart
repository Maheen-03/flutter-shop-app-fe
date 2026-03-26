import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class BarcodeScreen extends StatelessWidget {
  final String productName;
  final String barcode;

  const BarcodeScreen({
    super.key,
    required this.productName,
    required this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 🔥 BARCODE DISPLAY
                BarcodeWidget(
                  barcode: Barcode.code128(), // BEST for POS
                  data: barcode,
                  width: 250,
                  height: 80,
                ),

                const SizedBox(height: 10),

                Text(
                  barcode,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Printing coming soon")),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text("Print Barcode"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
