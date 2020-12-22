import 'package:finamoonproject/model/index.dart';
import 'package:finamoonproject/repos/repository.dart';
import 'package:hive/hive.dart';

class HiveRepository extends Repository{

  Future<void> changeFavoriteCurrencies(int index,String value) async {
    var boxList = await Hive.openBox<List<Currency>>('currenciesBox');
    var box = await Hive.openBox<Currency>('favoriteBox');
    List<Currency> list = boxList.get('favorite');
    list[index] = box.get(value);
  }

  Future<List<Currency>> getFavoriteCurrencies() async{
    var boxList = await Hive.openBox<List<Currency>>('currenciesBox');
    List<Currency> list = boxList.get('favorite');
    return list;
  }

  void initOrUpdateCurrencies(List<Currency> list) async {
    var listOfCur = <Currency>[];
    var box = await Hive.openBox<Currency>('currenciesBox');
    var boxList = await Hive.openBox<List<Currency>>('favoriteBox');
    for (Currency cur in list) {
      if(boxList.isEmpty){
        if(cur.currencyAbbreviation == "USD" || cur.currencyAbbreviation == "RUS" || cur.currencyAbbreviation == "EUR" || cur.currencyAbbreviation == "BLR" || cur.currencyAbbreviation == "AED"){
          listOfCur.add(cur);
        }
      }
      box.put(cur.currencyAbbreviation, cur);
    }
    if(boxList.isEmpty){
      boxList.put('favorite', listOfCur);
    }
  }

  Future<Currency> getCurrency(String currencyAbbreviation) async {
    var box = await Hive.openBox<Currency>('currenciesBox');
    return box.get(currencyAbbreviation);
  }

  Future<List<Currency>> getAllCurrencies() async{
    var box = await Hive.openBox<Currency>('currenciesBox');
    List<Currency> _list = List<Currency>();
    for(int i = 0; i < box.length; i++){
      _list.add(box.getAt(i));
    }
    return _list;
  }

}