import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController categoryNameController = TextEditingController();

  List categories = [];
  bool isLoading = true;

  final String baseUrl = "http://localhost:3000";

  // Fetch categories from backend
  Future<void> fetchCategories() async {
    final url = Uri.parse("$baseUrl/categories");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        categories = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print("Failed to load categories");
    }
  }

  // Add category
  Future<void> addCategory() async {
    final url = Uri.parse("$baseUrl/categories/add-category");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": categoryNameController.text}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      categoryNameController.clear();
      Navigator.pop(context);

      fetchCategories();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category Added")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add category")),
      );
    }
  }

  // Dialog for adding category
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
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
