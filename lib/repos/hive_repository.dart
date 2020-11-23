import 'package:finamoonproject/model/index.dart';
import 'package:hive/hive.dart';

class HiveRepository{

  static Future<void> changeFavoriteCurrencies(int index,String value) async {
    var boxList = await Hive.openBox<List<Currency>>('currenciesBox');
    var box = await Hive.openBox<Currency>('favoriteBox');
    List<Currency> list = boxList.get('favorite');
    list[index] = box.get(value);
  }
}