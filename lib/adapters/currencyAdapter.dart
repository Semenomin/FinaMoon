import 'package:finamoonproject/model/currency.dart';
import 'package:hive/hive.dart';

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final typeId = 0;

  @override
  Currency read(BinaryReader reader) {
    return Currency(currencyAbbreviation: reader.read(),rate: reader.read());
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    writer.write(obj.currencyAbbreviation);
    writer.write(obj.rate);
  }
}