import 'package:flutter/material.dart';

class IncomePage extends StatefulWidget {
  static const String routeName = '/income';

  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income'),
      ),
      body: Container()
    );
  }
}
