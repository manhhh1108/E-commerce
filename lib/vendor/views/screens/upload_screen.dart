import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/provider/product_provider.dart';
import 'package:multi_store/vendor/views/screens/upload_tab_screens/attributes_screen.dart';
import 'package:multi_store/vendor/views/screens/upload_tab_screens/general_screen.dart';
import 'package:multi_store/vendor/views/screens/upload_tab_screens/images_tab_screen.dart';
import 'package:multi_store/vendor/views/screens/upload_tab_screens/shipping_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UploadScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final ProductProvider _productProvider =
        Provider.of<ProductProvider>(context);
    return DefaultTabController(
      length: 4,
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.yellow.shade900,
            bottom: TabBar(tabs: [
              Tab(
                child: Text(
                  'General',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  'Shipping',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  'Attributes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  'Images',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ]),
          ),
          body: TabBarView(
            children: [
              GeneralScreen(),
              ShippingScreen(),
              AttributesScreen(),
              ImagesTabScreen(),
            ],
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade900, // Đặt màu nền cho nút
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(''),
                      content: Text('Are you sure you want to save this product?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final productId = Uuid().v4();
                    await _firestore.collection('products').doc(productId).set({
                      'productId': productId,
                      'productName': _productProvider.productData['productName'],
                      'productPrice': _productProvider.productData['productPrice'],
                      'category': _productProvider.productData['category'],
                      'quantity': _productProvider.productData['quantity'],
                      'scheduleDate': _productProvider.productData['scheduleDate'],
                      'description': _productProvider.productData['description'],
                      'imageUrl': _productProvider.productData['imageUrlList'],
                      'chargeShipping': _productProvider.productData['chargeShipping'],
                      'shippingCharge': _productProvider.productData['shippingCharge'],
                      'brandName': _productProvider.productData['brandName'],
                      'sizeList': _productProvider.productData['sizeList'],
                      'vendorId': FirebaseAuth.instance.currentUser!.uid,
                      'approved': false,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Product saved successfully!')),
                    );
                  }
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
