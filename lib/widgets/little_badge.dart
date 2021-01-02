import 'package:flutter/material.dart';

class LittleBadge extends StatelessWidget {
  final Widget child;
  final String value;
  Color color;

  LittleBadge({
    @required this.child,
    @required this.value,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return value != "0" && value.isNotEmpty
        ? Stack(
            alignment: Alignment.center,
            children: <Widget>[
              child,
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor:
                      color != null ? color : Theme.of(context).accentColor,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: FittedBox(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        : child;
  }
}
