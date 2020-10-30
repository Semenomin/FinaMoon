import 'dart:async';

import 'package:finamoonproject/bloc/home/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeEvent {
  Stream<HomeState> applyAsync({HomeState currentState, HomeBloc bloc});
}

class OpenCurrencyPageEvent extends HomeEvent {
  @override
  Stream<HomeState> applyAsync({HomeState currentState, HomeBloc bloc}) async* {
    yield CurrencyPageState("CURRENCIES");
  }
}

class OpenIncomePageEvent extends HomeEvent {
  @override
  Stream<HomeState> applyAsync({HomeState currentState, HomeBloc bloc}) async* {
    yield IncomePageState("INCOMES");
  }
}

class OpenChatScreenEvent extends HomeEvent {
  final HomeState state;
  OpenChatScreenEvent({this.state});
  @override
  Stream<HomeState> applyAsync({HomeState currentState, HomeBloc bloc}) async* {
    yield ChatScreenState();
    yield state;
  }
}

class OpenSettingsScreenEvent extends HomeEvent {
  @override
  Stream<HomeState> applyAsync({HomeState currentState, HomeBloc bloc}) async* {
    yield SettingsScreenState();
  }
}


