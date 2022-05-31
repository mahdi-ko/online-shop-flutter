import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';

import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final productId = arguments['id'];
    final Function addProduct = arguments['addProduct'];

    final productProvider = arguments['productProvider'];
    final product = Provider.of<Products>(context, listen: false).findById(productId);
    final cartProvider = Provider.of<Cart>(context, listen: false);

    final double width = MediaQuery.of(context).size.width;

    Widget imageBuilder() {
      return Container(
        height: 300,
        width: isPortrait ? double.infinity : width / 2,
        child: Hero(
          tag: product.id,
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    List<Widget> priceAndDescriptionBuilder() {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Theme.of(context).accentColor,
            elevation: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              width: isPortrait ? double.infinity : (width - 50) / 2,
              child: Center(
                child: Text(
                  'Price: \$${product.price}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 70),
          width: isPortrait ? double.infinity : MediaQuery.of(context).size.width / 2,
          child: Text(
            product.description,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.justify,
          ),
        ),
      ];
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(product.title),
      // ),
      body: isPortrait
          ? CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  stretch: true,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(product.title),
                    background: imageBuilder(),
                  ),
                  expandedHeight: 300,
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      children: <Widget>[
                        ...priceAndDescriptionBuilder(),
                        SizedBox(
                          height: 500,
                        ),
                      ],
                    )
                  ]),
                ),
              ],
            )
          : Row(
              children: <Widget>[
                imageBuilder(),
                SingleChildScrollView(
                  child: Column(
                    children: priceAndDescriptionBuilder(),
                  ),
                ),
              ],
            ),
      floatingActionButton: Builder(
        builder: (ctx) => FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            addProduct(
              cartProvider: cartProvider,
              productProvider: productProvider,
            );
            ScaffoldMessenger.of(ctx).removeCurrentSnackBar();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                duration: Duration(
                  seconds: 2,
                ),
                content: Row(
                  children: <Widget>[
                    Icon(Icons.shopping_cart),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Item is added to the cart!',
                    ),
                  ],
                ),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cartProvider.removeLastItem(productProvider.id);
                  },
                ),
              ),
            );
          },
          child: Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
