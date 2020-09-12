import 'dart:io';

import 'package:finamoonproject/repos/currency_api_client.dart';
import 'package:flutter/material.dart';
import 'index.dart';
import 'package:http/http.dart' as http;

void main() {
  var cur = CurrencyApiClient(httpClient: http.Client());
  cur.getCurrencies();
  runApp(MyApp());
}
