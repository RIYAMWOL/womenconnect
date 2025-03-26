import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:womenconnect/seller/sellerdashboardscreen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Uint8List? _webImage;
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dqaitmb01/image/upload";
  final String cloudinaryPreset = "women_connect_images";

  // 🔹 Pick Image (Web & Mobile Support)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() => _webImage = imageBytes);
      } else {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  // 🔹 Upload Image to Cloudinary
  Future<String> _uploadImageToCloudinary() async {
    if (_webImage == null && _selectedImage == null) return '';

    try {
      var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = cloudinaryPreset;

      if (kIsWeb && _webImage != null) {
        request.files.add(http.MultipartFile.fromBytes('file', _webImage!, filename: 'image.jpg'));
      } else if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        return jsonData['secure_url'];
      } else {
        throw Exception("Image upload failed: ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("Cloudinary Upload Error: $e");
    }
  }

  // 🔹 Add Product to Firestore
  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        (_webImage == null && _selectedImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("Uploading Image to Cloudinary...");
      String imageUrl = await _uploadImageToCloudinary();

      if (imageUrl.isEmpty) {
        throw Exception("Image upload failed.");
      }

      double? price;
      try {
        price = double.parse(_priceController.text);
      } catch (e) {
        throw Exception("Invalid price format.");
      }

      // ✅ Get current seller's ID
      String? sellerId = FirebaseAuth.instance.currentUser?.uid;
      if (sellerId == null) {
        throw Exception("User not authenticated.");
      }

      // ✅ Fetch seller details (name, shop)
      DocumentSnapshot sellerSnapshot =
          await FirebaseFirestore.instance.collection('sellers').doc(sellerId).get();
      String sellerName = sellerSnapshot['name'] ?? "Unknown Seller";
      String shopName = sellerSnapshot['shopName'] ?? "Unknown Shop";

      print("Adding product to Firestore...");
      await FirebaseFirestore.instance.collection('Products').add({
        'sellerId': sellerId, // ✅ Store sellerId
        'sellerName': sellerName,
        'shopName': shopName,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => SellerDashboardScreen()));
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      print("Operation Completed, resetting loading state.");
      setState(() => _isLoading = false);
    }
  }

  // 🔹 UI Build Function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product"), backgroundColor: Colors.deepOrangeAccent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _webImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_webImage!, fit: BoxFit.cover))
                        : _selectedImage != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                            : const Center(child: Text("Tap to select an image", style: TextStyle(color: Colors.grey))),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Product Name",
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Price",
                    prefixIcon: const Icon(Icons.money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Add Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
