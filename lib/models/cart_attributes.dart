import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class CartAttr with ChangeNotifier {
  final String productName;
  final String productId;
  final List imageUrl;
  final int quantity;
  final double price;
  final String vendorId;
  final String productSize;
  Timestamp scheduleDate;

  CartAttr(
      {required this.productName,
      required this.productId,
      required this.imageUrl,
      required this.quantity,
      required this.price,
      required this.vendorId,
      required this.productSize,
      required this.scheduleDate});
}
