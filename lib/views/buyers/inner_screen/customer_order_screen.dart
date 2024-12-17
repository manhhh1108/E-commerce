import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CustomerOrderScreen extends StatelessWidget {
  CustomerOrderScreen({super.key});

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
    // Lấy danh sách đơn hàng từ Firestore
    final Stream<QuerySnapshot> _ordersStream = _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.yellow.shade900,
        title: const Text(
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

              final fullName = data['fullName'] ?? 'N/A';
              final phone = data['phone'] ?? 'N/A';
              final address = data['address'] ?? 'N/A';
              final paymentMethod = data['paymentMethod'] ?? 'N/A';
              final orderStatus = data['orderStatus'] ?? 'Pending';

              return Slidable(
                key: ValueKey(data['orderId']),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    // Kiểm tra trạng thái đơn hàng trước khi hiển thị nút hủy
                    if (orderStatus != 'Completed') // Chỉ cho phép hủy nếu không phải "Completed"
                      SlidableAction(
                        onPressed: (context) async {
                          try {
                            final paymentStatus = data['paymentStatus'] ?? 'unpaid'; // Dùng giá trị mặc định nếu không có
                            if (orderStatus == 'Pending' && paymentStatus == 'unpaid') {
                              await _firestore
                                  .collection('orders')
                                  .doc(document.id)
                                  .update({'orderStatus': 'Canceled'});
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Order has been canceled.')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Only unpaid and pending orders can be canceled.')));
                            }
                          } catch (e) {
                            print("Lỗi khi hủy đơn hàng: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to cancel the order.')));
                          }
                        },
                        backgroundColor: Colors.red,
                        icon: Icons.close,
                        label: 'Cancel Order',
                      ),
                  ],
                ),
                child: ExpansionTile(
                  title: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 14,
                      child: orderStatus == 'Canceled'
                          ? Icon(Icons.cancel, color: Colors.red)
                          : orderStatus == 'Completed'
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : orderStatus == 'Delivering'
                          ? Icon(Icons.delivery_dining, color: Colors.purple)
                          : orderStatus == 'Preparing'
                          ? Icon(Icons.settings, color: Colors.blue)
                          : Icon(Icons.pending, color: Colors.yellow.shade900),
                    ),
                    title: Text(
                      orderStatus == 'Canceled'
                          ? 'Canceled'
                          : orderStatus == 'Completed'
                          ? 'Completed'
                          : orderStatus == 'Delivering'
                          ? 'Delivering'
                          : orderStatus == 'Preparing'
                          ? 'Preparing'
                          : 'Pending',
                      style: TextStyle(
                        color: orderStatus == 'Canceled'
                            ? Colors.red
                            : orderStatus == 'Completed'
                            ? Colors.green
                            : orderStatus == 'Delivering'
                            ? Colors.purple
                            : orderStatus == 'Preparing'
                            ? Colors.blue
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
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '$paymentMethod',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15),
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
                          const Text('Buyer Info:'),
                          Text('Full Name: $fullName'),
                          Text('Phone: $phone'),
                          Text('Address: $address'),
                          const Divider(),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index] as Map<String, dynamic>;

                              final productImage = item['productImage'] as List<dynamic>?;
                              final productName = item['productName'] ?? 'N/A';
                              final productPrice = item['productPrice'] ?? '0';
                              final productSize = item['productSize'] ?? 'N/A';
                              final quantity = item['quantity'] ?? 0;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: productImage != null && productImage.isNotEmpty
                                      ? NetworkImage(productImage[0] ?? '')
                                      : null,
                                ),
                                title: Text(productName),
                                subtitle: Text('Price: \$${productPrice} | Size: ${productSize}'),
                                trailing: Text('Qty: $quantity'),
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
