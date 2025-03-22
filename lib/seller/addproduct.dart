import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  Uint8List? _webImage;  // For Web (Stores image bytes)
  File? _selectedImage;  // For Mobile (Stores File object)
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Function to Pick Image (Compatible with Web & Mobile)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      if (kIsWeb) {
        // Web: Convert to Uint8List
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = imageBytes;
        });
      } else {
        // Mobile: Store File
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  // Function to Upload Image to Firebase Storage
  Future<String> _uploadImageToFirebase() async {
    if (_webImage == null && _selectedImage == null) return '';

    String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = FirebaseStorage.instance.ref().child('product_images').child(fileName);
    UploadTask uploadTask;

    if (kIsWeb && _webImage != null) {
      uploadTask = ref.putData(_webImage!);
    } else if (!kIsWeb && _selectedImage != null) {
      uploadTask = ref.putFile(_selectedImage!);
    } else {
      return '';
    }

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Function to Add Product to Firestore
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload Image to Firebase Storage
      String imageUrl = await _uploadImageToFirebase();

      // Add Product to Firestore (Collection: 'products')
      await FirebaseFirestore.instance.collection('Products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );

      Navigator.pop(context); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                // Image Picker
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
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(_webImage!, fit: BoxFit.cover),
                          )
                        : _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover),
                              )
                            : const Center(child: Text("Tap to select an image", style: TextStyle(color: Colors.grey))),
                  ),
                ),
                const SizedBox(height: 16),

                // Product Name
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Product Name",
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
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

                // Price
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

                // Add Product Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Add Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
