import 'package:finamoonproject/model/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:select_dialog/select_dialog.dart';

// ignore: must_be_immutable
class CurrencyCell extends StatefulWidget {
  CurrencyCell({Key key, this.color, this.name, this.currency})
      : super(key: key);
  Color color;
  String name;
  Currency currency;
  @override
  _CurrencyCellState createState() =>
      _CurrencyCellState(color: color, name: name, currency: currency);
}

class _CurrencyCellState extends State<CurrencyCell> {
  Color _color = Colors.transparent;
  String _name;
  Currency _currency;

  _CurrencyCellState({Color color, String name, Currency currency}) {
    _color = color;
    _name = name;
    _currency = currency;
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0,),
                child: TextFormField(
                  cursorColor: Colors.white12,
                  onChanged: (str) {
                    //TODO getcurrnames;
                  },
                  keyboardType: TextInputType.number,
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
          buildGestureDetector(context),
        ],
      ),
    ));
  }

  GestureDetector buildGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: () {
        buildShowModal(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Text(
            _name, //TODO CurrencyAbreviation
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(102, 171, 0, 100)),
          ),
          alignment: Alignment.topRight,
        ),
      ),
    );
  }

  Future<String> buildShowModal(BuildContext context) {
    //TODO getCurrencies
    return SelectDialog.showModal<String>(
      context,
      label: "Choose Currency",
      titleStyle: TextStyle(color: Colors.white60),
      showSearchBox: true,
      selectedValue: _name,
      backgroundColor: Color.fromRGBO(102, 171, 0, 100),
      items: List.generate(50, (index) => "Item $index"), //TODO generate list
      onChange: (String selected) {
        setState(() {
          _name = selected;
        });
      },
    );
  }
}
