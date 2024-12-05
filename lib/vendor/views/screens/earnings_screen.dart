import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String vendorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade900,
        title: const Text(
          'Earnings',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 7,
            color: Colors.white, // Đổi màu chữ thành màu trắng
          ),
        ),
        centerTitle: true, // Đảm bảo title được căn giữa
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('vendors').doc(vendorId).get(),
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
          final storeImg = vendorData['image'] ?? 'https://via.placeholder.com/150'; // URL placeholder nếu không có ảnh

          return Column(
            children: [
              // Hiển thị thông tin cửa hàng
              Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Ảnh đại diện
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
                    // Tên cửa hàng
                    Expanded(
                      child: Text(
                        storeName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tạo khoảng cách giữa AppBar và các khung
              SizedBox(height: 80), // Khoảng cách giữa AppBar và các khung

              // Hiển thị tổng số tiền và số lượng đã bán
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('orders')
                    .where('vendorIds', isEqualTo: vendorId)
                    .get(),
                builder: (context, ordersSnapshot) {
                  if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  double totalAmount = 0.0;
                  int totalQuantity = 0;

                  // Tính tổng số tiền và số lượng đã bán từ bảng orders
                  for (var order in ordersSnapshot.data!.docs) {
                    final productPrice = order['productPrice']; // productPrice có thể là num
                    final quantity = order['quantity']; // quantity có thể là num

                    // Kiểm tra và ép kiểu đúng
                    if (productPrice is num && quantity is num) {
                      totalAmount += (productPrice.toDouble() * quantity.toDouble());
                      totalQuantity += quantity.toInt();
                    }
                  }

                  // Nếu không có đơn hàng, mặc định giá trị là 0
                  if (ordersSnapshot.data!.docs.isEmpty) {
                    totalAmount = 0.0;
                    totalQuantity = 0;
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các khung
                    children: [
                      // Khung tổng thu nhập với chiều cao và chiều rộng cố định
                      Container(
                        width: MediaQuery.of(context).size.width - 120, // Chiều rộng cố định (width - padding)
                        height: 150, // Chiều cao cố định
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Khoảng cách giữa các khung
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade900,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Earnings',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Khoảng cách giữa 2 khung
                      SizedBox(height: 120),

                      // Khung tổng số lượng hàng bán được với chiều cao và chiều rộng cố định
                      Container(
                        width: MediaQuery.of(context).size.width - 120, // Chiều rộng cố định (width - padding)
                        height: 150, // Chiều cao cố định
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Khoảng cách giữa các khung
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade900,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Items Sold',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '$totalQuantity',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
