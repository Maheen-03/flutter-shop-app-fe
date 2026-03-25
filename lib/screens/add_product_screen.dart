import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ✅ BASE URL CONFIGURATION
const bool useLocal = false; // true = local, false = Vercel
const String baseUrl = useLocal
    ? "http://127.0.0.1:3000"
    : "https://flutter-shop-app-be.vercel.app";

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController stockQuantityController = TextEditingController();
  final TextEditingController supplierIdController = TextEditingController();

  // Categories
  List categories = [];
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // ================= FETCH CATEGORIES =================
  Future<void> fetchCategories() async {
    try {
      final url = Uri.parse("$baseUrl/categories");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = data;
        });
      } else {
        showMessage("Failed to load categories (${response.statusCode})");
      }
    } catch (e) {
      showMessage("Error: $e");
    }
  }

  // ================= SAVE PRODUCT =================
  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategoryId == null) {
      showMessage("Please select a category");
      return;
    }

    final url = Uri.parse("$baseUrl/add-product");

    Map<String, dynamic> productData = {
      "product_name": productNameController.text.trim(),
      "barcode": barcodeController.text.trim(),
      "category_id": selectedCategoryId,
      "cost_price": double.tryParse(costPriceController.text) ?? 0,
      "sale_price": double.tryParse(salePriceController.text) ?? 0,
      "stock_quantity": int.tryParse(stockQuantityController.text) ?? 0,
      "supplier_id": supplierIdController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showMessage("Product Saved Successfully");
        Navigator.pop(context);
      } else {
        showMessage("Failed to save product (${response.statusCode})");
      }
    } catch (e) {
      showMessage("Error: $e");
    }
  }

  // ================= HELPER =================
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: productNameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: barcodeController,
                decoration: const InputDecoration(
                  labelText: "Barcode",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                hint: const Text("Select Category"),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: categories.isEmpty
                    ? []
                    : categories.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem<String>(
                          value: cat["id"].toString(),
                          child: Text(cat["name"] ?? "No Name"),
                        );
                      }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: costPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Cost Price",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: salePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Sale Price",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: stockQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Stock Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: supplierIdController,
                decoration: const InputDecoration(
                  labelText: "Supplier ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text(
                    "Save Product",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
