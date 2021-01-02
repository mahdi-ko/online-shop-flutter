import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/manager_products_screen.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statusBarSize = MediaQuery.of(context).padding.top;
    final cart = Provider.of<Cart>(context, listen: false);
    Widget rowItems(IconData icon, String name, String goTo,
        {String args = '', Widget widget}) {
      return InkWell(
        onTap: () {
          Navigator.of(context).pushReplacementNamed(
            goTo,
            arguments: args,
          );
        },
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Icon(
                icon,
                size: 30,
              ),
            ),
            Container(
              child: Text(
                name,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Spacer(),
            if (args != '') widget,
          ],
        ),
      );
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: statusBarSize),
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            width: double.infinity,
            child: Text(
              'Shop',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 23,
              ),
            ),
          ),
          Divider(
            thickness: 1,
          ),
          SizedBox(
            height: 10,
          ),
          rowItems(Icons.add_shopping_cart, 'Products', '/'),
          rowItems(
            Icons.shopping_cart,
            'Your Cart',
            CartScreen.routeName,
            args: 'addDrawer',
            widget: Container(
              margin: EdgeInsets.only(right: 10),
              child: Chip(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                backgroundColor: Theme.of(context).primaryColor,
                label: cart.items.length > 0
                    ? Text(
                        cart.items.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Empty',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          rowItems(Icons.payment, 'Your Orders', OrdersScreen.routeName),
          rowItems(Icons.edit_outlined, 'Manage Products',
              ManagerProductsScreen.routeName),
        ],
      ),
    );
  }
}
