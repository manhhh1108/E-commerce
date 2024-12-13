import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_store/controllers/auth_cotroller.dart';
import 'package:multi_store/utils/show_snackBar.dart';
import 'package:multi_store/views/buyers/auth/login_screen.dart';

import '../../../vendor/views/screens/widgets/button.dart';
import '../../../vendor/views/screens/widgets/text_field.dart';

class BuyerRegisterScreen extends StatefulWidget {
  @override
  State<BuyerRegisterScreen> createState() => _BuyerRegisterScreenState();
}

class _BuyerRegisterScreenState extends State<BuyerRegisterScreen> {
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  Uint8List? _image;
  bool _imageSelected = false;

  // Sign up user method
  _signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        // Create user with Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Handle image
        String imageUrl = '';
        Uint8List imageBytes;

        if (_image != null) {
          imageBytes = _image!;
        } else {
          // Use a default profile image if none selected
          imageBytes = await rootBundle
              .load('assets/images/default_profile.jpg')
              .then((byteData) => byteData.buffer.asUint8List());
        }

        // Upload image to Firebase Storage
        String fileName = '${userCredential.user!.uid}_profile.jpg';
        Reference storageRef =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');
        UploadTask uploadTask = storageRef.putData(imageBytes);

        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();

        // Save user data to Firestore
        String uid = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('buyers').doc(uid).set({
          'fullName': _fullNameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'email': _emailController.text.trim(),
          'buyerId': uid,
          'profileImage': imageUrl,
          'address': 'null',
        });

        setState(() {
          _isLoading = false;
        });

        showSnack(context, 'Account created successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (e.code == 'email-already-in-use') {
          showSnack(context, 'Email is already in use');
        } else {
          showSnack(context, e.message ?? 'An error occurred');
        }
      }
    } else {
      setState(() {
        _isLoading = false;
        if (_image == null) {
          _imageSelected = false;
        }
      });
    }
  }

  // Pick image from gallery
  selectGalleryImage() async {
    Uint8List im = await _authController.pickProfileImage(ImageSource.gallery);
    setState(() {
      _image = im;
      _imageSelected = true;
    });
  }

  // Take a photo from camera
  selectCameraImage() async {
    Uint8List im = await _authController.pickProfileImage(ImageSource.camera);
    setState(() {
      _image = im;
      _imageSelected = true;
    });
  }

  // Show dialog for image selection
  selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(CupertinoIcons.photo),
                title: Text("Select from library"),
                onTap: () async {
                  Navigator.of(context).pop();
                  selectGalleryImage();
                },
              ),
              ListTile(
                leading: Icon(CupertinoIcons.camera),
                title: Text("Take a photo with the camera"),
                onTap: () async {
                  Navigator.of(context).pop();
                  selectCameraImage();
                },
              ),
              if (_image != null)
                ListTile(
                  leading: Icon(CupertinoIcons.trash),
                  title: Text("Delete photo"),
                  onTap: () {
                    setState(() {
                      _image = null;
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create Customer's Account",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.yellow.shade900,
                        backgroundImage: _image != null
                            ? MemoryImage(_image!)
                            : AssetImage('assets/images/default_profile.jpg')
                                as ImageProvider,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          onPressed: () {
                            selectImage();
                          },
                          icon: Icon(
                            CupertinoIcons.photo,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_imageSelected)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Please select a profile image',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  TextFieldInput(
                      icon: Icons.mail_lock_outlined,
                      textEditingController: _emailController,
                      hintText: 'Enter your email',
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Email must not be empty';
                        } else if (!RegExp(
                                r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      textInputType: TextInputType.text),
                  TextFieldInput(
                    icon: Icons.person_2_outlined,
                    textEditingController: _fullNameController,
                    hintText: 'Enter your full name',
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Full name must not be empty';
                      }
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.phone_android_rounded,
                    textEditingController: _phoneNumberController,
                    hintText: 'Enter your phone number',
                    textInputType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone number must not be empty';
                      } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Phone number must be exactly 10 digits';
                      }
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.lock_outline,
                    textEditingController: _passwordController,
                    hintText: 'Enter your password',
                    textInputType: TextInputType.text,
                    isPass: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password must not be empty';
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      } else if (!RegExp(
                              r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)]).{8,}$')
                          .hasMatch(value)) {
                        return 'Password must contain at least one letter, one number, and one special character';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  MyButtons(
                      onTap: () {
                        _signUpUser(); // Trigger sign-up process
                      },
                      text: _isLoading
                          ? 'Registering...'
                          : 'Register' // Button text
                      ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already Have An Account ?',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
