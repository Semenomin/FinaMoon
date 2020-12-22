import 'package:finamoonproject/bloc/home/index.dart';
import 'package:finamoonproject/components/transaction/transaction.new.page.dart';
import 'package:finamoonproject/pages/charts_page.dart';
import 'package:finamoonproject/pages/currency_page.dart';
import 'package:finamoonproject/pages/index.dart';
import 'package:finamoonproject/pages/wallet_page.dart';
import 'package:finamoonproject/repos/currency_repository.dart';
import 'package:finamoonproject/repos/hive_repository.dart';
import 'package:finamoonproject/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screen_lock/lock_screen.dart';
import 'package:local_auth/local_auth.dart';

List<NavigationRailDestination> destinations = [
  NavigationRailDestination(icon: Icon(Icons.menu), label: Text("MENU")),
  NavigationRailDestination(
      icon: Icon(Icons.account_balance_wallet), label: Text("BUDGET")),
  NavigationRailDestination(
      icon: Icon(Icons.compare_arrows), label: Text("CURRENSIES")),
  NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text("CHARTS")),
];

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  bool _isExtended = false;
  Color white = Colors.white;

  @override
  void initState() {
    initData();
    BlocProvider.of<HomeBloc>(context).add(WelcomeStateEvent());
    super.initState();
  }

  void initData() async {
    final hiveRepository = RepositoryProvider.of<HiveRepository>(context);
    final currencyRepository =
        RepositoryProvider.of<CurrencyRepository>(context);
    hiveRepository.initOrUpdateCurrencies(
        await currencyRepository.getCurrencies(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is ChatScreenState) buildShowModalBottomSheet(context);
        if (state is AuthScreenState) buildAuthPage(context);
      },
      child: SafeArea(
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                BlocProvider.of<HomeBloc>(context).add(
                    OpenChatScreenEvent(state: context.bloc<HomeBloc>().state));
              },
              backgroundColor: Color.fromRGBO(51, 51, 51, 100),
              foregroundColor: Colors.white24,
              child: Icon(Icons.chat),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            backgroundColor: Color.fromRGBO(51, 51, 51, 100),
            body: Row(
              children: <Widget>[
                buildNavigationRail(),
                Expanded(
                    child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        return Text(
                          state.title,
                          softWrap: false,
                          style: TextStyle(fontSize: 35, color: white),
                        );
                      },
                    ),
                    actions: <Widget>[
                      IconButton(
                        onPressed: () => BlocProvider.of<HomeBloc>(context)
                            .add(OpenSettingsScreenEvent()),
                        icon: Icon(Icons.settings),
                      ),
                    ],
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: buildBottomNavigationBar(),
                  ),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: BlocBuilder<HomeBloc, HomeState>(
                                builder: (context, state) {
                              switch (state.runtimeType) {
                                case CurrencyPageState:
                                  return CurrencyPage();
                                  break;
                                case WalletPageState:
                                  return BudgetPage();
                                  break;
                                case ChartsPageState:
                                  return ChartsPage();
                                  break;
                                case EditTransactionPageState:
                                  return TransactionNewPage(
                                      transactionId: state.transactionId);
                                  break;
                                default:
                                  return Container(
                                      child: CircularProgressIndicator());
                              }
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            )),
      ),
    );
  }

  void buildAuthPage(BuildContext context){
    showLockScreen(
      canCancel: false,
      context: context,
      correctString: '1234',
      canBiometric: true,
      showBiometricFirst: true,
      biometricAuthenticate: (context) async {
        final localAuth = LocalAuthentication();
        final didAuthenticate =
        await localAuth.authenticateWithBiometrics(
            localizedReason: 'Please authenticate');
        if (didAuthenticate) {
          BlocProvider.of<HomeBloc>(this.context).add(OpenWalletPageEvent());
          return true;
        }
        else{
          return false;
        }
      },
      onUnlocked: () {
        BlocProvider.of<HomeBloc>(context).add(OpenWalletPageEvent());
      },
    );
  }

  Future buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(color: Colors.black87, child: HomePageDialogflow());
        });
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: bottomNavigationBaritems(),
      iconSize: 27,
      backgroundColor: Colors.transparent,
      fixedColor: Color.fromRGBO(102, 171, 0, 100),
      elevation: 0,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.white30,
    );
  }

  List<BottomNavigationBarItem> bottomNavigationBaritems() {
    return [
      BottomNavigationBarItem(
          icon: Icon(Icons.accessibility_new), label: "Name"),
      BottomNavigationBarItem(icon: Icon(Icons.access_alarms), label: "Name"),
      BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "Name"),
      BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Name"),
      BottomNavigationBarItem(icon: Icon(Icons.account_box), label: "Name"),
    ];
  }

  NavigationRail buildNavigationRail() {
    return NavigationRail(
      extended: _isExtended,
      selectedLabelTextStyle: TextStyle(color: Colors.grey, fontSize: 20),
      unselectedLabelTextStyle: TextStyle(color: white, fontSize: 20),
      unselectedIconTheme: IconThemeData(color: white),
      selectedIconTheme: IconThemeData(color: Color.fromRGBO(102, 171, 0, 100)),
      backgroundColor: Colors.transparent,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (value) {
        switch (value) {
          case 0:
            {
              if (_isExtended == false) {
                setState(() {
                  _isExtended = true;
                });
              } else
                setState(() {
                  _isExtended = false;
                });
              break;
            }
          case 1:
            BlocProvider.of<HomeBloc>(context).add(OpenWalletPageEvent());
            break;
          case 2:
            BlocProvider.of<HomeBloc>(context).add(OpenCurrencyPageEvent());
            break;
          case 3:
            BlocProvider.of<HomeBloc>(context).add(OpenChartsPageEvent());
            break;
          default:
        }
        if (value != 0) {
          setState(() {
            _selectedIndex = value;
          });
        }
      },
      labelType: NavigationRailLabelType.none,
      destinations: destinations,
      minWidth: 56,
    );
  }
}
