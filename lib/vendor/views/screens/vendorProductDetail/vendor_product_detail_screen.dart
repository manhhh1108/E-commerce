import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorProductDetailScreen extends StatefulWidget {
  final dynamic productData;

  const VendorProductDetailScreen({super.key, required this.productData});

  @override
  State<VendorProductDetailScreen> createState() =>
      _VendorProductDetailScreenState();
}

class _VendorProductDetailScreenState extends State<VendorProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _productNameController;
  late TextEditingController _brandNameController;
  late TextEditingController _quantityController;
  late TextEditingController _productPriceController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;

  List<String> categories = []; // List to store category names

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _productNameController =
        TextEditingController(text: widget.productData['productName']);
    _brandNameController =
        TextEditingController(text: widget.productData['brandName']);
    _quantityController =
        TextEditingController(text: widget.productData['quantity'].toString());
    _productPriceController = TextEditingController(
        text: widget.productData['productPrice'].toString());
    _descriptionController =
        TextEditingController(text: widget.productData['description'] ?? '');

    // Fetch categories from Firestore
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      // Get categories collection from Firestore
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('categories').get();

      // Map the category names to the categories list
      List<String> fetchedCategories = snapshot.docs
          .map((doc) => doc['categoryName'] as String)
          .toList();

      setState(() {
        categories = fetchedCategories;
        // Pre-select the category if it exists in the productData
        if (widget.productData['category'] != null) {
          _selectedCategory = widget.productData['category'];
        }
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _brandNameController.dispose();
    _quantityController.dispose();
    _productPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productData['productId'])  // Dùng productId thay vì id
            .update({
          'productName': _productNameController.text,
          'brandName': _brandNameController.text,
          'quantity': int.parse(_quantityController.text),
          'productPrice': double.parse(_productPriceController.text),
          'description': _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          'category': _selectedCategory,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade900,
        elevation: 0,
        title: Text(
          'Edit Product',
          style: TextStyle(
            fontSize: 25, // Slightly smaller title font size
            fontWeight: FontWeight.bold,
            letterSpacing: 7,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Set the back button to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(fontSize: 18), // Slightly smaller label font size
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Reduced padding
                ),
                style: TextStyle(fontSize: 18), // Slightly smaller input font size
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15), // Reduced space between fields

              // Brand Name
              TextFormField(
                controller: _brandNameController,
                decoration: InputDecoration(
                  labelText: 'Brand Name',
                  labelStyle: TextStyle(fontSize: 18), // Slightly smaller label font size
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Reduced padding
                ),
                style: TextStyle(fontSize: 18), // Slightly smaller input font size
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15), // Reduced space between fields

              // Quantity
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(fontSize: 18), // Slightly smaller label font size
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Reduced padding
                ),
                style: TextStyle(fontSize: 18), // Slightly smaller input font size
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15), // Reduced space between fields

              // Product Price
              TextFormField(
                controller: _productPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Product Price',
                  labelStyle: TextStyle(fontSize: 18), // Slightly smaller label font size
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Reduced padding
                ),
                style: TextStyle(fontSize: 18), // Slightly smaller input font size
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15), // Reduced space between fields

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(fontSize: 18), // Slightly smaller label font size
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Reduced padding
                ),
                style: TextStyle(fontSize: 18), // Slightly smaller input font size
              ),
              SizedBox(height: 15), // Reduced space between fields

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (newCategory) {
                  setState(() {
                    _selectedCategory = newCategory;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(fontSize: 18), // Slightly smaller label font size
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Reduced padding
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15), // Reduced space between fields

              Spacer(), // Push the button to the bottom

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade900,
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 18, // Slightly smaller button text
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set button text color to white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
