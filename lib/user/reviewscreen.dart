import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final String accommodationId;

  ReviewScreen({required this.accommodationId});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController reviewController = TextEditingController();
  double rating = 3.0;

  Future<void> _submitReview() async {
    if (reviewController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection("Accommodations").doc(widget.accommodationId).collection("Reviews").add({
      "review": reviewController.text,
      "rating": rating,
      "timestamp": FieldValue.serverTimestamp(),
    });

    reviewController.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Review added successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reviews"), backgroundColor: Colors.pinkAccent),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Accommodations")
                  .doc(widget.accommodationId)
                  .collection("Reviews")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No reviews yet"));
                }

                var reviews = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var data = reviews[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(data["review"]),
                        subtitle: Text("⭐ ${data["rating"].toStringAsFixed(1)}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                    labelText: "Write a review",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<double>(
                      value: rating,
                      items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e.toDouble(), child: Text("⭐ $e"))).toList(),
                      onChanged: (value) {
                        setState(() {
                          rating = value!;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                      child: Text("Submit Review", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
