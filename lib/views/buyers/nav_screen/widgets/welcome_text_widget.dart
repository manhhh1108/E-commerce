import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeText extends StatefulWidget {
  const WelcomeText({super.key});

  @override
  State<WelcomeText> createState() => _WelcomeTextState();
}

class _WelcomeTextState extends State<WelcomeText> {
  String? fullName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Hàm lấy tên người dùng từ Firestore
  Future<void> _fetchUserName() async {
    try {
      // Lấy buyerId từ FirebaseAuth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final buyerId = user.uid;

        // Truy vấn Firestore để lấy thông tin người dùng
        final docSnapshot = await FirebaseFirestore.instance
            .collection('buyers')
            .doc(buyerId)
            .get();

        if (docSnapshot.exists) {
          setState(() {
            fullName = docSnapshot.data()?['fullName']; // Lấy tên người dùng
          });
        }
      }
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top, left: 25, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chào mừng người dùng
          Expanded(
            child: Text(
              fullName != null && fullName!.isNotEmpty
                  ? 'Hi $fullName, What Are You\nLooking For 👀'
                  : 'Hi, What Are You\nLooking For 👀',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                fontFamily: 'Semi-Bold',
              ),
              overflow: TextOverflow.ellipsis, // Giới hạn nếu tên quá dài
            ),
          ),

          // Icon giỏ hàng
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}
