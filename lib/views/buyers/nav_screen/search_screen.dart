import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/views/buyers/ProductDetail/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchValue = '';

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream =
    FirebaseFirestore.instance.collection('products').snapshots();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.yellow.shade900,
        elevation: 0,
        title: TextFormField(
          onChanged: (value) {
            setState(() {
              _searchValue = value.trim();
            });
          },
          decoration: InputDecoration(
            hintText: "Search for products...",
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _searchValue.isEmpty
          ? Center(
        child: Text(
          'Start typing to search for products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final searchData = snapshot.data!.docs.where((element) {
            final productName =
                element['productName']?.toString().toLowerCase() ?? '';
            return productName.contains(_searchValue.toLowerCase());
          }).toList();

          if (searchData.isEmpty) {
            return Center(
              child: Text(
                'No products match your search.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: searchData.length,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemBuilder: (context, index) {
              final product = searchData[index];
              final productData = product.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: productData['imageUrl'] != null &&
                          productData['imageUrl'] is List &&
                          productData['imageUrl'].isNotEmpty
                          ? Image.network(
                        productData['imageUrl'][0],
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        'assets/images/default-image_730.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    productData['productName'] ?? 'No Name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        '\$${(productData['productPrice'] ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        productData['category'] ?? 'Uncategorized',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.yellow.shade900),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return ProductDetailScreen(
                              productData: productData,
                            );
                          }));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
