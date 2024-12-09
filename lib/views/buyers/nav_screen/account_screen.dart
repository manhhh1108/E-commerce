import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/views/buyers/auth/login_screen.dart';
import 'package:multi_store/views/buyers/inner_screen/customer_order_screen.dart';
import 'package:multi_store/views/buyers/inner_screen/edit_profile.dart';

class AccountScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

        // Safely unwrap and handle potential null values
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

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
                  backgroundImage: NetworkImage(
                    data['profileImage'] ?? 'https://via.placeholder.com/150',
                  ),
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
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EditProfile(
                      userData: data,
                    );
                  }));
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width - 250,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade900,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Divider(thickness: 2, color: Colors.grey),
              ),
              ListTile(
                leading: Icon(Icons.phone_iphone),
                title: Text(
                  data['phoneNumber'] ?? 'No Phone Number',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart_outlined),
                title: Text('Cart'),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return CustomerOrderScreen();
                    }),
                  );
                },
                leading: Icon(CupertinoIcons.bag),
                title: Text('Order'),
              ),
              ListTile(
                onTap: () async {
                  await _auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return LoginScreen();
                    }),
                  );
                },
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ],
          ),
        );
      },
    );
  }
}
