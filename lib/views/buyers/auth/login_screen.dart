import 'package:flutter/material.dart';
import 'package:multi_store/controllers/auth_cotroller.dart';
import 'package:multi_store/utils/show_snackBar.dart';
import 'package:multi_store/views/buyers/auth/register_screen.dart';
import 'package:multi_store/views/buyers/main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  late String email;

  late String password;

  bool _isLoading = false;

  _loginUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      print("Email: $email, Password: $password");

      String res = await _authController.loginUsers(email, password);

      setState(() {
        _isLoading = false; // Đặt về false sau khi đăng nhập thành công hoặc thất bại
      });

      if (res == 'success') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return MainScreen();
            }));
      } else {
        showSnack(context, res);
      }
    } else {
      setState(() {
        _isLoading = false; // Đặt về false nếu dữ liệu không hợp lệ
      });
      showSnack(context, 'Please fill in all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login Customer's Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please email must not be empty';
                    } else {
                      return null;
                    }
                  },
                  onChanged: ((value) {
                    email = value;
                  }),
                  decoration: InputDecoration(labelText: 'Enter Email Address'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextFormField(
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please password must not be empty ';
                    } else {
                      return null;
                    }
                  },
                  onChanged: ((value) {
                    password = value;
                  }),
                  decoration: InputDecoration(labelText: 'Password'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  _loginUser();
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
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Login',
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
                  Text("Need An Account ?"),
                  TextButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return BuyerRegisterScreen();
                      }),
                    );
                  }, child: Text("Register"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
