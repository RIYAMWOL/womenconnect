import 'package:flutter/material.dart';
import 'package:womenconnect/user/viewproducts.dart';
import 'view_products.dart'; // Import the Product model

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _submitProduct() {
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        imageUrlController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      final newProduct = Product(
        name: nameController.text,
        price: "\$${priceController.text}",
        imageUrl: imageUrlController.text,
        description: descriptionController.text, // Added description
      );

      Navigator.pop(context, newProduct); // Send the new product back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Product Name")),
            TextField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: imageUrlController, decoration: InputDecoration(labelText: "Image URL")),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")), // Added description field
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white),
              onPressed: _submitProduct,
              child: Text("Add Product"),
            ),
          ],
        ),
      ),
    );
  }
}
