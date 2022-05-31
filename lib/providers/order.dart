import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class Order {
  final String id;
  final double amount;
  final List<CartItem> cartItems;
  final DateTime dateTime;

  Order(
      {@required this.id,
      @required this.amount,
      @required this.cartItems,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  String authToken;
  List<Order> _orders = [];
  String userId;

  void setAuth(String authToken, String userId, List<Order> oldOrders) {
    this.authToken = authToken;
    this.userId = userId;
    _orders = oldOrders;
  }

  List<Order> get allOrders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://flutter-shop-54c5d-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    final response = await http.get(url);
    final List<Order> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    //print(json.decode(response.body));
    if (extractedData == null) return;
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(Order(
          id: orderId,
          amount: orderData['amount'],
          cartItems: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  title: item["title"],
                  quantity: item['quantity'],
                  price: item['price']))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime'])));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        "https://flutter-shop-54c5d-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        Order(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timestamp,
          cartItems: cartProducts,
        ));
    notifyListeners();
  }

  void clearOrders() {}
}
