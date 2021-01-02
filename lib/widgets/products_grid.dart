import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  const ProductsGrid(this.showFavs);

  bool isPortrait(BuildContext ctx) {
    return MediaQuery.of(ctx).orientation == Orientation.portrait;
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);

    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return products.isNotEmpty
        ? GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isPortrait(context) ? 1 : 2,
              childAspectRatio: isPortrait(context) ? 1 : 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: ProductItem(showFavs),
            ),
            itemCount: products.length,
          )
        : Container();
  }
}
