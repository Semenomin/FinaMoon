import 'package:finamoonproject/model/index.dart';
import 'package:finamoonproject/repos/currency_api_client.dart';
import 'package:finamoonproject/repos/repository.dart';
import 'package:hive/hive.dart';

class CurrencyRepository extends Repository {
  CurrencyApiClient apiClient;

  CurrencyRepository({this.apiClient});

  void saveCurrenciesInHive(context) async {
    List<Currency> list = await apiClient.getCurrencies(context);
    var listOfCur = <Currency>[];
    var box = await Hive.openBox<Currency>('currenciesBox');
    var boxList = await Hive.openBox<List<Currency>>('favoriteBox');
    for (Currency cur in list) {
      if (boxList.isEmpty) {
        if (cur.currencyAbbreviation == "USD" ||
            cur.currencyAbbreviation == "RUS" ||
            cur.currencyAbbreviation == "EUR" ||
            cur.currencyAbbreviation == "BLR" ||
            cur.currencyAbbreviation == "AED") {
          listOfCur.add(cur);
        }
      }
      box.put(cur.currencyAbbreviation, cur);
    }
    if (boxList.isEmpty) {
      boxList.put('favorite', listOfCur);
    }
  }
}
