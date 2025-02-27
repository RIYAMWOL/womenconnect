import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  final String productId;

  OrderScreen({required this.productId});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int quantity = 1;
  bool _isLoading = true;
  bool _isPlacingOrder = false;
  double price = 0.0;
  String productName = "";
  String imageUrl = "";
  String paymentMethod = "Cash on Delivery";
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Products").doc(widget.productId).get();
      
      if (doc.exists) {
        setState(() {
          productName = doc["name"];
          imageUrl = doc["imageUrl"];
          price = double.parse(doc["price"].toString());
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product not found")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading product: $e")));
      Navigator.pop(context);
    }
  }

  double get totalPrice => price * quantity;

  void _increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      await FirebaseFirestore.instance.collection("Orders").add({
        "productId": widget.productId,
        "productName": productName,
        "imageUrl": imageUrl,
        "price": price,
        "quantity": quantity,
        "totalPrice": totalPrice,
        "phoneNumber": phoneController.text,
        "address": addressController.text,
        "paymentMethod": paymentMethod,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed successfully!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order $productName"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 15),

                    // Product Details
                    Text(productName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("\$${price.toStringAsFixed(2)} per item", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                    SizedBox(height: 15),

                    // Quantity Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _decreaseQuantity,
                          icon: Icon(Icons.remove, color: Colors.pinkAccent),
                        ),
                        Text(
                          quantity.toString(),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _increaseQuantity,
                          icon: Icon(Icons.add, color: Colors.pinkAccent),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),

                    // Total Price
                    Text("Total Price: \$${totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),

                    // Phone Number Field
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: Icon(Icons.phone, color: Colors.pinkAccent),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter your phone number";
                        if (value.length < 10) return "Enter a valid phone number";
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Address Field
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: "Delivery Address",
                        prefixIcon: Icon(Icons.location_on, color: Colors.pinkAccent),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter your address";
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Payment Method Dropdown
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: InputDecoration(
                        labelText: "Payment Method",
                        prefixIcon: Icon(Icons.payment, color: Colors.pinkAccent),
                        border: OutlineInputBorder(),
                      ),
                      items: ["Cash on Delivery", "UPI", "Credit/Debit Card"]
                          .map((method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                    ),
                    SizedBox(height: 25),

                    // Place Order Button
                    _isPlacingOrder
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _placeOrder,
                            icon: Icon(Icons.shopping_cart),
                            label: Text("Place Order"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
