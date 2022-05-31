import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  final bool favoriteScreen;

  const ProductItem(this.favoriteScreen);
  void addToCart({@required cartProvider, @required productProvider}) {
    cartProvider.addCartItem(
      productProvider.id,
      productProvider.price,
      productProvider.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final productsData = Provider.of<Products>(context, listen: false);
    final cartProvider = Provider.of<Cart>(context, listen: false);
    final authProvider = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: {'id': product.id, 'addProduct': addToCart, "productProvider": product});
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage.assetNetwork(
              placeholder: 'images/loading.gif',
              image: product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              onPressed: () async {
                await product.toggleFavorite(authProvider.token, authProvider.userId);
                //notify is used to update the UI inside the favorites screen only
                if (favoriteScreen) productsData.notify();
              },
              icon: product.isFavorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
              color: Theme.of(context).accentColor,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              addToCart(cartProvider: cartProvider, productProvider: product);
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
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
                      cartProvider.removeLastItem(product.id);
                    },
                  ),
                ),
              );
            },
            icon: Icon(Icons.shopping_cart_outlined),
            color: Theme.of(context).accentColor,
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
          ),
        ),
      ),
    );
  }
}
