import 'package:finamoonproject/pages/currency_page.dart';
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
  String _title = "Home";
  Color white = Colors.white;
  Widget _mainPage = Container(color: Colors.transparent);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Color.fromRGBO(51, 51, 51, 100),
          body: Row(
            children: <Widget>[
              NavigationRail(
                extended: _isExtended,
                selectedLabelTextStyle:
                    TextStyle(color: Colors.grey, fontSize: 20),
                unselectedLabelTextStyle: TextStyle(color: white, fontSize: 20),
                unselectedIconTheme: IconThemeData(color: white),
                selectedIconTheme:
                    IconThemeData(color: Color.fromRGBO(102, 171, 0, 100)),
                backgroundColor: Colors.transparent,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (value) {
                  if (value == 0) {
                    if (_isExtended == false) {
                      setState(() {
                        _isExtended = true;
                      });
                    } else
                      setState(() {
                        _isExtended = false;
                      });
                  } else if (value == 1) {
                    setState(() {
                      _title = "CURRENCIES";
                      _mainPage = CurrencyPage();
                    });
                  }
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                labelType: NavigationRailLabelType.none,
                destinations: destinations,
                minWidth: 56,
              ),
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
                bottomNavigationBar: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.accessibility_new),
                    ),
                    BottomNavigationBarItem(icon: Icon(Icons.access_alarms)),
                    BottomNavigationBarItem(icon: Icon(Icons.ac_unit)),
                    BottomNavigationBarItem(icon: Icon(Icons.access_time)),
                    BottomNavigationBarItem(icon: Icon(Icons.account_box)),
                  ],
                  iconSize: 27,
                  backgroundColor: Colors.transparent,
                  fixedColor: Color.fromRGBO(102, 171, 0, 100),
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  unselectedItemColor: Colors.white30,
                ),
                body: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Neumorphic(
                            style: NeumorphicStyle(
                              intensity: 0.5,
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      bottomLeft: Radius.circular(50))),
                              depth: 2.5,
                              lightSource: LightSource.bottomRight,
                              color: Color.fromRGBO(102, 171, 0, 100),
                            ),
                            child: _mainPage),
                      ),
                    ),
                  ],
                ),
              ))
            ],
          )),
    );
  }
}
