import 'package:finamoonproject/repos/currency_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'bloc/home/index.dart';
import 'classes/localedelegate.dart';
import 'index.dart';

class MyApp extends StatelessWidget {
  final CurrencyRepository currencyRepository;
  MyApp(this.currencyRepository);

  @override
  Widget build(BuildContext context) {
    currencyRepository.saveCurrenciesInHive(context);
    return MaterialApp(
      localizationsDelegates: [
        const LocDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: RepositoryProvider.value(
        value: currencyRepository,
        child: BlocProvider(
          create: (context) => HomeBloc(),
          child: HomeScreen(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
