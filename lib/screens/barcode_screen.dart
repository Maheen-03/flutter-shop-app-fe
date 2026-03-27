import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'barcode_pdf_generator.dart';

class BarcodeScreen extends StatelessWidget {
  final String productName;
  final String barcode;

  const BarcodeScreen({
    super.key,
    required this.productName,
    required this.barcode,
  });

  // ================= PRINT FUNCTION =================
  void printBarcode() async {
    await generateBarcodePdf([
      {
        "product_name": productName,
        "barcode": barcode,
      }
    ]);
  }

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
                // PRODUCT NAME
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                //  BARCODE DISPLAY
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: barcode,
                  width: 250,
                  height: 80,
                ),

                const SizedBox(height: 10),

                // BARCODE TEXT
                Text(
                  barcode,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                //  PRINT BUTTON
                ElevatedButton.icon(
                  onPressed: printBarcode,
                  icon: const Icon(Icons.print),
                  label: const Text("Print Barcode"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
