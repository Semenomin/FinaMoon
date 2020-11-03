import 'package:finamoonproject/model/index.dart';
import 'package:finamoonproject/repos/currency_api_client.dart';
import 'package:hive/hive.dart';

class CurrencyRepository {
  CurrencyApiClient apiClient;

  CurrencyRepository({this.apiClient});

  void saveCurrenciesInHive(context) async {
    List<Currency> list = await apiClient.getCurrencies(context);
    var box = await Hive.openBox<Currency>('currenciesBox');
    for (Currency cur in list) {
      box.put(cur.currencyAbbreviation, cur);
    }
  }

  static Future<Currency> getCurrencyFromHive(String currencyAbbreviation) async {
    var box = await Hive.openBox<Currency>('currenciesBox');
    return box.get(currencyAbbreviation);
  }

  static Future<List<Currency>> getAllCurrenciesFromHive() async{
    var box = await Hive.openBox<Currency>('currenciesBox');
    List<Currency> _list = List<Currency>();
    for(int i = 0; i < box.length; i++){
      _list.add(box.getAt(i));
    }
    return _list;
  }
}
