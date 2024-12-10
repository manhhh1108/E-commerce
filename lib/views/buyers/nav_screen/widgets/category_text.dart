import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/views/buyers/nav_screen/categories_screen.dart';
import 'package:multi_store/views/buyers/nav_screen/widgets/home_products.dart';
import 'package:multi_store/views/buyers/nav_screen/widgets/main_product_widget.dart';

class CategoryText extends StatefulWidget {
  @override
  State<CategoryText> createState() => _CategoryTextState();
}

class _CategoryTextState extends State<CategoryText> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _categoryStream =
    FirebaseFirestore.instance.collection('categories').snapshots();

    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(fontSize: 19),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _categoryStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Loading Categories..."),
                );
              }

              return Container(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final categoryData = snapshot.data!.docs[index];
                          final isSelected =
                              categoryData['categoryName'] == _selectedCategory;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ActionChip(
                              backgroundColor: isSelected
                                  ? Colors.black
                                  : Colors.orange, // Đổi màu nếu được chọn
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isSelected) {
                                    // Nếu đang chọn, nhấn lại để bỏ chọn
                                    _selectedCategory = null;
                                  } else {
                                    // Chọn danh mục mới
                                    _selectedCategory =
                                    categoryData['categoryName'];
                                  }
                                });
                              },
                              label: Container(
                                alignment: Alignment.center,
                                width: 50, // Đặt chiều rộng cố định
                                height: 20, // Đặt chiều cao cố định
                                child: Text(
                                  categoryData['categoryName'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1, // Đảm bảo chỉ hiển thị 1 dòng
                                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return CategoriesScreen();
                            }));
                      },
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_selectedCategory == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MainProductWidget(),
            ),
          if (_selectedCategory != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HomeProductsWidget(categoryName: _selectedCategory!),
            ),
        ],
      ),
    );
  }
}
