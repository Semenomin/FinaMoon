import 'package:finamoonproject/pages/currency_page.dart';
import 'package:finamoonproject/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

List<NavigationRailDestination> destinations = [
  NavigationRailDestination(icon: Icon(Icons.menu), label: Text("MENU")),
  NavigationRailDestination(
      icon: Icon(Icons.money_off), label: Text("CURRENSIES")),
  NavigationRailDestination(icon: Icon(Icons.menu), label: Text("Love")),
  NavigationRailDestination(icon: Icon(Icons.menu), label: Text("Love")),
];

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  bool _isExtended = false;
  String _title = "CURRENCIES";
  Color white = Colors.white;
  Widget _mainPage = CurrencyPage();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              buildShowModalBottomSheet(context);
            },
            backgroundColor: Color.fromRGBO(51, 51, 51, 100),
            foregroundColor: Colors.white24,
            child: Icon(Icons.chat),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
                  title: Text(
                    _title,
                    softWrap: false,
                    style: TextStyle(fontSize: 35, color: white),
                  ),
                  actions: <Widget>[
                    IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
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
                          child: _mainPage,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
            ],
          )),
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
            {
              setState(() {
                _title = "CURRENCIES";
                _mainPage = CurrencyPage();
              });
              break;
            }

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
