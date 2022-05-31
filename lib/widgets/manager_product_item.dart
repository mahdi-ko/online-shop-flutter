import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class ManagerProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const ManagerProductItem({Key key, this.title, this.imageUrl, @required this.id})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: id);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline),
              color: Theme.of(context).errorColor,
              onPressed: () {
                return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Delete product ' + title),
                    content: Text('Are you sure you want to delete this product?'),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('No'),
                      ),
                      FlatButton(
                        onPressed: () async {
                          try {
                            Navigator.of(ctx).pop();
                            await Provider.of<Products>(context, listen: false).deleteProduct(id);
                          } catch (error) {
                            scaffold.removeCurrentSnackBar();
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Deleting failed!',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                        splashColor: Colors.red[100],
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
