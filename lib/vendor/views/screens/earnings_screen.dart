import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Kiểm tra nếu người dùng chưa đăng nhập
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade900,
          title: const Text(
            'Earnings',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LoginVendorScreen()), // Điều hướng đến màn hình đăng nhập
              );
            },
            child: const Text(
              'Login to Continue',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }

    final String vendorId = user.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade900,
        title: const Text(
          'Earnings',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Vendor data not found',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          final vendorData = snapshot.data!.data() as Map<String, dynamic>;
          final storeName = vendorData['businessName'] ?? 'No Store Name';
          final storeImg = vendorData['image'] ??
              'https://via.placeholder.com/150'; // Placeholder nếu không có ảnh

          return SingleChildScrollView(
            child: Column(
              children: [
                // Thông tin cửa hàng
                _buildStoreInfo(storeImg, storeName),
                const SizedBox(height: 20),

                // Hiển thị tổng số tiền và số lượng đã bán
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('orders')
                      .where('vendorIds',
                          arrayContains: vendorId) // Lọc đơn hàng theo vendorId
                      .get(),
                  builder: (context, ordersSnapshot) {
                    if (ordersSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    double totalEarnings = 0.0;
                    int totalItemsSold = 0;

                    if (ordersSnapshot.hasData) {
                      for (var order in ordersSnapshot.data!.docs) {
                        final orderData = order.data() as Map<String, dynamic>;
                        final cartItems =
                            orderData['cartItems'] as List<dynamic>? ?? [];

                        // Duyệt qua từng item trong cartItems
                        for (var item in cartItems) {
                          if (item is Map<String, dynamic>) {
                            final productPrice =
                                (item['productPrice'] ?? 0) as num;
                            final quantity = (item['quantity'] ?? 0) as num;

                            // Kiểm tra nếu vendorId của sản phẩm trong cartItem khớp với vendorId hiện tại
                            if (item['vendorId'] == vendorId) {
                              totalEarnings +=
                                  productPrice * quantity; // Tính thu nhập
                              totalItemsSold +=
                                  quantity.toInt(); // Tính số lượng đã bán
                            }
                          }
                        }
                      }
                    }

                    return Column(
                      children: [
                        _buildEarningsCard(
                          context,
                          title: 'Total Earnings',
                          value: '\$${totalEarnings.toStringAsFixed(2)}',
                          color: Colors.yellow.shade900,
                        ),
                        const SizedBox(height: 20),
                        _buildEarningsCard(
                          context,
                          title: 'Total Items Sold',
                          value: '$totalItemsSold',
                          color: Colors.yellow.shade900,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreInfo(String storeImg, String storeName) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(storeImg),
            onBackgroundImageError: (error, stackTrace) => const Icon(
              Icons.store,
              size: 30,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              storeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context,
      {required String title, required String value, required Color color}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
