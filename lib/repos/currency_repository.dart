import 'package:finamoonproject/model/index.dart';
import 'package:finamoonproject/repos/currency_api_client.dart';
import 'package:finamoonproject/repos/repository.dart';
import 'package:hive/hive.dart';

class CurrencyRepository extends Repository{
  CurrencyApiClient apiClient;

  CurrencyRepository({this.apiClient});

  Future<List<Currency>> getCurrencies(context) async {
    List<Currency> list = await apiClient.getCurrencies(context);
    return list;
  }
}
