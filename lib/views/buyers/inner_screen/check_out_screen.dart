import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_store/provider/cart_provider.dart';
import 'package:multi_store/views/buyers/main_screen.dart';
import 'package:multi_store/views/buyers/payment/home_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    final CartProvider _cartProvider = Provider.of<CartProvider>(context);
    CollectionReference users = FirebaseFirestore.instance.collection('buyers');
    final cartItems = _cartProvider.getCartItem;

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade900),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          return const Center(child: Text("No user data available"));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final address = data['address'] != null ? data['address'] : '';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.yellow.shade900,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              "Checkout",
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          body: cartItems.isEmpty
              ? const Center(child: Text("No items in your cart"))
              : ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartData = cartItems.values.toList()[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.network(
                              (cartData.imageUrl != null &&
                                  cartData.imageUrl.isNotEmpty)
                                  ? cartData.imageUrl[0]
                                  : 'https://via.placeholder.com/150',
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    cartData.productName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '\$${cartData.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow.shade900,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Quantity:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${cartData.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: Text(cartData.productSize),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          bottomSheet: address.isEmpty
              ? TextButton(
            onPressed: () {
              // Chuyển tới EditProfile để nhập địa chỉ
            },
            child: const Text('Enter Address'),
          )
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                final orderId = const Uuid().v4();
                final orderDate = DateTime.now();

                List<Map<String, dynamic>> cartItemsData =
                cartItems.values
                    .map((item) => {
                  'productId': item.productId,
                  'productName': item.productName,
                  'productPrice': item.price,
                  'productImage': item.imageUrl,
                  'quantity': item.quantity,
                  'productSize': item.productSize,
                  'totalPrice': item.price * item.quantity,
                  'vendorId': item.vendorId,
                })
                    .toList();

                final orderData = {
                  'orderId': orderId,
                  'vendorIds': cartItems.values
                      .map((item) => item.vendorId)
                      .toSet()
                      .toList(),
                  'email': data['email'],
                  'phone': data['phoneNumber'],
                  'address': address,
                  'buyerId': data['buyerId'],
                  'fullName': data['fullName'],
                  'buyerPhoto': data['profileImage'],
                  'orderDate': orderDate.toIso8601String(),
                  'totalOrderPrice': _cartProvider.totalPrice,
                  'cartItems': cartItemsData,
                  'accepted': false,
                };

                // Chuyển tới HomePagePayment
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return HomePagePayment(
                        amount: _cartProvider.totalPrice,
                        orderData: orderData,
                      );
                    }));
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.yellow.shade900,
                    borderRadius: BorderRadius.circular(10)),
                child: const Center(
                  child: Text(
                    'Place Order',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
