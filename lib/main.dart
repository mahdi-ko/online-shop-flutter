import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/order.dart';
import 'package:my_shop/screens/auth_screen.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/screens/manager_products_screen.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:my_shop/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:my_shop/providers/products.dart';

import 'screens/products_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, auth, previousProducts) => previousProducts
            ..setAuth(
                auth.token, auth.userId, previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, auth, previousOrders) => previousOrders
            ..setAuth(
                auth.token, auth.userId, previousOrders == null ? [] : previousOrders.allOrders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authentication, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.green,
            accentColor: Colors.red,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Lato',
          ),
          home: authentication.isAuth
              ? ProductsOverViewScreen()
              : FutureBuilder(
                  future: authentication.tryAutoLogIn(),
                  builder: (ctx, snapShot) => snapShot.connectionState == ConnectionState.waiting
                      ? SplashScreen()
                      : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            ManagerProductsScreen.routeName: (ctx) => ManagerProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
