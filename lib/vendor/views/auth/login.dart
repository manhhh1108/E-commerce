import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/vendor/views/screens/landing_screen.dart';
import '../../../utils/show_snackBar.dart';
import '../../controllers/authentication.dart';
import 'vendor_register_screen.dart';
import '../forget_password/forgot_password.dart';
import '../phoneAuth/phone_login.dart';
import 'signup.dart';
import '../screens/widgets/button.dart';
import '../screens/widgets/text_field.dart';

class LoginVendorScreen extends StatefulWidget {
  const LoginVendorScreen({super.key});

  @override
  State<LoginVendorScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<LoginVendorScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

// email and passowrd auth part
  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    // Đăng nhập người dùng
    String res = await AuthMethod().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == "success") {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Kiểm tra trạng thái 'approved' trong Firestore
        DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(user.uid)
            .get();

        bool isApproved = vendorDoc.exists && (vendorDoc['approved'] ?? false);

        setState(() {
          isLoading = false;
        });

        if (isApproved) {
          // Nếu đã được phê duyệt, điều hướng đến LandingScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LandingScreen(),
            ),
          );
        } else {
          // Nếu chưa được phê duyệt, điều hướng đến VendorRegisterScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VendorRegisterScreen(),
            ),
          );
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      // Hiển thị lỗi nếu đăng nhập thất bại
      showSnack(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height / 2.7,
              child: Image.asset('assets/images/login.jpg'),
            ),
            TextFieldInput(
                icon: Icons.person,
                textEditingController: emailController,
                hintText: 'Enter your email',
                textInputType: TextInputType.text),
            TextFieldInput(
              icon: Icons.lock,
              textEditingController: passwordController,
              hintText: 'Enter your passord',
              textInputType: TextInputType.text,
              isPass: true,
            ),
            //  we call our forgot password below the login in button
            ForgotPassword(),
            MyButtons(onTap: loginUser, text: "Log In"),
            Row(
              children: [
                Expanded(
                  child: Container(height: 1, color: Colors.black26),
                ),
                Text("  or  "),
                Expanded(
                  child: Container(height: 1, color: Colors.black26),
                )
              ],
            ),
            // for phone authentication
            // PhoneAuthentication(),
            // Don't have an account? got to signup screen
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Căn giữa
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SignupVendorScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "SignUp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue, // Thêm màu nếu cần
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Container socialIcon(image) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black45,
          width: 2,
        ),
      ),
      child: Image.network(
        image,
        height: 40,
      ),
    );
  }
}
