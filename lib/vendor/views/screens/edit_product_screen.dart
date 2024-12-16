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
            automaticallyImplyLeading: false,
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.yellow.shade900,
            title: Text(
              'Manage Products',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 7,
                color: Colors.white,
              ),
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Published',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Tab(
                  child: Text(
                    'Unpublished',
                    style: TextStyle(
                        color: Colors.white, fontSize: 18), // Màu trắng cho tab
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(children: [
            PublishedTab(),
            UnpublishedTab(),
          ])),
    );
  }
}
