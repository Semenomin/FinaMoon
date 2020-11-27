import 'package:finamoonproject/model/index.dart';
import 'package:finamoonproject/repos/repository.dart';
import 'package:hive/hive.dart';

class HiveRepository extends Repository {
  var currenciesBox;
  var favoriteBox;

  HiveRepository() {
    initBoxes();
  }

  void initBoxes() async {
    currenciesBox = await Hive.openBox<Currency>('favoriteBox');
  }

  Future<void> changeFavoriteCurrencies(int index, String value) async {
    List<Currency> list = currenciesBox.get('favorite');
    list[index] = favoriteBox.get(value);
  }

  Future<Currency> getCurrencyFromHive(String currencyAbbreviation) async {
    return currenciesBox.get(currencyAbbreviation);
  }

  Future<List<Currency>> getAllCurrenciesFromHive() async {
    List<Currency> _list = List<Currency>();
    for (int i = 0; i < currenciesBox.length; i++) {
      _list.add(currenciesBox.getAt(i));
    }
    return _list;
  }
}
