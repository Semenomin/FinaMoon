import 'dart:convert';

import 'package:finamoonproject/model/index.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

class CurrencyApiClient {
  static const baseUrl = 'https://openexchangerates.org/api/latest.json';
  static const appId = '3861d8bbdc994542b5ef26fadf159471';
  static const base = "USD";
  final http.Client httpClient;

  CurrencyApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);

  Future<List> getCurrencies() async {
    List<Currency> currencies = new List<Currency>();
    const currencyUrl = "$baseUrl?app_id=$appId&base=$base";
    final response = await http.get(currencyUrl);
    if (response.statusCode == 200) {
      Map data = await json.decode(response.body) as Map;
      data['rates'].forEach((k, v) {
        currencies.add(Currency(currencyAbbreviation: k, rate: v));
      });
      return currencies;
    } else {
      throw Exception('error fetching currencies');
    }
  }
}
