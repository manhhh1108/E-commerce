import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartProvider _cartProvider = Provider.of<CartProvider>(context);
    final cartItems = _cartProvider.getCartItem;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade900,
        elevation: 0,
        title: Center(
          child: Text(
            'Cart Screen',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(  // Ensure content scrolls when too large
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,  // Allows list to take up only the necessary space
              itemCount: _cartProvider.getCartItem.length,
              itemBuilder: (context, index) {
                final cartData = _cartProvider.getCartItem.values.toList()[index];
                return Card(
                  child: SizedBox(
                    height: 170,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.network(cartData.imageUrl[0]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartData.productName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$' + " " + cartData.price.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow.shade900,
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                child: Text(cartData.productSize),
                              ),
                              // Use an Expanded widget to allow the quantity control to grow and shrink as needed
                              Expanded(
                                child: Container(
                                  width: 110,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade900,
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          // Decrease quantity logic here
                                        },
                                        icon: Icon(
                                          CupertinoIcons.minus,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        cartData.quantity.toString(),
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Increase quantity logic here
                                        },
                                        icon: Icon(
                                          CupertinoIcons.plus,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
