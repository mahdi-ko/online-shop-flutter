import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_shop/models/http_exception.dart';
import 'package:my_shop/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // bool _showFavoriteOnly = false;

  List<Product> get items {
    // if (_showFavoriteOnly)
    //   return [..._items.where((product) => product.isFavorite)];
    // else
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }
  // void toggleShowFavoriteOnly(bool newVal) {
  //   _showFavoriteOnly = newVal;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((product) => id == product.id);
  }

  void notify() {
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    const url =
        "https://flutter-shop-54c5d-default-rtdb.firebaseio.com/products.json";

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageURL': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
          }));

      if (response.statusCode >= 400) throw Exception("error");

      _items.add(Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProducts() async {
    const url =
        "https://flutter-shop-54c5d-default-rtdb.firebaseio.com/products.json";
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.insert(
            0,
            Product(
                id: prodId,
                title: prodData['title'],
                description: prodData['description'],
                price: prodData['price'],
                imageUrl: prodData['imageURL'],
                isFavorite: prodData['isFavorite']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final url =
        "https://flutter-shop-54c5d-default-rtdb.firebaseio.com/products/${updatedProduct.id}.json";
    try {
      final response = await http.patch(url,
          body: json.encode({
            'title': updatedProduct.title,
            'description': updatedProduct.description,
            'imageURL': updatedProduct.imageUrl,
            'isFavorite': updatedProduct.isFavorite,
            'price': updatedProduct.price,
          }));
      if (response.statusCode >= 400) throw Exception('dead');
      final prodIndex =
          _items.indexWhere((oldProd) => oldProd.id == updatedProduct.id);
      _items[prodIndex] = updatedProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://flutter-shop-54c5d-default-rtdb.firebaseio.com/products/$id.json";
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url).catchError((_) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    });

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
