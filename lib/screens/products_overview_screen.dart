import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/cart_screen.dart';

import 'package:my_shop/widgets/little_badge.dart';
import 'package:my_shop/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';

enum PopupMenuOptions {
  AllItems,
  Favorites,
}

class ProductsOverViewScreen extends StatefulWidget {
  @override
  _ProductsOverViewScreenState createState() => _ProductsOverViewScreenState();
}

class _ProductsOverViewScreenState extends State<ProductsOverViewScreen> {
  bool _showFavoritesOnly = false;
  // bool isLoading = true;
  //@override
  // void initState() {
  //   Future.delayed(Duration.zero).then((_) {
  //     Provider.of<Products>(context)
  //         .fetchAndSetProducts()
  //         .then((_) {})
  //         .catchError((error) {})
  //         .then((_) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     });

  //     isLoading = false;
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<Cart>(context, listen: false);
    // final productsData = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (PopupMenuOptions selectedValue) {
              setState(() {
                if (selectedValue == PopupMenuOptions.Favorites)
                  _showFavoritesOnly = true;
                else if (selectedValue == PopupMenuOptions.AllItems)
                  _showFavoritesOnly = false;
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Show All'), value: PopupMenuOptions.AllItems),
              PopupMenuItem(
                  child: Text('Favorites'), value: PopupMenuOptions.Favorites),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, consumerChild) => LittleBadge(
              value: (cartItems.items.length).toString(),
              child: consumerChild,
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.pushNamed(context, CartScreen.routeName),
            ),
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Products>(context, listen: false).fetchAndSetProducts(),
        builder: (ctx2, snapData) {
          if (snapData.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else
            return ProductsGrid(_showFavoritesOnly);
        },
      ),
    );
  }
}
