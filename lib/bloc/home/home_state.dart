import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  final String title;
  final int transactionId;
  HomeState([this.title, this.transactionId]);

  @override
  List<Object> get props => (title ?? []);
}

class CurrencyPageState extends HomeState {
  final String title;
  CurrencyPageState(this.title) : super(title);
  @override
  String toString() => 'CurrencyPageState';
}

class WalletPageState extends HomeState {
  final String title;
  WalletPageState(this.title) : super(title);
  @override
  String toString() => 'WalletPageState';
}

class ChartsPageState extends HomeState {
  final String title;
  ChartsPageState(this.title) : super(title);
  @override
  String toString() => 'ChartsPageState';
}

class AuthScreenState extends HomeState {
  @override
  String toString() => 'AuthScreenState';
}

class EditTransactionPageState extends HomeState {
  final int transactionId;
  EditTransactionPageState(this.transactionId) : super("EDIT", transactionId);
  @override
  String toString() => 'EditTransactionPage';
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
