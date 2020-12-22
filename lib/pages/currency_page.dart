import 'package:finamoonproject/index.dart';
import 'package:finamoonproject/model/currency.dart';
import 'package:finamoonproject/repos/hive_repository.dart';
import 'package:finamoonproject/style/decorations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<TextEditingController> controllers = [
  TextEditingController(),
  TextEditingController(),
];

class CurrencyPage extends StatefulWidget {
  CurrencyPage({Key key}) : super(key: key);

  @override
  _CurrencyPageState createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  @override
  Widget build(BuildContext context) {
    String name1 = "USD";
    String name2 = "BYN";
    int res;

    return Container(
        decoration: Decorations.buildBoxDecoration(),
        child: Stack(
          children: [
            Column(
              children: [
                CurrencyCell(
                  name: name1,
                  index: 0,
                  controller: controllers[0],
                ),
                CurrencyCell(
                  name: name2,
                  color: Colors.black12,
                  index: 1,
                  controller: controllers[1],
                ),
              ],
            ),
            IconButton(
                icon: Icon(
                  Icons.arrow_downward_outlined,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () async {
                  //TODO очень тупой костыль
                  final hiveRepository =
                      RepositoryProvider.of<HiveRepository>(context);
                  List<Currency> list = await hiveRepository.getAllCurrencies();
                  for (Currency currency1 in list) {
                    if (currency1.currencyAbbreviation == name1) {
                      for (Currency currency2 in list) {
                        if(currency2.currencyAbbreviation == name2){
                          controllers[1].text = ((double.tryParse(controllers[0].text) * currency2.rate) / currency1.rate).toString();
                        }
                      }
                    }
                  }
                })
          ],
        ));
  }
}
