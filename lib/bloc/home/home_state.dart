import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  final String title;
  HomeState([this.title]);

  @override
  List<Object> get props => (title ?? []);
}

class CurrencyPageState extends HomeState {
  String title;
  CurrencyPageState(this.title) : super(title);
  @override
  String toString() => 'UnHomeState';
}

class IncomePageState extends HomeState {
  String title;
  IncomePageState(this.title) : super(title);
  @override
  String toString() => 'IncomePageState';
}

class ChatScreenState extends HomeState {
  @override
  String toString() => 'ChatScreenState';
}

class SettingsScreenState extends HomeState {
  @override
  String toString() => 'GoToSettingsScreen';
}








class ErrorHomeState extends HomeState {
  @override
  String toString() => 'ErrorHomeState';
}
