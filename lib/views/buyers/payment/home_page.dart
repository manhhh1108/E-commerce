import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:multi_store/views/buyers/main_screen.dart';
import 'package:multi_store/views/buyers/payment/key.dart';

class HomePagePayment extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> orderData;

  const HomePagePayment(
      {required this.amount, required this.orderData, Key? key})
      : super(key: key);

  @override
  State<HomePagePayment> createState() => _HomePagePaymentState();
}

class _HomePagePaymentState extends State<HomePagePayment> {
  Map<String, dynamic>? intentPaymentData;

  Future<void> showPaymetSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Nếu thanh toán thành công, lưu đơn hàng
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderData['orderId'])
          .set(widget.orderData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );

      // Chuyển về MainScreen sau khi thanh toán thành công
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
      );
    } on StripeException catch (e) {
      print("Lỗi Stripe: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed!")),
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

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: paymentInfo,
        headers: {
          'Authorization': 'Bearer $SecretKey',
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

  Future<void> paymentSheetInitialization() async {
    try {
      intentPaymentData =
      await makeIntentForPayment(widget.amount.toString(), "USD");

      if (intentPaymentData != null &&
          intentPaymentData!.containsKey("client_secret")) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: intentPaymentData!["client_secret"],
            style: ThemeMode.dark,
            merchantDisplayName: "Your Company Name",
          ),
        );
        showPaymetSheet();
      } else {
        throw Exception("Client secret không khả dụng.");
      }
    } catch (e) {
      print("Lỗi khởi tạo PaymentSheet: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.yellow.shade900,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => paymentSheetInitialization(),
          child: Text("Pay \$${widget.amount.toStringAsFixed(2)}"),
        ),
      ),
    );
  }
}
