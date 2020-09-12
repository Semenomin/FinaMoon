import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class CurrencyCell extends StatefulWidget {
  CurrencyCell({Key key, Color this.color, String this.name}) : super(key: key);
  Color color;
  String name;
  @override
  _CurrencyCellState createState() =>
      _CurrencyCellState(color: color, name: name);
}

class _CurrencyCellState extends State<CurrencyCell> {
  Color _color = Colors.transparent;
  String _name = "none";

  _CurrencyCellState({Color color, String name}) {
    _color = color;
    _name = name;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      color: _color,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  cursorColor: Colors.white12,
                  onChanged: (str) {
                    print(str);
                  },
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 62,
                    color: Colors.white38,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Text(
                _name,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(102, 171, 0, 100)),
              ),
              alignment: Alignment.topRight,
            ),
          ),
        ],
      ),
    ));
  }
}
