import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_store/views/buyers/auth/login_screen.dart';

class CustomerOrderScreen extends StatelessWidget {
  CustomerOrderScreen({super.key});

  // Hàm định dạng ngày
  String formatedDate(String? date) {
    if (date == null) return 'N/A';
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat outputFormat = DateFormat('dd/MM/yyyy');
    return outputFormat.format(parsedDate);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách đơn hàng từ Firestore
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        // .where('buyerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.yellow.shade900,
        title: Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Xử lý lỗi
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          // Hiển thị vòng tròn loading khi đang chờ dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Danh sách đơn hàng
          final orders = snapshot.data?.docs;

          // Xử lý nếu không có đơn hàng nào
          if (orders == null || orders.isEmpty) {
            return const Center(
              child: Text(
                'No Orders Yet!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }

          // Hiển thị danh sách đơn hàng
          return ListView(
            children: orders.map((DocumentSnapshot document) {
              final data = document.data() as Map<String, dynamic>?;

              // Kiểm tra nếu dữ liệu bị thiếu
              if (data == null) {
                return const Center(child: Text('No data available'));
              }

              final cartItems = data['cartItems'] as List<dynamic>?;

              // Kiểm tra nếu không có sản phẩm trong đơn hàng
              if (cartItems == null || cartItems.isEmpty) {
                return const Center(child: Text('No items in this order'));
              }

              // Lấy thông tin người mua và kiểm tra null
              final buyerInfo =
                  data['buyerInfo'] as Map<String, dynamic>? ?? {};
              final fullName = buyerInfo['fullName'] ?? 'N/A';
              final phone = buyerInfo['phone'] ?? 'N/A';
              final address = buyerInfo['address'] ?? 'N/A';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sử dụng ExpansionTile để ẩn/hiển thị thông tin đơn hàng và người mua
                  ExpansionTile(
                    title: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 14,
                        child: data['accepted'] == true
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.pending, color: Colors.orange),
                      ),
                      title: Text(
                        data['accepted'] == true ? 'Accepted' : 'Pending',
                        style: TextStyle(
                          color: data['accepted'] == true
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${data['orderId'] ?? 'N/A'}'),
                          Text('Date: ${formatedDate(data['orderDate'])}'),
                          Text(
                            'Total Price: \$${data['totalOrderPrice'] ?? '0'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: [
                      // Thông tin người mua
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Buyer Info:'),
                            Text('Full Name: ${document['fullName']}'),
                            Text('Phone: ${document['phone']}'),
                            Text('Address: ${document['address']}'),
                            const Divider(),
                            // Hiển thị danh sách sản phẩm trong đơn hàng
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item =
                                    cartItems[index] as Map<String, dynamic>;

                                // Safely access fields in cart item
                                final productImage =
                                    item['productImage'] as List<dynamic>?;
                                final productName =
                                    item['productName'] ?? 'No name';
                                final productPrice =
                                    item['productPrice'] ?? '0';
                                final productSize =
                                    item['productSize'] ?? 'N/A';
                                final quantity = item['quantity'] ?? 0;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: productImage != null &&
                                            productImage.isNotEmpty
                                        ? NetworkImage(productImage[0] ?? '')
                                        : null,
                                  ),
                                  title: Text(productName),
                                  subtitle: Text(
                                    'Price: \$${productPrice} | Size: ${productSize}',
                                  ),
                                  trailing: Text('Qty: $quantity'),
                                );
                              },
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
