import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_store/views/buyers/nav_screen/widgets/banner_widget.dart';
import 'package:multi_store/views/buyers/nav_screen/widgets/category_text.dart';
import 'package:multi_store/views/buyers/nav_screen/widgets/search_input_widget.dart';
import 'package:multi_store/views/buyers/nav_screen/widgets/welcome_text_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WelcomeText(),
        SizedBox(
          height: 14,
        ),
        SearchInputWidget(),
        BannerWidget(),
        CategoryText(),
      ],
    );
  }
}




