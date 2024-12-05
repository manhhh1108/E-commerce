import 'dart:typed_data';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_store/vendor/controllers/vendor_register_controller.dart';

import '../screens/landing_screen.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final VendorController _vendorController = VendorController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String businessName;
  late String email;
  late String phoneNumber;
  late String taxNumber;
  late String countryValue;
  late String stateValue;
  late String cityValue;

  Uint8List? _image;

  String? _taxStatus;
  List<String> _taxOptions = ['Yes', 'No'];

  selectGalleryImage() async {
    Uint8List im = await _vendorController.pickStoreImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  selectCameraImage() async {
    Uint8List im = await _vendorController.pickStoreImage(ImageSource.camera);
    setState(() {
      _image = im;
    });
  }

  _saveVendorDetail() async {
    if (_formKey.currentState!.validate()) {
      if (_taxStatus == null) {
        EasyLoading.showError('Please select Tax Register option');
        return;
      }

      if (_taxStatus == 'No') {
        taxNumber = "N/A";
      }

      if (_image == null) {
        EasyLoading.showError('Please upload a store image');
        return;
      }

      EasyLoading.show(status: 'Saving details...');
      try {
        await _vendorController.registerVendor(
          businessName,
          email,
          phoneNumber,
          countryValue,
          cityValue,
          stateValue,
          _taxStatus!,
          taxNumber,
          _image,
        );

        EasyLoading.dismiss();
        EasyLoading.showSuccess('Vendor details saved successfully');

        setState(() {
          _formKey.currentState!.reset();
          _image = null;
          _taxStatus = null;
        });

        // Hiển thị Dialog và điều hướng
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Vendor details saved successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LandingScreen(),
                      ),
                    ); // Điều hướng về LandingScreen
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        EasyLoading.dismiss();
        EasyLoading.showError('Error saving details: $e');
      }
    } else {
      EasyLoading.showError('Please fill all required fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register as Vendor",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.yellow.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Wrap(
                    children: [
                      ListTile(
                        leading: Icon(CupertinoIcons.photo),
                        title: Text("Select from library"),
                        onTap: () {
                          Navigator.pop(context);
                          selectGalleryImage();
                        },
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.camera),
                        title: Text("Take a photo"),
                        onTap: () {
                          Navigator.pop(context);
                          selectCameraImage();
                        },
                      ),
                      if (_image != null)
                        ListTile(
                          leading: Icon(CupertinoIcons.delete),
                          title: Text("Remove photo"),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _image = null;
                            });
                          },
                        ),
                    ],
                  ),
                );
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _image != null ? MemoryImage(_image!) : null,
                child: _image == null
                    ? Icon(
                        CupertinoIcons.camera,
                        size: 40,
                        color: Colors.grey[700],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    label: "Business Name",
                    onChanged: (value) => businessName = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a business name' : null,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: "Email Address",
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => email = value,
                    validator: (value) {
                      if (value!.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: "Phone Number",
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => phoneNumber = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a phone number' : null,
                  ),
                  const SizedBox(height: 20),
                  SelectState(
                    onCountryChanged: (value) {
                      setState(() {
                        countryValue = value;
                      });
                    },
                    onStateChanged: (value) {
                      setState(() {
                        stateValue = value;
                      });
                    },
                    onCityChanged: (value) {
                      setState(() {
                        cityValue = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _taxStatus,
                    decoration: InputDecoration(
                      labelText: "Tax Register?",
                      border: OutlineInputBorder(),
                    ),
                    items: _taxOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _taxStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_taxStatus == 'Yes')
                    _buildTextField(
                      label: "Tax Number",
                      onChanged: (value) => taxNumber = value,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your tax number'
                          : null,
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveVendorDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Save Details",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
