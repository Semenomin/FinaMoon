import 'package:finamoonproject/style/decorations.dart';
import 'package:finamoonproject/util/const.dart';
import 'package:finamoonproject/repos/sqlite_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartsPage extends StatefulWidget {
  ChartsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageState();
  }
}

class _PageState extends State<ChartsPage> {
  dynamic preferences = SharedPreferences;
  DateTime initialDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  bool submitting = false;
  bool submittingGraph = false;
  var balance, income, expenses, savings;
  Map<String, double> dataMap = Map();
  Map<String, double> dataMapCategories = Map();
  List<Color> colorList = [Colors.black54, Colors.black26, Colors.black12];

  /// This method gets the current currency
  String _getCurrency() {
    final currency = preferences.getString("currency") ?? '';
    return currency;
  }

  /// This method converts a number into currency format with two decimals
  String _numberFormat(value) {
    return NumberFormat.currency(name: _getCurrency(), decimalDigits: 2)
        .format(value)
        .toString();
  }

  /// Interface for accessing and modifying preference data
  _initPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      this.preferences = preferences;
      _getCurrency();
      fetchTotalsFromDatabase();
      fetchTotalsByCategoryFromDatabase();
    });
  }

  /// This method gets the sum of Income, Expenses & Savings from database
  /// Set the balance value and populates the types graph pie chart
  fetchTotalsFromDatabase() async {
    setState(() {
      submittingGraph = false;
    });
    var dbHelper = SqliteRepository();
    List<Map> totals = await dbHelper.getTransactionsSum(initialDate);
    setState(() {
      income = totals[0]['income'];
      expenses = totals[0]['expenses'];
      savings = totals[0]['savings'];
      balance = _numberFormat(income - (expenses + savings));
      dataMap.clear();
      dataMap.putIfAbsent("Income", () => income > 0 ? income : 0);
      dataMap.putIfAbsent("Expenses", () => expenses > 0 ? expenses : 0);
      dataMap.putIfAbsent("Savings", () => savings > 0 ? savings : 0);
      submittingGraph = true;
    });
    return totals;
  }

  /// This method gets the categories and their total and
  /// populates the categories graph pie chart
  fetchTotalsByCategoryFromDatabase() async {
    setState(() {
      submittingGraph = false;
    });
    var dbHelper = SqliteRepository();
    List<Map> totals = await dbHelper.getTransactionsByCategory(initialDate);
    setState(() {
      dataMapCategories.clear();
      for (int i = 0; i < totals.length; i++) {
        dataMapCategories.putIfAbsent(totals[i]['category'],
            () => totals[i]['total'] > 0 ? totals[i]['total'] : 0);
      }
      submittingGraph = true;
    });
    return totals;
  }

  /// This method is called the first time a stateful
  /// widget is inserted in the widget-tree
  @override
  void initState() {
    super.initState();

    /// This forces the orientation to be portrait up only
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _initPreferences();
  }

  /// Builds the reports page UI
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Decorations.buildBoxDecoration(),
      child: bodyWidget(context),
    );
  }

  /// Body widget
  Widget bodyWidget(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(top: 20.0),
        child: new Stack(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /// Build Header widget
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: headerWidget(context: context),
                  ),

                  /// Build Balance widget
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: new Card(
                        color: Color.fromRGBO(40, 40, 40, 100),
                        child: new ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(10.0),
                            children: <Widget>[
                              new ListTile(
                                dense: true,
                                title: new Text('Balance',
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                                trailing:
                                    new Text((balance != null) ? balance : '0',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: Constants.balanceTxtColor,
                                        )),
                              ),
                            ])),
                  ),

                  new SizedBox(height: 10.0),

                  /// Build types graph pie chart header text
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: new Text(
                      'Transactions / Type',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      ),
                    ),
                  ),

                  new SizedBox(height: 5.0),

                  /// Build types graph pie chart
                  new Flexible(
                    child: submittingGraph && dataMap.length > 0
                        ? typesGraph(context: context)
                        : Center(child: new Text("N/A")),
                  ),

                  new SizedBox(height: 10.0),

                  /// Build categories graph pie chart header text
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: new Text(
                      'Transactions / Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  new SizedBox(height: 5.0),

                  /// Build categories graph pie chart
                  new Flexible(
                    child: submittingGraph && dataMapCategories.length > 0
                        ? categoriesGraph(context: context)
                        : new Center(child: Text("N/A",style:TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    ))),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  /// Header widget
  Widget headerWidget({@required BuildContext context}) {
    return new Container(
        child: new Row(
      children: <Widget>[
        new Expanded(
            flex: 4,
            child: new RichText(
              text: new TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                children: <TextSpan>[
                  new TextSpan(
                    text: DateFormat.MMMM("en_US").format(selectedDate),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  new TextSpan(
                    text: ', ',
                  ),
                  new TextSpan(
                    text: DateFormat.y("en_US").format(selectedDate),
                  ),
                ],
              ),
            )),
        Expanded(
          flex: 1,
          child: new IconButton(
            padding: const EdgeInsets.all(0.0),
            alignment: Alignment.centerRight,
            icon: new Icon(
              FontAwesomeIcons.calendarAlt,
              size: 26,
            ),
            tooltip: 'Calendar',
            color: Colors.white,
            iconSize: 20,
            onPressed: () {
              showMonthPicker(
                      context: context,
                      lastDate: DateTime(DateTime.now().year + 1, 9),
                      initialDate: selectedDate ?? initialDate)
                  .then((date) {
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                    initialDate = selectedDate;
                    fetchTotalsFromDatabase();
                    fetchTotalsByCategoryFromDatabase();
                  });
                }
              });
            },
          ),
        )
      ],
    ));
  }

  /// Types (Income, Expenses and Savings) graph pie chart widget
  Widget typesGraph({@required BuildContext context}) {
    /// Builds the graph pie chart from dataMap list
    /// and colorList for Income/Expenses/Savings
    /// colors are changeable in util/const.dart
    return new PieChart(
      dataMap: dataMap,
      legendStyle: TextStyle(color: Colors.white, fontSize: 13),
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 35.0,
      showChartValuesInPercentage: true,
      showChartValues: true,
      showChartValuesOutside: false,
      chartValueBackgroundColor: Colors.black,
      colorList: colorList,
      showLegends: true,
      legendPosition: LegendPosition.right,
      decimalPlaces: 0,
      showChartValueLabel: true,
      initialAngle: 0,
      chartValueStyle: defaultChartValueStyle.copyWith(
        color: Colors.white.withOpacity(0.9),
      ),
      chartType: ChartType.disc,
    );
  }

  /// Categories graph pie chart widget
  Widget categoriesGraph({@required BuildContext context}) {
    /// Builds graph pie chart from dataMapCategories
    return new PieChart(
      colorList: [Colors.white70,Colors.white54,Colors.white24],
      dataMap: dataMapCategories,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32.0,
      legendStyle: TextStyle(color: Colors.white, fontSize: 13),
      chartRadius: MediaQuery.of(context).size.width / 1,
      showChartValuesInPercentage: true,
      showChartValues: true,
      showChartValuesOutside: false,
      chartValueBackgroundColor: Colors.black,
      showLegends: true,
      legendPosition: LegendPosition.right,
      decimalPlaces: 0,
      showChartValueLabel: true,
      initialAngle: 0,
      chartValueStyle: defaultChartValueStyle.copyWith(
        color: Colors.white,
      ),
      chartType: ChartType.disc,
    );
  }
}
