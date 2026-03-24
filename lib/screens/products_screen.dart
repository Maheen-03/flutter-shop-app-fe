import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_product_screen.dart';

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
    final response =
        await http.get(Uri.parse("http://localhost:3000/categories"));

    if (response.statusCode == 200) {
      setState(() {
        categories = jsonDecode(response.body);
      });
    }
  }

  // ================= FETCH PRODUCTS BY CATEGORY =================
  Future<void> fetchProducts(String categoryId) async {
    final response = await http.get(
      Uri.parse("http://localhost:3000/products-by-category/$categoryId"),
    );

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

  // ================= REFRESH AFTER ADD =================
  void refreshAfterAdd() {
    if (selectedCategoryId != null) {
      fetchProducts(selectedCategoryId!);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.teal,
      ),

      // ✅ ADD BUTTON BACK
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

          // Refresh after coming back
          refreshAfterAdd();
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ================= CATEGORY DROPDOWN =================
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

            // ================= PRODUCTS LIST =================
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
