import 'package:finamoonproject/repos/currency_api_client.dart';
import 'package:finamoonproject/repos/currency_repository.dart';
import 'package:finamoonproject/repos/hive_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'adapters/currencyAdapter.dart';
import 'index.dart';
import 'package:http/http.dart' as http;

void main() async {
  List<RepositoryProvider> repos = [];
  await Hive.initFlutter();
  Hive.registerAdapter(CurrencyAdapter());
  initRepositories(repos);
  runApp(MyApp(repos));
}

void initRepositories(List<RepositoryProvider> repos) {
  repos.add(RepositoryProvider.value(
      value: CurrencyRepository(
          apiClient: CurrencyApiClient(httpClient: http.Client()))));
  repos.add(RepositoryProvider.value(value: HiveRepository()));
}
