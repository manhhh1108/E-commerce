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

  Future<void> showPaymentSheet(Map<String, dynamic> orderData) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Lưu đơn hàng vào Firestore nếu thanh toán thành công
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderData['orderId'])
          .set(orderData);

      // Update product stock in Firestore
      await updateProductStock(orderData['cartItems']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );

      // Chuyển về MainScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } on StripeException catch (e) {
      print("Stripe Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed!")),
      );
    } catch (e) {
      print("Unexpected Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred!")),
      );
    }
  }

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

  Future<void> paymentSheetInitialization(
      double amount, Map<String, dynamic> orderData) async {
    try {
      intentPaymentData = await makeIntentForPayment(amount.toString(), "USD");

      if (intentPaymentData != null &&
          intentPaymentData!.containsKey("client_secret")) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: intentPaymentData!["client_secret"],
            style: ThemeMode.dark,
            merchantDisplayName: "Your Company Name",
          ),
        );
        showPaymentSheet(orderData);
      } else {
        throw Exception("Client secret not available.");
      }
    } catch (e) {
      print("Error initializing PaymentSheet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment initialization failed!")),
      );
    }
  }

  Future<void> updateProductStock(List<Map<String, dynamic>> cartItems) async {
    final productCollection = FirebaseFirestore.instance.collection('products');

    // Loop through cart items and reduce product stock
    for (var item in cartItems) {
      final productId = item['productId'];
      final quantityOrdered = item['quantity'];

      // Get the product document by its ID
      DocumentReference productRef = productCollection.doc(productId);

      // Update the product quantity in Firestore
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get current product data
        DocumentSnapshot productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception("Product does not exist in database");
        }

        int currentStock = productSnapshot['quantity'];

        if (currentStock < quantityOrdered) {
          throw Exception("Not enough stock for product: $productId");
        }

        // Decrease the stock by the ordered quantity
        transaction.update(productRef, {
          'quantity': currentStock - quantityOrdered,
        });
      }).catchError((error) {
        print("Error updating stock: $error");
      });
    }
  }

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

        double totalAmount = _cartProvider.totalPrice; // Số tiền cần thanh toán

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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        color: Colors.green,
                                      ),
                                    ),
                                    // Hiển thị size và số lượng
                                    Row(
                                      children: [
                                        Text(
                                          'Size: ${cartData.productSize}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                            width:
                                                10), // Khoảng cách giữa size và số lượng
                                        Text(
                                          'Quantity: ${cartData.quantity}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
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
                  onPressed: () {
                    // Navigate to address screen
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
                        'totalOrderPrice': totalAmount,
                        'cartItems': cartItemsData,
                        'accepted': false,
                      };

                      paymentSheetInitialization(totalAmount, orderData);
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.yellow.shade900,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          'Pay \$${totalAmount.toStringAsFixed(2)}', // Hiển thị số tiền cần thanh toán
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
