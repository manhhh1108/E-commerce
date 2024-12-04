import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_store/provider/cart_provider.dart';
import 'package:multi_store/views/buyers/inner_screen/edit_profile.dart';
import 'package:multi_store/views/buyers/main_screen.dart';
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

    // Tính tổng tiền phải thanh toán
    final totalAmount = _cartProvider.totalPrice;

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.yellow.shade900,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Checkout",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            body: SafeArea(
              child: ListView.builder(
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
                                  cartData.imageUrl.isNotEmpty
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
            ),
            bottomSheet: data['address'] == null || data['address'].isEmpty
                ? TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EditProfile(userData: data,);
                      }));
                    },
                    child: Text('Enter Address'))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        EasyLoading.show(status: 'Placing Order');
                        final orderId =
                            const Uuid().v4(); // Tạo mã đơn hàng duy nhất
                        final orderDate =
                            DateTime.now();

                        // Chuẩn bị dữ liệu giỏ hàng
                        List<Map<String, dynamic>> cartItemsData =
                            _cartProvider.getCartItem.values
                                .map((item) => {
                                      'productId': item.productId,
                                      'productName': item.productName,
                                      'productPrice': item.price,
                                      'productImage': item.imageUrl,
                                      'quantity': item.quantity,
                                      'productSize': item.productSize,
                                      'totalPrice': item.price * item.quantity,
                                    })
                                .toList();

                        // Tạo đơn hàng duy nhất
                        _fireStore.collection('orders').doc(orderId).set({
                          'orderId': orderId,
                          'vendorIds': _cartProvider.getCartItem.values
                              .map((item) => item.vendorId)
                              .toSet()
                              .toList(), // Danh sách các vendor liên quan
                          'email': data['email'],
                          'phone': data['phoneNumber'],
                          'address': data['address'],
                          'buyerId': data['buyerId'],
                          'fullName': data['fullName'],
                          'buyerPhoto': data['profileImage'],
                          'orderDate': orderDate.toIso8601String(),
                          'totalOrderPrice':
                              _cartProvider.totalPrice, // Tổng tiền cả giỏ hàng
                          'cartItems':
                              cartItemsData, // Danh sách các sản phẩm trong giỏ
                        }).whenComplete(() {
                          setState(() {
                            _cartProvider.getCartItem.clear();
                          });
                          EasyLoading.dismiss();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return MainScreen();
                          }));
                        });
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
        }

        return Center(
          child: CircularProgressIndicator(
            color: Colors.yellow.shade900,
          ),
        );
      },
    );
  }
}
