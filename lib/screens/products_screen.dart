import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_product_screen.dart';
import 'barcode_screen.dart';
import 'barcode_pdf_generator.dart';

const String baseUrl = "https://flutter-shop-app-be.vercel.app";

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List categories = [];
  List products = [];

  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // ================= FETCH CATEGORIES =================
  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/categories"));

    if (response.statusCode == 200) {
      setState(() {
        categories = jsonDecode(response.body);
      });
    }
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts(String categoryId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/products-by-category/$categoryId"));

    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    } else {
      setState(() {
        products = [];
      });
    }
  }

  // ================= REFRESH =================
  void refreshAfterAdd() {
    if (selectedCategoryId != null) {
      fetchProducts(selectedCategoryId!);
    }
  }

  // ================= PRINT ALL BARCODES =================
  void printAllBarcodes() async {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No products to print")),
      );
      return;
    }

    await generateBarcodePdf(products);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.teal,

        // 🔥 PRINT ICON (NOW YOU WILL SEE IT)
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: printAllBarcodes,
          ),
        ],
      ),

      // ADD PRODUCT BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );
          refreshAfterAdd();
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // CATEGORY DROPDOWN
            DropdownButtonFormField<String>(
              hint: const Text("Select Category"),
              value: selectedCategoryId,
              items: categories.map<DropdownMenuItem<String>>((cat) {
                return DropdownMenuItem<String>(
                  value: cat["id"].toString(),
                  child: Text(cat["name"] ?? ""),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });

                if (value != null) {
                  fetchProducts(value);
                }
              },
            ),

            const SizedBox(height: 15),

            // PRODUCTS LIST
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text("No Products Found"))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return Card(
                          child: ListTile(
                            title: Text(product["product_name"] ?? ""),
                            subtitle: Text(
                              "Price: ${product["sale_price"]} | Stock: ${product["stock_quantity"]}",
                            ),

                            // 🔥 ACTION BUTTONS
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 👁 VIEW BARCODE
                                IconButton(
                                  icon: const Icon(Icons.qr_code),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BarcodeScreen(
                                          productName: product["product_name"],
                                          barcode: product["barcode"],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // 🖨 PRINT SINGLE BARCODE
                                IconButton(
                                  icon: const Icon(Icons.print),
                                  onPressed: () async {
                                    await generateBarcodePdf([product]);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
