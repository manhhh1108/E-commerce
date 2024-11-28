import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  _uploadProfileImageToStorage(Uint8List? image) async {
    Reference ref =
        _storage.ref().child('profilePics').child(_auth.currentUser!.uid);
    ref.putData(image!);
    UploadTask uploadTask = ref.putData(image!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  pickProfileImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);

    if (_file != null) {
      return await _file.readAsBytes();
    } else {
      print('No Image Selected');
    }
  }

  Future<String> signUpUsers(String email, String fullName, String phoneNumber,
      String password, Uint8List? image) async {
    String res = 'Some error occured';
    try {
      if (email.isNotEmpty &&
          fullName.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String profileImageUrl = await _uploadProfileImageToStorage(image);

        await _firestore.collection('buyers').doc(cred.user!.uid).set({
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'password': password,
          'buyerId': cred.user!.uid,
          'address': '',
          'profileImage': profileImageUrl,
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
      if (email.isEmpty || password.isEmpty) {
        // Nếu một trong hai trường rỗng, trả về thông báo lỗi
        res = 'Please fill in both email and password fields.';
      } else {
        // Nếu cả hai trường đều không rỗng, tiến hành đăng nhập
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'success';
      }
    } on FirebaseAuthException catch
    (e) {
    // Xử lý các lỗi phổ biến
    // ... (các trường hợp lỗi khác như trước)
    } catch (e) {
    res = 'An error occurred: ${e.toString()}';
    }
    return res;
  }
}
