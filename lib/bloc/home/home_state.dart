import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  final String title;
  HomeState([this.title]);

  @override
  List<Object> get props => (title ?? []);
}

class CurrencyPageState extends HomeState {
  final String title;
  CurrencyPageState(this.title) : super(title);
  @override
  String toString() => 'UnHomeState';
}

class WalletPageState extends HomeState {
  final String title;
  WalletPageState(this.title) : super(title);
  @override
  String toString() => 'WalletPageState';
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
