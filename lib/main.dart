import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_store/provider/cart_provider.dart';
import 'package:multi_store/provider/location_api.dart';
import 'package:multi_store/provider/product_provider.dart';
import 'package:multi_store/vendor/views/auth/vendor_register_screen.dart';
import 'package:multi_store/vendor/views/screens/landing_screen.dart';
import 'package:multi_store/vendor/views/auth/login.dart';
import 'package:multi_store/vendor/views/screens/main_vendor_screen.dart';
import 'package:multi_store/vendor/views/screens/upload_screen.dart';
import 'package:multi_store/views/buyers/auth/login_screen.dart';
import 'package:multi_store/views/buyers/auth/register_screen.dart';
import 'package:multi_store/views/buyers/inner_screen/edit_profile.dart';
import 'package:multi_store/views/buyers/inner_screen/search_view.dart';
import 'package:multi_store/views/buyers/main_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/cart_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  String publishableKey = dotenv.env['PUBLISHABLE_KEY'] ?? '';
  Stripe.publishableKey = publishableKey;
  await Stripe.instance.applySettings();

  // Firebase initialization
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
        appId: dotenv.env['FIREBASE_APP_ID']!,
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return ProductProvider();
        }), // Cung cấp ProductProvider
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocationApi()),
      ],
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
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      title: 'Multi Store App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Brand-Bold',
      ),
      home: LoginScreen(),
    );
  }
}
