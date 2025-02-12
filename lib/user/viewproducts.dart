import 'package:flutter/material.dart';
import 'package:womenconnect/user/addproducts.dart';

class Product {
  final String name;
  final String price;
  final String imageUrl;
  final String description;

  Product({required this.name, required this.price, required this.imageUrl, required this.description});
}

class ViewProductsPage extends StatefulWidget {
  @override
  _ViewProductsPageState createState() => _ViewProductsPageState();
}

class _ViewProductsPageState extends State<ViewProductsPage> {
  List<Product> products = [
    Product(
      name: "Handmade Earrings",
      price: "\$15",
      imageUrl: "https://via.placeholder.com/150",
      description: "Beautiful handcrafted earrings made with love.",
    ),
    Product(
      name: "Organic Skincare Set",
      price: "\$30",
      imageUrl: "https://via.placeholder.com/150",
      description: "A set of organic skincare products for glowing skin.",
    ),
    Product(
      name: "Handwoven Tote Bag",
      price: "\$40",
      imageUrl: "https://via.placeholder.com/150",
      description: "Eco-friendly and stylish handwoven tote bag.",
    ),
    Product(
      name: "Women’s Perfume",
      price: "\$50",
      imageUrl: "https://via.placeholder.com/150",
      description: "A long-lasting floral fragrance for women.",
    ),
  ];

  // Function to update product list
  void _addProduct(Product product) {
    setState(() {
      products.add(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shop for Women",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        product.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          product.description,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          product.price,
                          style: TextStyle(fontSize: 14, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.shopping_cart),
                        label: Text("Buy"),
                        onPressed: () {
                          // TODO: Implement buy functionality
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );

          if (newProduct != null && newProduct is Product) {
            _addProduct(newProduct); // Add product to the list
          }
        },
        child: Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
