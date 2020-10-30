import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'bloc/home/index.dart';
import 'classes/localedelegate.dart';
import 'index.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        const LocDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: BlocProvider(
        create: (context) => HomeBloc(),
        child: HomeScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
