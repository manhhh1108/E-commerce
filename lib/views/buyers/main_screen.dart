import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_store/views/buyers/nav_screen/account_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/cart_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/categories_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/home_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/search_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/store_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;
  List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    AccountScreen(),
    StoreScreen(),
    CartScreen(),
    CategoriesScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _pageIndex,
          onTap: (value){
            setState(() {
              _pageIndex = value;
            });
          },
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.yellow.shade900,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/cart.svg'),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/shop.svg'),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/explore.svg'),
              label: 'Categories',
            ),
          ]),
      body: _pages[_pageIndex],
    );
  }
}
