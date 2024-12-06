import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart'; // Đảm bảo đường dẫn đúng

class VendorLogoutScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          try {
            await _auth.signOut(); // Đăng xuất người dùng
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginVendorScreen(),
              ),
            ); // Điều hướng về màn hình đăng nhập
          } catch (e) {
            // Xử lý lỗi nếu có
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error logging out: $e')),
            );
          }
        },
        child: Text('Sign out'),
      ),
    );
  }
}
