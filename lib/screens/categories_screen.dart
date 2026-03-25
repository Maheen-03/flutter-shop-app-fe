import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ✅ BASE URL CONFIGURATION
const bool useLocal = false; // true = local, false = Vercel
const String baseUrl = useLocal
    ? "http://127.0.0.1:3000"
    : "https://flutter-shop-app-be.vercel.app";

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController categoryNameController = TextEditingController();

  List categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // ================= FETCH CATEGORIES =================
  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("$baseUrl/categories");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          categories = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        showMessage("Failed to load categories (${response.statusCode})");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showMessage("Error fetching categories: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= ADD CATEGORY =================
  Future<void> addCategory() async {
    if (categoryNameController.text.trim().isEmpty) {
      showMessage("Please enter category name");
      return;
    }

    try {
      final url = Uri.parse("$baseUrl/categories/add-category");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": categoryNameController.text.trim()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        categoryNameController.clear();
        Navigator.pop(context);
        fetchCategories();
        showMessage("Category Added Successfully");
      } else {
        showMessage("Failed to add category (${response.statusCode})");
      }
    } catch (e) {
      showMessage("Error adding category: $e");
    }
  }

  // ================= DIALOG =================
  void showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: categoryNameController,
          decoration: const InputDecoration(
            labelText: "Category Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: addCategory,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ================= HELPER =================
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
        title: const Text("Categories"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text("No categories available"))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(category["name"] ?? ""),
                        trailing: const Icon(
                          Icons.category,
                          color: Colors.teal,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCategoryDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
