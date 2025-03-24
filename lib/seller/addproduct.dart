import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  Uint8List? _webImage;  // For Web Image
  File? _selectedImage;  // For Mobile Image
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // 🛠️ Pick Image from Gallery (Mobile & Web)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = imageBytes;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImage = null;
        });
      }
    }
  }

  // ✅ Check if Form is Valid
  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        (_webImage != null || _selectedImage != null);
  }

  // 📥 Upload Image to Firebase Storage & Get URL
  Future<String> _uploadImage() async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child("products/$fileName");

    UploadTask uploadTask;
    if (kIsWeb) {
      uploadTask = ref.putData(_webImage!);
    } else {
      uploadTask = ref.putFile(_selectedImage!);
    }

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // 🔥 Upload Product to Firestore
  Future<void> _addProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = await _uploadImage();
      await FirebaseFirestore.instance.collection('Products').add({
        "name": _nameController.text,
        "description": _descriptionController.text,
        "price": _priceController.text,
        "imageUrl": imageUrl,
        "timestamp": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Product Added Successfully!")));

      setState(() {
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _webImage = null;
        _selectedImage = null;
        _isLoading = false;
      });
    } catch (error) {
      print("🔥 Error Adding Product: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⚠️ Failed to Add Product!")));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product"), backgroundColor: Colors.deepOrangeAccent),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🖼 Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _webImage != null
                    ? Image.memory(_webImage!, fit: BoxFit.cover)
                    : _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              ),
            ),
            SizedBox(height: 16),

            // 📌 Product Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Product Name",
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 10),

            // 📝 Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 10),

            // 💰 Price
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Price",
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 20),

            // 🛒 Add Product Button
            ElevatedButton(
              onPressed: (_isFormValid() && !_isLoading) ? _addProduct : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Add Product", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
