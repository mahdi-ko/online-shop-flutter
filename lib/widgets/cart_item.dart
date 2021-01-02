import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';

class CartItemW extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int qty;
  final String title;
  final bool isLastItem;

  const CartItemW(
      {@required this.id,
      @required this.productId,
      @required this.price,
      @required this.qty,
      @required this.title,
      @required this.isLastItem});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final products = Provider.of<Products>(context, listen: false);
    return Column(
      children: <Widget>[
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Dismissible(
            confirmDismiss: (direction) {
              return showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete item'),
                  content: Text(
                      'Are you sure you want to remove the item from the cart?'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                    ),
                    FlatButton(
                      splashColor: Colors.red[100],
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              cart.removeCartItem(
                productId,
              );
            },
            direction: DismissDirection.endToStart,
            key: ValueKey(id),
            background: Container(
              padding: EdgeInsets.only(right: 20),
              color: Theme.of(context).accentColor,
              child: Icon(
                Icons.delete,
                size: 35,
                color: Colors.white,
              ),
              alignment: Alignment.centerRight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: SizedBox(
                  width: 55,
                  child: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                          products.findById(productId).imageUrl,
                        ),
                      ),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.black38,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: FittedBox(
                            child: Text(
                              '\$$price',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(title),
                subtitle: Text('Total: \$${(price * qty).toStringAsFixed(2)}'),
                trailing: Container(
                  width: MediaQuery.of(context).size.width / 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Text(' ${qty}x'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isLastItem)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'swipe to delete.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
