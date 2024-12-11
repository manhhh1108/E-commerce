import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/views/buyers/inner_screen/all_product_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productStream =
    FirebaseFirestore.instance.collection('categories').snapshots();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.yellow.shade900,
        title: Text(
          'Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center, // Căn giữa chữ
        ),
        centerTitle: true,  // Đảm bảo tiêu đề luôn được căn giữa
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.yellow.shade900,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cột
                crossAxisSpacing: 15.0, // Khoảng cách giữa các cột
                mainAxisSpacing: 15.0, // Khoảng cách giữa các hàng
                childAspectRatio: 0.8, // Tỷ lệ chiều rộng/chiều cao của mỗi mục
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final categoryData = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return AllProductScreen(categoryData: categoryData);
                    }));
                  },
                  child: Card(
                    elevation: 5.0, // Tạo độ bóng nhẹ cho các thẻ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Bo góc thẻ
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Column(
                        children: [
                          // Hình ảnh danh mục
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    categoryData['image'] ?? '', // Kiểm tra nếu không có ảnh
                                  ),
                                  fit: BoxFit.cover, // Làm ảnh phủ toàn bộ thẻ
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: categoryData['image'] == null || categoryData['image'] == ''
                                  ? Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ) // Placeholder icon if image is missing
                                  : SizedBox.shrink(),
                            ),
                          ),
                          // Tên danh mục
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5), // Nền mờ cho tên
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: Text(
                              categoryData['categoryName'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
