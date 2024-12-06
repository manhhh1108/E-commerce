import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store/provider/product_provider.dart';
import 'package:provider/provider.dart';

import '../../auth/login.dart';

class AttributesScreen extends StatefulWidget {
  @override
  State<AttributesScreen> createState() => _AttributesScreenState();
}

class _AttributesScreenState extends State<AttributesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _sizeController = TextEditingController();
  bool _entered = false;
  List<String> _sizeList = [];
  late String brandName;
  bool _isSave = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final ProductProvider _productProvider = Provider.of<ProductProvider>(context);

    // Kiểm tra người dùng đã đăng nhập chưa
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Nếu người dùng chưa đăng nhập, hiển thị nút Login
      return Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginVendorScreen()), // Điều hướng tới LoginVendorScreen
            );
          },
          child: Text('Login to Continue', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          // Brand Name Input
          TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return 'Enter Brand Name';
              } else {
                return null;
              }
            },
            onChanged: (value) {
              _productProvider.getFormData(brandName: value);
            },
            decoration: InputDecoration(
              labelText: "Brand",
            ),
          ),
          SizedBox(height: 10),

          // Size Input and Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Container(
                  width: 100,
                  child: TextFormField(
                    controller: _sizeController,
                    onChanged: (value) {
                      setState(() {
                        _entered = value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Size",
                    ),
                  ),
                ),
              ),
              _entered
                  ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade900,
                ),
                onPressed: () {
                  setState(() {
                    _sizeList.add(_sizeController.text);
                    _sizeController.clear();
                    _entered = false; // Reset input state after adding
                  });
                },
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : SizedBox.shrink(), // Avoid rendering extra widgets if not entered
            ],
          ),

          // Display Size List
          if (_sizeList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sizeList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _sizeList.removeAt(index);
                            _productProvider.getFormData(sizeList: _sizeList);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade900,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _sizeList[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Save Button
          if (_sizeList.isNotEmpty)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade900,
              ),
              onPressed: () {
                _productProvider.getFormData(sizeList: _sizeList);
                setState(() {
                  _isSave = true;
                });
              },
              child: Text(
                _isSave ? 'Saved' : 'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
