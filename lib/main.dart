import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_store/provider/cart_provider.dart';
import 'package:multi_store/provider/location_api.dart';
import 'package:multi_store/provider/product_provider.dart';
import 'package:multi_store/vendor/views/auth/vendor_auth_screen.dart';
import 'package:multi_store/vendor/views/auth/vendor_register_screen.dart';
import 'package:multi_store/vendor/views/screens/landing_screen.dart';
import 'package:multi_store/vendor/views/screens/main_vendor_screen.dart';
import 'package:multi_store/vendor/views/screens/upload_screen.dart';
import 'package:multi_store/views/buyers/auth/login_screen.dart';
import 'package:multi_store/views/buyers/auth/register_screen.dart';
import 'package:multi_store/views/buyers/inner_screen/edit_profile.dart';
import 'package:multi_store/views/buyers/inner_screen/search_view.dart';
import 'package:multi_store/views/buyers/main_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/cart_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization for Android and iOS
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyC7SZ7DqmK4LyrqNAAvV--NxgnRADUDs2U",
        appId: "1:35588038182:android:6abf54cc5ed824137210e7",
        messagingSenderId: "35588038182",
        projectId: "multi-store-e24b6",
        storageBucket: "gs://multi-store-e24b6.firebasestorage.app",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {return ProductProvider();}), // Cung cấp ProductProvider
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocationApi()),],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi Store App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Brand-Bold',
      ),
      home: SignInScreen(),
    );
  }
}
