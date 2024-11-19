import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> signUpUsers(String email, String fullName, String phoneNumber,
      String password) async {
    String res = 'Some error occured';
    try {
      if (email.isNotEmpty &&
          fullName.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          password.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        await _firestore.collection('buyers').doc(cred.user!.uid).set({
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'password': password,
          'buyerId': cred.user!.uid,
          'address': '',
        });
      } else {
        res = 'Please fields must not be empty';
      }
    } catch (e) {}
    return res;
  }

  Future<String> loginUsers(String email, String password) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Đăng nhập với Firebase Authentication
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'success'; // Đăng nhập thành công
      } else {
        res = 'Fields must not be empty';
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi phổ biến
      if (e.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        res = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        res = 'The email address is badly formatted.';
      } else {
        res = e.message ?? 'Authentication failed';
      }
    } catch (e) {
      res = 'An error occurred: ${e.toString()}';
    }
    return res;
  }

}
