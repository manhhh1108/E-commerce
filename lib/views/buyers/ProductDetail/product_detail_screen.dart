import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/provider/cart_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic productData;

  const ProductDetailScreen({super.key, this.productData});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String formatedDate(DateTime date) {
    final outPutDateFormat = DateFormat('dd/MM/yyyy');
    return outPutDateFormat.format(date);
  }

  int _imageIndex = 0;
  String? _selectedSize;

  @override
  Widget build(BuildContext context) {
    DateTime shippingDate = DateTime.now().add(Duration(days: 2));
    String formatedShippingDate = formatedDate(shippingDate);

    // Safely access the data using null checks
    final productName = widget.productData?['productName'] ?? 'No Product Name';
    final productPrice = widget.productData?['productPrice'] ?? 0.0;
    final imageUrlList = widget.productData?['imageUrl'] ?? [];
    final description = widget.productData?['description'] ?? 'No Description';
    final sizeList = widget.productData?['sizeList'] ?? [];
    final brandName = widget.productData?['brandName'] ?? 'No Brand Name';
    final quantityInStock = widget.productData?['quantity'] ?? 0;

    final CartProvider _cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          productName,
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: imageUrlList.isNotEmpty
                      ? PhotoView(imageProvider: NetworkImage(imageUrlList[_imageIndex]))
                      : Center(
                    child: Text(
                      'No Images Available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                if (imageUrlList.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrlList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _imageIndex = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.yellow.shade900,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                height: 60,
                                width: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(imageUrlList[index], fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "\$ ${productPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                productName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Text(
                'Brand: $brandName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Text(
                'Available in stock: $quantityInStock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red),
              ),
            ),
            ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Product Description',
                    style: TextStyle(
                      color: Colors.yellow.shade900,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'View More',
                    style: TextStyle(
                      color: Colors.yellow.shade900,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Delivery Time',
                    style: TextStyle(color: Colors.yellow.shade900, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    formatedShippingDate,
                    style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              title: Text(
                'Available Size',
                style: TextStyle(color: Colors.yellow.shade900, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              children: sizeList.isNotEmpty
                  ? [
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sizeList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSize = sizeList[index];
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _selectedSize == sizeList[index] ? Colors.yellow.shade900 : Colors.black,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(sizeList[index], style: TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  ),
                ),
              ]
                  : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No Sizes Available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: InkWell(
        onTap: _selectedSize == null
            ? null // Disable if no size is selected
            : () {
          _cartProvider.addProductToCart(
            widget.productData['productName'],
            widget.productData['productId'],
            widget.productData['imageUrl'],
            1, // Số lượng
            widget.productData['quantity'],
            widget.productData['productPrice'],
            widget.productData['vendorId'],
            _selectedSize!, // Truyền size đã chọn
            Timestamp.now(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added to cart successfully!')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: _selectedSize == null ? Colors.grey : Colors.yellow.shade900,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.cart, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Add To Cart',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
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
