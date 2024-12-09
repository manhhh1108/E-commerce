import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../auth/login.dart';

class VendorOrderScreen extends StatelessWidget {
  VendorOrderScreen({super.key});

  // Hàm định dạng ngày
  String formatedDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat outputFormat = DateFormat('dd/MM/yyyy');
    return outputFormat.format(parsedDate);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LoginVendorScreen()), // Điều hướng đến LoginVendorScreen
            );
          },
          child: Text('Login to Continue', style: TextStyle(fontSize: 18)),
        ),
      );
    }
    // Lấy danh sách đơn hàng từ Firestore
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.yellow.shade900,
        title: const Center(
          child: Text(
            'My Orders',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 30,
            ),
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
          final orders = snapshot.data!.docs;

          // Xử lý nếu không có đơn hàng nào
          if (orders.isEmpty) {
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
              final data = document.data() as Map<String, dynamic>;
              final cartItems = data['cartItems'] as List<dynamic>;

              // Lấy thông tin người mua và kiểm tra null
              final buyerInfo = data['buyerInfo'] as Map<String, dynamic>?;
              final fullName = buyerInfo?['fullName'] ?? 'N/A';
              final phone = buyerInfo?['phone'] ?? 'N/A';
              final address = buyerInfo?['address'] ?? 'N/A';

              return Slidable(
                child: Column(
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
                        title: data['accepted'] == true
                            ? Text(
                                'Accepted',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                'Pending',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ID: ${data['orderId']}'),
                            Text('Date: ${formatedDate(data['orderDate'])}'),
                            Text(
                              'Total Price: \$${data['totalOrderPrice']}',
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
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(item['productImage'][0]),
                                    ),
                                    title: Text(item['productName']),
                                    subtitle: Text(
                                      'Price: \$${item['productPrice']} | Size: ${item['productSize']}',
                                    ),
                                    trailing: Text('Qty: ${item['quantity']}'),
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
                ),
                key: ValueKey(document['orderId']),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  dismissible: DismissiblePane(onDismissed: () {}),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        await _firestore
                            .collection('orders')
                            .doc(document['orderId'])
                            .update({
                          'accepted': false,
                        });
                      },
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Reject',
                    ),
                    SlidableAction(
                      onPressed: (context) async {
                        await _firestore
                            .collection('orders')
                            .doc(document['orderId'])
                            .update({
                          'accepted': true,
                        });
                      },
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.check,
                      label: 'Accept',
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
