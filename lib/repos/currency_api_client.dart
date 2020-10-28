import 'package:finamoonproject/model/index.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

class CurrencyApiClient {
  static const baseUrl = 'https://openexchangerates.org/api/latest.json';
  static const appId = '3861d8bbdc994542b5ef26fadf159471';
  static const base = "USD";
  final http.Client httpClient;

  CurrencyApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);

  Future<List> getCurrencies(context) async {
    const currencyUrl = "$baseUrl?app_id=$appId&base=$base";
    final response = await http.get(currencyUrl);
    if (response.statusCode == 200) {
      try{
        return await Currency.fromJsons(response);
      }
      catch(_){
        _showMyDialog(context);
      }
    } else {
      throw Exception('Error fetching currencies. No connection');
    }
    return null;
  }
}

Future<void> _showMyDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Error Parse JSON'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}