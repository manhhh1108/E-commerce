import 'package:flutter/material.dart';
import 'package:multi_store/controllers/auth_cotroller.dart';
import 'package:multi_store/utils/show_snackBar.dart';
import 'package:multi_store/vendor/views/forget_password/forgot_password.dart';
import 'package:multi_store/views/buyers/auth/register_screen.dart';
import 'package:multi_store/views/buyers/main_screen.dart';
import 'package:multi_store/vendor/views/auth/login.dart';
import '../../../vendor/views/screens/widgets/button.dart';
import '../../../vendor/views/screens/widgets/text_field.dart'; // Widget TextFieldInput

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  // TextEditingController cho email và password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Hàm đăng nhập người dùng
  Future<void> _loginUser() async {
    // Hiển thị trạng thái loading
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      // Lấy giá trị từ các TextEditingController
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      print("Email: $email, Password: $password");

      String res = await _authController.loginUsers(email, password);

      // Xử lý kết quả đăng nhập
      setState(() {
        _isLoading = false;
      });

      if (res == 'success') {
        // Chuyển hướng đến màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        // Hiển thị lỗi nếu không thành công
        showSnack(context, res);
      }
    } else {
      // Nếu form không hợp lệ
      setState(() {
        _isLoading = false;
      });
      showSnack(context, 'Please fill in all fields');
    }
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Multi Store",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Nhập email
                TextFieldInput(
                  icon: Icons.person,
                  textInputType: TextInputType.emailAddress,
                  hintText: 'Enter your email',
                  textEditingController: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please email must not be empty';
                    }
                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                // Nhập mật khẩu
                TextFieldInput(
                  icon: Icons.lock,
                  textInputType: TextInputType.text,
                  hintText: 'Enter your password',
                  textEditingController: _passwordController,
                  isPass: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please password must not be empty';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                ForgotPassword(),
                // Nút đăng nhập
                InkWell(
                  onTap: _loginUser,
                  child: MyButtons(
                    onTap: _loginUser,
                    text: _isLoading ? 'Logging in...' : 'Login',
                  ),
                ),
                SizedBox(height: 15),
                // Đăng ký tài khoản
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyerRegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                // Chế độ Guest
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue as Guest",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Guest View",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                // Login cho Vendor
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vendor Login",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginVendorScreen(), // Thay bằng màn hình login Vendor của bạn
                          ),
                        );
                      },
                      child: Text(
                        "Login as Vendor",
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
    );
  }
}
