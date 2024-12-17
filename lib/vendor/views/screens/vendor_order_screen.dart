import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../auth/login.dart';

class VendorOrderScreen extends StatelessWidget {
  VendorOrderScreen({super.key});

  // Hàm định dạng ngày
  String formatedDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final DateTime parsedDate = timestamp.toDate();
    final DateFormat outputFormat = DateFormat('dd/MM/yyyy');
    return outputFormat.format(parsedDate);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Nếu user chưa đăng nhập
    if (user == null) {
      return Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginVendorScreen()),
            );
          },
          child: const Text('Login to Continue', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    // Lấy danh sách đơn hàng từ Firestore
    final Stream<QuerySnapshot> _ordersStream =
    _firestore.collection('orders').snapshots();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            return const Center(child: Text('Something went wrong'));
          }

          // Hiển thị vòng tròn loading khi đang chờ dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Danh sách đơn hàng
          final orders = snapshot.data!.docs;

          // Lọc các đơn hàng có chứa sản phẩm thuộc vendor hiện tại
          final filteredOrders = orders.where((document) {
            final data = document.data() as Map<String, dynamic>;
            final cartItems = data['cartItems'] as List<dynamic>;

            return cartItems.any((item) => item['vendorId'] == user.uid);
          }).toList();

          // Xử lý nếu không có đơn hàng nào
          if (filteredOrders.isEmpty) {
            return const Center(
              child: Text(
                'No Orders for Your Shop Yet!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }

          // Hiển thị danh sách đơn hàng đã lọc
          return ListView(
            children: filteredOrders.map((DocumentSnapshot document) {
              final data = document.data() as Map<String, dynamic>;
              final cartItems = data['cartItems'] as List<dynamic>;

              final fullName = data['fullName'] ?? 'N/A';
              final phone = data['phone'] ?? 'N/A';
              final address = data['address'] ?? 'N/A';
              final paymentMethod = data['paymentMethod'] ?? 'N/A';

              // Lọc sản phẩm chỉ thuộc shop hiện tại
              final filteredItems = cartItems.where((item) {
                return item['vendorId'] == user.uid;
              }).toList();

              // Tính tổng giá trị của các sản phẩm thuộc vendor hiện tại
              double totalPrice = 0;
              for (var item in filteredItems) {
                final price =
                    double.tryParse(item['productPrice'].toString()) ?? 0;
                final quantity = item['quantity'] ?? 0;
                totalPrice += price * quantity;
              }

              // Lấy màu chữ dựa trên trạng thái đơn hàng
              Color getStatusColor(String status) {
                switch (status) {
                  case 'Canceled':
                    return Colors.red;
                  case 'Preparing':
                    return Colors.blue;
                  case 'Delivering':
                    return Colors.purple;
                  case 'Completed':
                    return Colors.green;
                  default:
                    return Colors.yellow.shade900;
                }
              }

              return Slidable(
                key: ValueKey(data['orderId']),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    // Kiểm tra nếu trạng thái không phải "Completed" hoặc "Canceled" thì mới cho phép thay đổi
                    if (data['orderStatus'] != 'Completed' && data['orderStatus'] != 'Canceled')
                      SlidableAction(
                        onPressed: (context) async {
                          await _firestore
                              .collection('orders')
                              .doc(document.id)
                              .update({
                            'orderStatus': 'Preparing',
                          });
                        },
                        backgroundColor: Colors.blue,
                        icon: Icons.settings,
                        label: 'Preparing',
                      ),
                    if (data['orderStatus'] != 'Completed' && data['orderStatus'] != 'Canceled')
                      SlidableAction(
                        onPressed: (context) async {
                          await _firestore
                              .collection('orders')
                              .doc(document.id)
                              .update({
                            'orderStatus': 'Delivering',
                          });
                        },
                        backgroundColor: Colors.orange,
                        icon: Icons.delivery_dining,
                        label: 'Delivering',
                      ),
                    if (data['orderStatus'] != 'Completed' && data['orderStatus'] != 'Canceled')
                      SlidableAction(
                        onPressed: (context) async {
                          await _firestore
                              .collection('orders')
                              .doc(document.id)
                              .update({
                            'orderStatus': 'Completed',
                            'paymentStatus': 'paid', // Cập nhật paymentStatus thành 'paid'
                          });
                        },
                        backgroundColor: Colors.green,
                        icon: Icons.check,
                        label: 'Completed',
                      ),
                  ],
                ),
                child: ExpansionTile(
                  title: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        data['orderStatus'] == 'Completed'
                            ? Icons.check
                            : data['orderStatus'] == 'Delivering'
                            ? Icons.delivery_dining
                            : data['orderStatus'] == 'Preparing'
                            ? Icons.settings
                            : data['orderStatus'] == 'Canceled'
                            ? Icons.cancel
                            : Icons.pending,
                        color: getStatusColor(data['orderStatus'] ?? 'Pending'),
                      ),
                    ),
                    title: Text(
                      data['orderStatus'] ?? 'Pending',
                      style: TextStyle(
                        color: getStatusColor(data['orderStatus'] ?? 'Pending'),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: ${data['orderId']}'),
                        Text('Date: ${formatedDate(data['orderDate'])}'),
                        Text(
                          'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '$paymentMethod',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Buyer Info:'),
                          Text('Full Name: $fullName'),
                          Text('Phone: $phone'),
                          Text('Address: $address'),
                          const Divider(),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item =
                              filteredItems[index] as Map<String, dynamic>;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                  NetworkImage(item['productImage'][0]),
                                ),
                                title: Text(item['productName']),
                                subtitle: Text(
                                    'Price: \$${item['productPrice']} | Size: ${item['productSize']}'),
                                trailing: Text('Qty: ${item['quantity']}'),
                              );
                            },
                          ),
                          Divider(),
                        ],
                      ),
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
