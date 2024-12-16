import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:multi_store/provider/cart_provider.dart';
import 'package:multi_store/views/buyers/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  Map<String, dynamic>? intentPaymentData;

  // Lưu đơn hàng vào Firestore và cập nhật stock
  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    try {
      orderData['orderStatus'] = 'Pending';
      // Lưu đơn hàng vào Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderData['orderId'])
          .set(orderData);
      await updateProductStock(orderData['cartItems']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );
      navigateToMainScreen();
    } catch (e) {
      handleError("Error placing the order", e);
    }
  }

  // Cập nhật số lượng sản phẩm trong Firestore
  Future<void> updateProductStock(List<Map<String, dynamic>> cartItems) async {
    final productCollection = FirebaseFirestore.instance.collection('products');
    for (var item in cartItems) {
      final productId = item['productId'];
      final quantityOrdered = item['quantity'];

      DocumentReference productRef = productCollection.doc(productId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot productSnapshot = await transaction.get(productRef);
        if (!productSnapshot.exists) throw Exception("Product does not exist");

        int currentStock = productSnapshot['quantity'];
        if (currentStock < quantityOrdered) throw Exception("Not enough stock");

        transaction
            .update(productRef, {'quantity': currentStock - quantityOrdered});
      }).catchError((error) => print("Error updating stock: $error"));
    }
  }

  // Hiển thị Modal Bottom Sheet để chọn phương thức thanh toán
  Future<void> showPaymentOptions(Map<String, dynamic> orderData) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.payment, color: Colors.green),
                title: Text('Pay on Delivery'),
                onTap: () {
                  Navigator.pop(context);
                  orderData['paymentMethod'] = 'Cash On Delivery';
                  orderData['paymentStatus'] = 'unpaid';
                  placeOrder(orderData);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.credit_card, color: Colors.blue),
                title: Text('Pay by Card'),
                onTap: () {
                  Navigator.pop(context);
                  paymentSheetInitialization(
                      orderData['totalOrderPrice'], orderData);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Khởi tạo Stripe Payment Sheet
  Future<void> paymentSheetInitialization(
      double amount, Map<String, dynamic> orderData) async {
    try {
      intentPaymentData = await makeIntentForPayment(amount.toString(), "USD");
      if (intentPaymentData?.containsKey("client_secret") ?? false) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: intentPaymentData!["client_secret"],
            style: ThemeMode.dark,
            merchantDisplayName: "Multi Store",
          ),
        );
        showPaymentSheet(orderData);
      } else {
        throw Exception("Client secret not available");
      }
    } catch (e) {
      handleError("Payment initialization failed", e);
    }
  }

  // Hiển thị Stripe Payment Sheet
  Future<void> showPaymentSheet(Map<String, dynamic> orderData) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      orderData['paymentMethod'] = 'Card Payment';
      orderData['paymentStatus'] = 'paid';
      placeOrder(orderData);
    } on StripeException catch (e) {
      handleError("Stripe Error: $e", e);
    } catch (e) {
      handleError("Unexpected Error: $e", e);
    }
  }

  // Tạo intent thanh toán từ Stripe API
  Future<Map<String, dynamic>?> makeIntentForPayment(
      String amount, String currency) async {
    try {
      final paymentInfo = {
        'amount': (double.parse(amount) * 100).toInt().toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey = dotenv.env['STRIPE_SECRET_KEY'];
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: paymentInfo,
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Stripe API Error: ${response.body}");
      }
    } catch (e) {
      print("Error creating intent: $e");
      return null;
    }
  }

  void navigateToMainScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  void handleError(String message, dynamic error) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Widget buildOrderStatus(String orderStatus) {
  //   Color statusColor;
  //   String statusText;
  //
  //   switch (orderStatus) {
  //     case 'Pending':
  //       statusColor = Colors.orange;
  //       statusText = 'Pending';
  //       break;
  //     case 'Preparing':
  //       statusColor = Colors.blue;
  //       statusText = 'Preparing';
  //       break;
  //     case 'Delivering':
  //       statusColor = Colors.purple;
  //       statusText = 'Delivering';
  //       break;
  //     case 'Completed':
  //       statusColor = Colors.green;
  //       statusText = 'Completed';
  //       break;
  //     case 'Canceled':
  //       statusColor = Colors.red;
  //       statusText = 'Canceled';
  //       break;
  //     default:
  //       statusColor = Colors.grey;
  //       statusText = 'Unknown';
  //   }
  //
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //     decoration: BoxDecoration(
  //       color: statusColor.withOpacity(0.2),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Text(
  //       statusText,
  //       style: TextStyle(
  //         color: statusColor,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    final CartProvider _cartProvider = Provider.of<CartProvider>(context);
    final cartItems = _cartProvider.getCartItem;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('buyers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.yellow.shade900));
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          return const Center(child: Text("Something went wrong"));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final address = data['address'] != null ? data['address'] : '';
        double totalAmount = _cartProvider.totalPrice;

        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.yellow.shade900,
            title: const Text("Checkout",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
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
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 4,
                                spreadRadius: 2)
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.network(cartData.imageUrl.isNotEmpty
                                  ? cartData.imageUrl[0]
                                  : 'https://via.placeholder.com/150'),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cartData.productName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        '\$${cartData.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                    Row(
                                      children: [
                                        Text('Size: ${cartData.productSize}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black)),
                                        const SizedBox(width: 10),
                                        Text('Quantity: ${cartData.quantity}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          bottomSheet: address.isEmpty
              ? TextButton(
                  onPressed: () {/* Navigate to address screen */},
                  child: Text('Enter Address'))
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
                        'email': data['email'],
                        'phone': data['phoneNumber'],
                        'buyerId': data['buyerId'],
                        'fullName': data['fullName'],
                        'buyerPhoto': data['profileImage'],
                        'orderDate': orderDate,
                        'cartItems': cartItemsData,
                        'totalOrderPrice': totalAmount,
                        'address': address,
                      };

                      showPaymentOptions(orderData);
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.yellow.shade900,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          'Proceed to Checkout',
                          style: const TextStyle(
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
