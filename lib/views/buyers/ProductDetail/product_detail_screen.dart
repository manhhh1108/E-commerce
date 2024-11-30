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

    final CartProvider _cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          productName,
          style: TextStyle(color: Colors.black, fontSize: 20),
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
                      ? PhotoView(
                    imageProvider: NetworkImage(imageUrlList[_imageIndex]),
                  )
                      : Center(
                    child: Text(
                      'No Images Available',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                if (imageUrlList.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 50,
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
                                ),
                                height: 60,
                                width: 60,
                                child: Image.network(imageUrlList[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Text(
                "\$ ${productPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow.shade900,
                ),
              ),
            ),
            Text(
              productName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Product Description',
                    style: TextStyle(
                      color: Colors.yellow.shade900,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'View More',
                    style: TextStyle(
                      color: Colors.yellow.shade900,
                      fontSize: 18,
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
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
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
                    'This Product Will Be Shipping On',
                    style: TextStyle(
                      color: Colors.yellow.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    formatedShippingDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              title: Text('Available Size'),
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
                            print(_selectedSize);
                          },
                          child: Text(sizeList[index]),
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
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: InkWell(
        onTap: _selectedSize == null
            ? null  // Disable if no size is selected
            : () {
          _cartProvider.addProductToCart(
            widget.productData['productName'],
            widget.productData['productId'],
            widget.productData['imageUrl'],
            1, // Quantity
            widget.productData['productPrice'],
            widget.productData['vendorId'],
            _selectedSize!,  // Safely use because we now check null
            Timestamp.now(),
          );
        },
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: _selectedSize == null ? Colors.grey : Colors.yellow.shade900, // Disable button
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.cart,
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Add To Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}