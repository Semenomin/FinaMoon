import 'package:finamoonproject/repos/currency_api_client.dart';
import 'package:finamoonproject/repos/currency_repository.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'adapters/currencyAdapter.dart';
import 'index.dart';
import 'package:http/http.dart' as http;
void main() async{
  await Hive.initFlutter();
  Hive.registerAdapter(CurrencyAdapter());
  CurrencyRepository repo = CurrencyRepository(apiClient: CurrencyApiClient(httpClient: http.Client()));
  runApp(MyApp(repo));
}
