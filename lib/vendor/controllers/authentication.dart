import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SignUp User

  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error Occurred";

    // Define a regex for password validation
    final passwordRegEx =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        res = "Please fill out all fields";
      } else if (!passwordRegEx.hasMatch(password)) {
        res =
            "Password must be at least 8 characters long and include at least one letter, one number, and one special character.";
      } else {
        // Register user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Add user to your Firestore database
        await _firestore.collection("vendors").doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'approved': false,
        });

        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  // logIn user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  signOut() async {
    // await _auth.signOut();
  }
}
