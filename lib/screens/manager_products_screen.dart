import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/widgets/main_drawer.dart';
import 'package:my_shop/widgets/manager_product_item.dart';
import 'package:provider/provider.dart';

class ManagerProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: const Text('Your Products'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, EditProductScreen.routeName);
              },
            ),
          ],
        ),
        body: FutureBuilder(
            future: _refreshProducts(context),
            builder: (ctx, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      displacement: 5,
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<Products>(
                        builder: (ctx, products, _) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: products.items.length,
                            itemBuilder: (ctx, i) => Column(
                              children: <Widget>[
                                ManagerProductItem(
                                  id: products.items[i].id,
                                  title: products.items[i].title,
                                  imageUrl: products.items[i].imageUrl,
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
            }),
      );
}
