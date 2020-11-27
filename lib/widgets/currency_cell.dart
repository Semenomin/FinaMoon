import 'package:finamoonproject/model/index.dart';
import 'package:finamoonproject/repos/currency_repository.dart';
import 'package:finamoonproject/repos/hive_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:select_dialog/select_dialog.dart';

//TODO save abbreviations
// ignore: must_be_immutable
class CurrencyCell extends StatefulWidget {
  CurrencyCell({Key key, this.color, this.name, this.index}) : super(key: key);
  Color color;
  String name;
  int index;
  @override
  _CurrencyCellState createState() =>
      _CurrencyCellState(color: color, name: name, index: index);
}

class _CurrencyCellState extends State<CurrencyCell> {
  Color _color = Colors.transparent;
  String _name;
  int _index;
  _CurrencyCellState({Color color, String name, int index}) {
    _color = color;
    _name = name;
    _index = index;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: TextFormField(
                    cursorColor: Colors.white12,
                    onChanged: (str) {
                      //TODO getcur
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
            _name,
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

  Future<String> buildShowModal(BuildContext context) async {
    List<Currency> list = await RepositoryProvider.of<HiveRepository>(context)
        .getAllCurrenciesFromHive();
    List<String> listOfAbbreviations = List<String>();
    for (Currency cur in list) {
      listOfAbbreviations.add(cur.currencyAbbreviation);
    }
    return SelectDialog.showModal<String>(
      context,
      label: "Choose Currency",
      titleStyle: TextStyle(color: Colors.white60),
      showSearchBox: true,
      selectedValue: _name,
      backgroundColor: Color.fromRGBO(102, 171, 0, 100),
      items: listOfAbbreviations,
      onChange: (String selected) {
        RepositoryProvider.of<HiveRepository>(context)
            .changeFavoriteCurrencies(_index, selected);
        setState(() {
          _name = selected;
        });
      },
    );
  }
}
