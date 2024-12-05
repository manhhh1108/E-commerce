import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/vendor/models/vendor_user_models.dart';
import 'package:multi_store/vendor/views/auth/vendor_register_screen.dart';
import 'package:multi_store/vendor/views/screens/login.dart';
import 'package:multi_store/vendor/views/screens/main_vendor_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final CollectionReference _vendorsStream =
        FirebaseFirestore.instance.collection('vendors');

    if (_auth.currentUser == null) {
      // Chuyển hướng đến màn hình đăng nhập nếu không có người dùng
      Future.microtask(() => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginVendorScreen()),
          ));
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _vendorsStream.doc(_auth.currentUser!.uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return VendorRegisterScreen();
          }

          VendorUserModel vendorUserModel = VendorUserModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>);

          if (vendorUserModel.apporoved == true) {
            return MainVendorScreen();
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    vendorUserModel.storeImage!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Text('Error loading image');
                    },
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  vendorUserModel.businessName.toString(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 15),
                Text(
                  'Your application has been sent to shop admin\nAdmin will get back to you soon',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: () async {
                    try {
                      await _auth.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => LoginVendorScreen()),
                      );
                    } catch (e) {
                      print('Error signing out: $e');
                    }
                  },
                  child: Text('Signout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
