import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
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
          RowItems(Icons.add_shopping_cart, 'Products', goTo: '/'),
          RowItems(
            Icons.shopping_cart,
            'Your Cart',
            goTo: CartScreen.routeName,
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
          RowItems(Icons.payment, 'Your Orders', goTo: OrdersScreen.routeName),
          RowItems(Icons.edit_outlined, 'Manage Products', goTo: ManagerProductsScreen.routeName),
          RowItems(Icons.logout, 'Logout', onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            Provider.of<Auth>(context, listen: false).logOut();
          }),
        ],
      ),
    );
  }
}

class RowItems extends StatelessWidget {
  final IconData icon;
  final String name;
  final String goTo;
  final String args;
  final Widget widget;
  final Function onTap;

  const RowItems(this.icon, this.name, {this.goTo, this.args, this.widget, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: goTo != null
          ? () {
              Navigator.of(context).pushReplacementNamed(
                goTo,
                arguments: args,
              );
            }
          : onTap,
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
          if (args != null) widget,
        ],
      ),
    );
  }
}

// Widget rowItems(IconData icon, String name,
//     {String goTo = '', String args = '', Widget widget = null, Function onTap}) {}
