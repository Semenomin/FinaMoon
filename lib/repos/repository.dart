import 'package:finamoonproject/adapters/currencyAdapter.dart';
import 'package:finamoonproject/repos/sqlite_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'currency_api_client.dart';
import 'currency_repository.dart';
import 'hive_repository.dart';

class Repository{

  static Future<List<RepositoryProvider>> initRepositories() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CurrencyAdapter());
    List<RepositoryProvider> repositories = [];
    repositories.add(RepositoryProvider<CurrencyRepository>(create: (ctx) => CurrencyRepository(
        apiClient: CurrencyApiClient(httpClient: http.Client()))));
    repositories.add(RepositoryProvider<SqliteRepository>(create: (ctx) => SqliteRepository()));
    repositories.add(RepositoryProvider<HiveRepository>(create: (ctx) => HiveRepository()));
    return repositories;
  }

}