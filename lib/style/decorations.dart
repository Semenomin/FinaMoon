import 'package:flutter/widgets.dart';

class Decorations{
  static BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(20),
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      color: Color.fromRGBO(102, 171, 0, 100),
    );
  }
}