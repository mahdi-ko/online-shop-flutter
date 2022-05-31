import 'package:flutter/material.dart';
import 'package:my_shop/providers/order.dart';
import 'package:my_shop/widgets/main_drawer.dart';
import 'package:my_shop/widgets/order_item.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        body: FutureBuilder(
            future:
                Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
            builder: (ctx, dataSnapShot) {
              if (dataSnapShot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else
                return Consumer<Orders>(
                  builder: (ctx, orders, child) => ListView.builder(
                    itemCount: orders.allOrders.length,
                    itemBuilder: (ctx, i) => OrderItem(orders.allOrders[i]),
                  ),
                );
            }));
  }
}
