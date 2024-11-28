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
    getBanners();
    super.initState();
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
          duration: Duration(seconds: 2), // Set the duration of shimmer effect
          interval: Duration(seconds: 1), // Set the interval of shimmer
          color: Colors.grey.shade400, // Set the shimmer color
          colorOpacity: 0.3, // Set shimmer opacity
          direction: ShimmerDirection.fromLeftToRight(), // Direction of shimmer
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
          itemCount: _bannerImage.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: _bannerImage[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer(
                  duration: Duration(seconds: 2),
                  interval: Duration(seconds: 1),
                  color: Colors.grey.shade400,
                  colorOpacity: 0.3,
                  direction: ShimmerDirection.fromLeftToRight(),
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            );
          },
        ),
      ),
    );
  }
}
