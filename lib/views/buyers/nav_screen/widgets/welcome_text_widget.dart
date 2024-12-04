import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multi_store/provider/user_provider.dart'; // Import UserProvider hoặc AuthProvider

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng từ Provider
    // final userProvider = Provider.of<UserProvider>(context);
    // final userName = userProvider.userName ?? "Guest"; // Hiển thị "Guest" nếu chưa có tên

    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top, left: 25, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chào mừng người dùng
          Expanded(
            child: Text(
              // '$userName, What Are You\nLooking For 👀',
              ', What Are You\nLooking For 👀',
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
