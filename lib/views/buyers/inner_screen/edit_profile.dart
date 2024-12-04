import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_store/views/buyers/inner_screen/search_view.dart';

class EditProfile extends StatefulWidget {
  final dynamic userData;

  EditProfile({super.key, this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Check if userData is null or not before accessing it
    if (widget.userData != null) {
      setState(() {
        _fullNameController.text = widget.userData['fullName'] ?? '';
        _emailController.text = widget.userData['email'] ?? '';
        _phoneController.text = widget.userData['phoneNumber'] ?? '';
        _addressController.text = widget.userData['address'] ?? '';
      });
    } else {
      print("No user data provided");
      _fullNameController.text = '';
      _emailController.text = '';
      _phoneController.text = '';
      _addressController.text = '';
    }
  }

  _selectAddress() async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchView()),
    );

    if (selectedAddress != null) {
      setState(() {
        _addressController.text = selectedAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade900,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Image Section
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.yellow.shade900,
                      backgroundImage:
                          NetworkImage(widget.userData['profileImage'] ?? ''),
                    ),
                    Positioned(
                      bottom: -10,
                      right: -10,
                      child: InkWell(
                        onTap: () {
                          // Implement functionality to change profile image
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(CupertinoIcons.photo,
                              color: Colors.yellow.shade900),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Full Name Field
                _buildTextField(_fullNameController, 'Full Name', CupertinoIcons.person),
                SizedBox(height: 16),

                // Email Field
                _buildTextField(_emailController, 'Email', CupertinoIcons.mail),
                SizedBox(height: 16),

                // Phone Field
                _buildTextField(_phoneController, 'Phone', CupertinoIcons.phone),
                SizedBox(height: 16),

                // Address Field with Search Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _addressController,
                    readOnly: true, // Don't allow direct editing
                    decoration: InputDecoration(
                      labelText: 'Enter Address',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: Colors.yellow.shade900),
                        onPressed: _selectAddress,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(13.0),
        child: InkWell(
          onTap: () async {
            EasyLoading.show(status: "Updating");
            await _firestore
                .collection('buyers')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              'fullName': _fullNameController.text,
              'email': _emailController.text,
              'phoneNumber': _phoneController.text,
              'address': _addressController.text,
            }).whenComplete(() {
              EasyLoading.dismiss();
              Navigator.pop(context);
            });
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.yellow.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build form text fields
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.yellow.shade900),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
