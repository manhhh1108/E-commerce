import 'package:flutter/material.dart';
import 'package:multi_store/vendor/views/screens/edit_product_tab/published_tab.dart';
import 'package:multi_store/vendor/views/screens/edit_product_tab/unpublished_tab.dart';

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.yellow.shade900,
          title: Text(
            'Manage Products',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 7,
              color: Colors.white, // Đổi màu chữ thành màu trắng
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Published',
                  style: TextStyle(color: Colors.white), // Màu trắng cho tab
                ),
              ),
              Tab(
                child: Text(
                  'Unpublished',
                  style: TextStyle(color: Colors.white), // Màu trắng cho tab
                ),
              ),
            ],
          ),
        ),
        body:TabBarView(children: [
          PublishedTab(),
          UnpublishedTab(),
        ])
      ),
    );
  }
}
