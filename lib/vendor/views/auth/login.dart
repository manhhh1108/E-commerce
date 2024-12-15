import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/vendor/views/screens/landing_screen.dart';
import 'package:multi_store/views/buyers/auth/login_screen.dart'; // Import màn hình đăng nhập khách
import '../../../utils/show_snackBar.dart';
import '../../controllers/authentication.dart';
import 'vendor_register_screen.dart';
import '../forget_password/forgot_password.dart';
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

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethod().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == "success") {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(user.uid)
            .get();

        bool isApproved = vendorDoc.exists && (vendorDoc['approved'] ?? false);

        setState(() {
          isLoading = false;
        });

        if (isApproved) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LandingScreen(),
            ),
          );
        } else {
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
      showSnack(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
              hintText: 'Enter your password',
              textInputType: TextInputType.text,
              isPass: true,
            ),
            ForgotPassword(),
            MyButtons(
              onTap: loginUser,
              text: isLoading ? 'Logging in...' : 'Login',
            ),
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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(), // Màn hình đăng nhập khách
                        ),
                      );
                    },
                    child: Text(
                      "Login as Customer",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
}
