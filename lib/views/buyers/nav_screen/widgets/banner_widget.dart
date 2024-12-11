import 'dart:async'; // Thêm thư viện để sử dụng Timer
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerWidget extends StatefulWidget {
  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List _bannerImage = [];
  PageController _pageController = PageController();
  int _currentPage = 0;

  getBanners() {
    return _firestore.collection('banners').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc['image'] != null &&
            Uri.tryParse(doc['image'])?.hasAbsolutePath == true) {
          setState(() {
            _bannerImage.add(doc['image']);
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getBanners();

    // Timer tự động lướt các banner mỗi 2 giây
    Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (_bannerImage.isNotEmpty) {
        _currentPage = (_currentPage + 1) % _bannerImage.length;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.yellow.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _bannerImage.isEmpty
            ? Shimmer(
          duration: Duration(seconds: 2),
          interval: Duration(seconds: 1),
          color: Colors.grey.shade400,
          colorOpacity: 0.3,
          direction: ShimmerDirection.fromLeftToRight(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 140,
            width: double.infinity,
          ),
        )
            : PageView.builder(
          controller: _pageController, // Điều khiển page view
          itemCount: _bannerImage.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: _bannerImage[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer(
                  duration: Duration(seconds: 4),
                  interval: Duration(seconds: 1),
                  color: Colors.grey.shade400,
                  colorOpacity: 0.3,
                  direction: ShimmerDirection.fromLeftToRight(),
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error),
              ),
            );
          },
        ),
      ),
    );
  }
}
