import 'dart:convert';
import 'package:finamoonproject/repos/currency_repository.dart';
import 'package:http/http.dart';

class Currency {
  Currency({this.currencyAbbreviation, this.rate});
  final String currencyAbbreviation;
  final dynamic rate;

  static Future<List> fromJsons(Response response) async {
    List<Currency> currencies = new List<Currency>();
    Map data = await json.decode(response.body) as Map;
    data['rates'].forEach((k, v) {
      currencies.add(Currency(currencyAbbreviation: k, rate: v));
    });
    return currencies;
  }

  Future<dynamic> castCurrency({dynamic value, Currency to}) async {
    try {
      double parcedValue = double.tryParse(value);
      if(parcedValue == null){
        throw Exception("Invalid value in ${this.currencyAbbreviation} cell");
      }
      Currency currencyTo = await CurrencyRepository.getCurrencyFromDB(to);
      return (value * currencyTo.rate) / this.rate;
    } catch (ex) {
      print(ex);
    }
  }
}
