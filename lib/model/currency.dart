import 'dart:convert';
import 'package:finamoonproject/repos/currency_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';


class Currency {
  String currencyAbbreviation;
  dynamic rate;

  Currency({this.currencyAbbreviation, this.rate});

  static Future<List> fromJsons(Response response) async {
    List<Currency> currencies = new List<Currency>();
    Map data = await json.decode(response.body) as Map;
    data['rates'].forEach((k, v) {
      currencies.add(Currency(currencyAbbreviation: k, rate: v));
    });
    return currencies;
  }

  Future<dynamic> castCurrency({dynamic value, String to, context}) async {
    try {
      double parcedValue = double.tryParse(value);
      if(parcedValue == null){
        throw Exception("Invalid value in ${this.currencyAbbreviation} cell");
      }
      Currency currencyTo = await CurrencyRepository.getCurrencyFromHive(to);
      return (value * currencyTo.rate) / this.rate;
    } catch (ex) {
      print(ex);
    }
  }
}
