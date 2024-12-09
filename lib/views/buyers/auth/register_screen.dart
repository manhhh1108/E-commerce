import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_store/controllers/auth_cotroller.dart';
import 'package:multi_store/utils/show_snackBar.dart';
import 'package:multi_store/views/buyers/auth/login_screen.dart';

class BuyerRegisterScreen extends StatefulWidget {
  @override
  State<BuyerRegisterScreen> createState() => _BuyerRegisterScreenState();
}

class _BuyerRegisterScreenState extends State<BuyerRegisterScreen> {
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String email;
  late String fullName;
  late String phoneNumber;
  late String password;

  bool _isLoading = false;
  Uint8List? _image;

  _signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        // Đăng ký người dùng với Firebase Authentication
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String imageUrl = '';
        if (_image != null) {
          // Tải ảnh lên Firebase Storage
          String fileName = '${userCredential.user!.uid}_profile.jpg';
          Reference storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
          UploadTask uploadTask = storageRef.putData(_image!);

          TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          // Sử dụng ảnh mặc định
          imageUrl = 'assets/images/default_profile.png';
        }

        // Lưu thông tin người dùng vào Firestore
        String uid = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('buyers').doc(uid).set({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'buyerId': uid,
          'profileImage': imageUrl,
          'address': '',
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
      });
      showSnack(context, 'Please fill in all fields');
    }
  }

  selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(CupertinoIcons.photo),
                title: const Text("Select from library"),
                onTap: () async {
                  Navigator.of(context).pop();
                  selectGalleryImage();
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.camera),
                title: const Text("Take a photo with the camera"),
                onTap: () async {
                  Navigator.of(context).pop();
                  selectCameraImage();
                },
              ),
              if (_image != null)
                ListTile(
                  leading: const Icon(CupertinoIcons.trash),
                  title: const Text("Delete photo"),
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

  selectGalleryImage() async {
    Uint8List im = await _authController.pickProfileImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  selectCameraImage() async {
    Uint8List im = await _authController.pickProfileImage(ImageSource.camera);
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Create Customer's Account",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.yellow.shade900,
                      backgroundImage: _image != null
                          ? MemoryImage(_image!)
                          : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: () {
                          selectImage();
                        },
                        icon: const Icon(
                          CupertinoIcons.photo,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email must not be empty';
                      } else if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: const InputDecoration(labelText: 'Enter Email'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Full name must not be empty';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      fullName = value;
                    },
                    decoration:
                    const InputDecoration(labelText: 'Enter Full Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone number must not be empty';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      phoneNumber = value;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Enter Phone Number'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password must not be empty';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      password = value;
                    },
                    decoration:
                    const InputDecoration(labelText: 'Enter Password'),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    _signUpUser();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already Have An Account?'),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return LoginScreen();
                            }),
                          );
                        },
                        child: const Text('Login')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
