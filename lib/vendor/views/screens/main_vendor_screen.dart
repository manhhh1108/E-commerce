import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/vendor/views/screens/earnings_screen.dart';
import 'package:multi_store/vendor/views/screens/edit_product_screen.dart';
import 'package:multi_store/vendor/views/screens/upload_screen.dart';
import 'package:multi_store/vendor/views/screens/vendor_logout_screen.dart';
import 'package:multi_store/vendor/views/screens/vendor_order_screen.dart';

class MainVendorScreen extends StatefulWidget {
  const MainVendorScreen({super.key});

  @override
  State<MainVendorScreen> createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  int _pageIndex = 0;

  List<Widget> _pages = [
    EarningsScreen(),
    UploadScreen(),
    EditProductScreen(),
    VendorOrderScreen(),
    VendorLogoutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _pageIndex,
          onTap: (value){
            setState(() {
              _pageIndex = value;
            });
          },
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.yellow.shade900,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.money_dollar),
              label: "Earnings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload),
              label: "Uploads",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: "Edit",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shopping_cart),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: "Logout",
            ),
          ]),
      body: _pages[_pageIndex],
    );
  }
}
