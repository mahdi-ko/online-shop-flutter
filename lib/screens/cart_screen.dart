import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart' show Cart;
import 'package:my_shop/providers/order.dart';
import 'package:my_shop/widgets/cart_item.dart';
import 'package:my_shop/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/CartScreen';
  @override
  Widget build(BuildContext context) {
    bool addDrawer = false;
    if (ModalRoute.of(context).settings.arguments == "addDrawer")
      addDrawer = true;
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      "\$" + cart.totalAmount,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: OrderButton(cart: cart),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
              child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (_, i) => CartItemW(
              id: cart.items.values.toList()[i].id,
              productId: cart.items.keys.toList()[i],
              title: cart.items.values.toList()[i].title,
              price: cart.items.values.toList()[i].price,
              qty: cart.items.values.toList()[i].quantity,
              isLastItem: cart.items.length - 1 == i,
            ),
          ))
        ],
      ),
      drawer: addDrawer ? MainDrawer() : null,
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context, listen: false);
    return TextButton(
      onPressed: (double.parse(widget.cart.totalAmount) <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await orders.addOrder(widget.cart.items.values.toList(),
                  double.parse(widget.cart.totalAmount));
              _isLoading = false;
              widget.cart.clearCart();
            },
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            )
          : Text(
              'ORDER NOW!',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
    );
  }
}
