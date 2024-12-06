import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_store/vendor/views/screens/vendorProductDetail/vendor_product_detail_screen.dart';

import '../../auth/login.dart';

class PublishedTab extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginVendorScreen()), // Điều hướng đến LoginVendorScreen
            );
          },
          child: Text('Login to Continue', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    final Stream<QuerySnapshot> _vendorProductStream = FirebaseFirestore
        .instance
        .collection('products')
        .where('vendorId', isEqualTo: user.uid)
        .where('approved', isEqualTo: true)
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _vendorProductStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No published products found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: ((context, index) {
              final vendorProductData = snapshot.data!.docs[index];
              final imageUrl =
                  vendorProductData['imageUrl'] as List<dynamic>? ?? [];
              final productName = vendorProductData['productName'] ?? 'No Name';
              final productPrice = (vendorProductData['productPrice'] as num?)
                      ?.toStringAsFixed(2) ??
                  '0.00';

              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return VendorProductDetailScreen(
                        productData: vendorProductData);
                  }));
                },
                child: Slidable(
                  key: ValueKey(vendorProductData.id),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _deleteProduct(vendorProductData.id);
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          _unpublishProduct(vendorProductData.id);
                        },
                        backgroundColor: const Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.undo,
                        label: 'Unpublish',
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        // Product image
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl[0],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _placeholderImage();
                                    },
                                  )
                                : _placeholderImage(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Product info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$ $productPrice',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.blue,
      child: Icon(
        Icons.image,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  // Delete product function
  void _deleteProduct(String productId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete()
        .then((_) {
      print('Product deleted');
    }).catchError((error) {
      print('Failed to delete product: $error');
    });
  }

  // Unpublish product function
  void _unpublishProduct(String productId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'approved': false}).then((_) {
      print('Product unpublished');
    }).catchError((error) {
      print('Failed to unpublish product: $error');
    });
  }
}
