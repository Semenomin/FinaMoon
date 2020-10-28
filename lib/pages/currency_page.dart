import 'package:finamoonproject/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CurrencyPage extends StatefulWidget {
  CurrencyPage({Key key}) : super(key: key);

  @override
  _CurrencyPageState createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: buildBoxDecoration(),
      child: Column(
        children: [
          CurrencyCell(
            name: "USD",
          ),
          CurrencyCell(
            name: "RUS",
            color: Colors.black12,
          ),
          CurrencyCell(
            name: "EUR",
          ),
          CurrencyCell(
            name: "GRI",
            color: Colors.black12,
          ),
          CurrencyCell(
            name: "LSD",
          ),
        ],
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
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
