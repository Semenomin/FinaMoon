import 'package:finamoonproject/repos/repository.dart';
import 'package:flutter/material.dart';
import 'index.dart';

void main() async {
  runApp(MyApp(await Repository.initRepositories()));
}

