import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_store/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ImagesTabScreen extends StatefulWidget {
  @override
  State<ImagesTabScreen> createState() => _ImagesTabScreenState();
}

class _ImagesTabScreenState extends State<ImagesTabScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ImagePicker picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<File> _image = [];
  List<String> _imageUrlList = [];

  // Chọn hoặc thay thế ảnh
  Future<void> chooseImage({int? replaceIndex}) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      print('No Image Picked');
    } else {
      setState(() {
        if (replaceIndex != null) {
          // Thay thế ảnh tại vị trí chỉ định
          _image[replaceIndex] = File(pickedFile.path);
        } else {
          // Thêm ảnh mới
          _image.add(File(pickedFile.path));
        }
      });
    }
  }

  // Xóa ảnh khỏi danh sách
  void removeImage(int index) {
    setState(() {
      _image.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ProductProvider _productProvider =
        Provider.of<ProductProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Product Images',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 15),

          // Hiển thị ảnh trong lưới
          GridView.builder(
            shrinkWrap: true,
            itemCount: _image.length + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8, // Điều chỉnh tỷ lệ khung hình
            ),
            itemBuilder: (context, index) {
              return index == 0
                  ? GestureDetector(
                      onTap: chooseImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 50,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Hiển thị ảnh
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _image[index - 1],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),

                        // Nút chỉ có biểu tượng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                chooseImage(replaceIndex: index - 1);
                              },
                              icon: Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              onPressed: () {
                                removeImage(index - 1);
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ],
                    );
            },
          ),

          SizedBox(height: 20),

          // Nút upload ảnh
          if (_image.isNotEmpty)
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  EasyLoading.show(status: 'Saving Images ...');
                  _imageUrlList
                      .clear(); // Đảm bảo danh sách trống trước khi thêm
                  for (var img in _image) {
                    Reference ref =
                        _storage.ref().child('productImage').child(Uuid().v4());
                    await ref.putFile(img).whenComplete(() async {
                      await ref.getDownloadURL().then((value) {
                        setState(() {
                          _imageUrlList.add(value);
                        });
                      });
                    });
                  }
                  // Lưu URL ảnh vào ProductProvider
                  _productProvider.getFormData(imageUrlList: _imageUrlList);
                  EasyLoading.dismiss();
                  EasyLoading.showSuccess('Images uploaded successfully');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade900,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
