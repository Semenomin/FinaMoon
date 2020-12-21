import 'package:finamoonproject/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'bloc/home/index.dart';
import 'classes/localedelegate.dart';

class MyApp extends StatelessWidget {
  final List<RepositoryProvider> repositories;

  MyApp(this.repositories);

  @override
  Widget build(BuildContext context) {
    //TODO repositories.saveCurrenciesInHive(context);
    return MaterialApp(
      localizationsDelegates: [
        const LocDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: MultiRepositoryProvider(
        providers: repositories,
        child: BlocProvider(
          create: (context) => HomeBloc(),
          child: HomeScreen(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
