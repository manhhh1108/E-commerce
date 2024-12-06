import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_store/vendor/views/screens/vendorProductDetail/vendor_product_detail_screen.dart';

class UnpublishedTab extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _vendorProductStream = FirebaseFirestore
        .instance
        .collection('products')
        .where('vendorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('approved', isEqualTo: false)
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
                'No unpublished products found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: ((context, index) {
              final vendorProductData = snapshot.data!.docs[index];
              return InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return VendorProductDetailScreen(productData: vendorProductData);
                      }));
                },
                child: Slidable(
                  key: ValueKey(vendorProductData.id), // Đảm bảo key là duy nhất
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
                          _publishProduct(vendorProductData.id);
                        },
                        backgroundColor: const Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.check,
                        label: 'Publish',
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        // Ảnh sản phẩm
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: vendorProductData['imageUrl'] != null &&
                                vendorProductData['imageUrl'].isNotEmpty
                                ? Image.network(
                              vendorProductData['imageUrl'][0],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.blue, // Màu nền khi không có ảnh
                                  child: Icon(
                                    Icons.image, // Biểu tượng khi không có ảnh
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                                : Container(
                              color: Colors.blue, // Màu nền khi không có ảnh
                              child: Icon(
                                Icons.image, // Biểu tượng khi không có ảnh
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Thông tin sản phẩm
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendorProductData['productName'] ?? 'No Name',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$ ${vendorProductData['productPrice']?.toStringAsFixed(2) ?? '0.00'}',
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

  // Hàm xóa sản phẩm
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

  // Hàm xuất bản sản phẩm
  void _publishProduct(String productId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'approved': true}).then((_) {
      print('Product published');
    }).catchError((error) {
      print('Failed to publish product: $error');
    });
  }
}
