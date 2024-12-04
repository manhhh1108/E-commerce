import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_store/models/cart_attributes.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartAttr> _cartItems = {};

  Map<String, CartAttr> get getCartItem {
    return _cartItems;
  }

  // Thêm sản phẩm vào giỏ
  void addProductToCart(
      String productName,
      String productId,
      List imageUrl,
      int quantity,
      int productQuantity,
      double price,
      String vendorId,
      String productSize,
      Timestamp scheduleDate) {
    String productKey = productId + productSize;
    if (_cartItems.containsKey(productId)) {
      // Nếu sản phẩm đã có trong giỏ, cập nhật quantity
      _cartItems.update(
        productKey,
        (existingCart) => CartAttr(
          productName: existingCart.productName,
          productId: existingCart.productId,
          imageUrl: existingCart.imageUrl,
          quantity: existingCart.quantity + quantity,
          productQuantity: existingCart.productQuantity,
          price: existingCart.price,
          vendorId: existingCart.vendorId,
          productSize: existingCart.productSize,
          scheduleDate: existingCart.scheduleDate,
        ),
      );
    } else {
      // Nếu sản phẩm chưa có trong giỏ, thêm mới
      _cartItems.putIfAbsent(
        productKey,
        () => CartAttr(
          productName: productName,
          productId: productId,
          imageUrl: imageUrl,
          quantity: quantity,
          productQuantity: productQuantity,
          price: price,
          vendorId: vendorId,
          productSize: productSize,
          scheduleDate: scheduleDate,
        ),
      );
    }
    notifyListeners();
  }

  // Xóa sản phẩm khỏi giỏ
  void removeProductFromCart(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  // Cập nhật số lượng sản phẩm
  void updateQuantity(String productId, int quantity) {
    if (_cartItems.containsKey(productId)) {
      if (quantity <= 0) {
        removeProductFromCart(productId); // Nếu số lượng <= 0, xóa sản phẩm
      } else {
        _cartItems.update(
          productId,
          (existingCart) => CartAttr(
            productName: existingCart.productName,
            productId: existingCart.productId,
            imageUrl: existingCart.imageUrl,
            quantity: quantity,
            productQuantity: existingCart.productQuantity,
            price: existingCart.price,
            vendorId: existingCart.vendorId,
            productSize: existingCart.productSize,
            scheduleDate: existingCart.scheduleDate,
          ),
        );
        notifyListeners();
      }
    }
  }

  // Tính tổng giá trị giỏ hàng
  double get totalPrice {
    double total = 0;
    _cartItems.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  // Xóa tất cả sản phẩm trong giỏ
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void increament(CartAttr cartAttr) {
    cartAttr.increase();
    notifyListeners();
  }

  void decreament(CartAttr cartAttr) {
    cartAttr.decrease();
    notifyListeners();
  }
}
