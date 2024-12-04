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
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0), // Khoảng cách giữa các chip
                            child: ActionChip(
                              backgroundColor: Colors.orange, // Màu nền của chip
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // Viền bo tròn
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = categoryData['categoryName'];
                                });
                                print(_selectedCategory);
                              },
                              label: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0), // Thêm padding nội bộ
                                constraints: BoxConstraints(
                                  minWidth: 40, // Đảm bảo chiều rộng tối thiểu
                                  minHeight: 40, // Đảm bảo chiều cao tối thiểu đồng nhất
                                ),
                                alignment: Alignment.center, // Căn giữa cả chiều ngang và dọc
                                child: Text(
                                  categoryData['categoryName'],
                                  textAlign: TextAlign.center, // Căn giữa văn bản
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return CategoriesScreen();

                        }));
                      },
                      icon: Icon(Icons.arrow_forward_ios),
                    )
                  ],
                ),
              );
            },
          ),
          if(_selectedCategory == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MainProductWidget(),
            ),
          if(_selectedCategory != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HomeProductsWidget(categoryName: _selectedCategory!),
            ),
        ],
      ),
    );
  }
}
