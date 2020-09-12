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
            name: "BYN",
          ),
        ],
      ),
    );
  }
}
