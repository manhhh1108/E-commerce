import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('buyers');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Something went wrong: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text("Document does not exist"));
        }

        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

        // Kiểm tra cấu trúc dữ liệu nhận được
        debugPrint(data.toString());

        return Scaffold(
          appBar: AppBar(
            elevation: 2,
            backgroundColor: Colors.yellow.shade900,
            title: Text('Profile', style: TextStyle(color: Colors.white)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              SizedBox(height: 25),
              Center(
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.yellow.shade900,
                  backgroundImage: NetworkImage(data['profileImage'] ?? ''),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['fullName'] ?? 'No Name',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['email'] ?? 'No Email',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(thickness: 2, color: Colors.grey),
              // ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
              ListTile(
                  leading: Icon(Icons.phone_iphone),
                  title: Text(
                    data['phoneNumber'] ?? 'No Phone Number',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )),
              ListTile(
                  leading: Icon(Icons.shopping_cart_outlined),
                  title: Text('Cart')),
              ListTile(
                  leading: Icon(Icons.store_outlined), title: Text('Orders')),
              ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
            ],
          ),
        );
      },
    );
  }
}
