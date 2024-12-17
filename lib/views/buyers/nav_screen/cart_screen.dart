import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/provider/cart_provider.dart';
import 'package:multi_store/views/buyers/auth/login_screen.dart'; // Import màn hình đăng nhập
import 'package:multi_store/views/buyers/inner_screen/check_out_screen.dart';
import 'package:multi_store/views/buyers/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartProvider _cartProvider = Provider.of<CartProvider>(context);
    final cartItems = _cartProvider.getCartItem;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.yellow.shade900,
        elevation: 0,
        title: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'Cart Screen',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _cartProvider.clearCart();
            },
            icon: Icon(
              CupertinoIcons.delete,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _cartProvider.getCartItem.isNotEmpty
          ? SafeArea(
        child: ListView.builder(
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final cartData = cartItems.values.toList()[index];

            return Card(
              margin:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.network(cartData.imageUrl.isNotEmpty
                          ? cartData.imageUrl[0]
                          : 'https://via.placeholder.com/150'), // Placeholder nếu không có ảnh
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              cartData.productName,
                              style: TextStyle(
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
                            OutlinedButton(
                              onPressed: () {},
                              child: Text(cartData.productSize),
                            ),
                            Container(
                              height: 40,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade900,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: cartData.quantity == 1
                                        ? null
                                        : () {
                                      _cartProvider
                                          .decreament(cartData);
                                    },
                                    icon: Icon(
                                      CupertinoIcons.minus,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    cartData.quantity.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: cartData.quantity ==
                                        cartData.productQuantity
                                        ? null
                                        : () {
                                      _cartProvider
                                          .increament(cartData);
                                    },
                                    icon: Icon(
                                      CupertinoIcons.plus,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _cartProvider.removeProductFromCart(
                            cartData.productId + cartData.productSize);
                      },
                      icon: Icon(
                        CupertinoIcons.trash,
                        color: Colors.yellow.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/abandoned-cart.png',
                height: 200,
                width: 200,
              ),
              SizedBox(height: 20),
              Text(
                'Your Shopping Cart Is Empty',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return MainScreen();
                      }));
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 100,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade900,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.shade900.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub Total:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '\$${_cartProvider.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shipping Fee:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '\$0.00',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${(_cartProvider.totalPrice).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _cartProvider.totalPrice == 0.00
                  ? null
                  : () async {
                // Kiểm tra trạng thái đăng nhập
                if (_auth.currentUser == null) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return LoginScreen();
                      }));
                } else {
                  // Kiểm tra xem người dùng đã có buyerId trong Firestore chưa
                  String uid = _auth.currentUser!.uid;
                  var buyerDoc = await _firestore.collection('buyers').doc(uid).get();

                  if (!buyerDoc.exists) {
                    // Nếu không có buyerId hợp lệ, chuyển đến LoginScreen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return LoginScreen();
                        }));
                  } else {
                    // Nếu có buyerId hợp lệ, chuyển đến CheckOutScreen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return CheckOutScreen();
                        }));
                  }
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: _cartProvider.totalPrice == 0.00
                        ? Colors.grey
                        : Colors.yellow.shade900,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'Check Out',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
