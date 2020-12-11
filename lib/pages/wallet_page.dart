import 'package:finamoonproject/components/transaction/transaction.class.dart';
import 'package:finamoonproject/components/transaction/transaction.new.page.dart';
import 'package:finamoonproject/pages/transactions_page.dart';
import 'package:finamoonproject/style/decorations.dart';
import 'package:finamoonproject/util/categories.dart';
import 'package:finamoonproject/util/const.dart';
import 'package:finamoonproject/repos/sqlite_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetPage extends StatefulWidget {
  BudgetPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new PageState();
  }
}

class PageState extends State<BudgetPage> {
  dynamic preferences = SharedPreferences;
  DateTime initialDate = DateTime.now();
  bool submitting = false;
  var totalIncome;
  var totalExpenses;
  var totalSavings;
  var totalBalance;

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

  /// This method converts a type to its colors
  /// Income, Expense, Saving colors are in util/const.dart
  Color _switchType(type) {
    Color color;
    switch (type) {
      case "Income":
        {
          color = Colors.white;
        }
        break;
      case "Expense":
        {
          color = Colors.white;
        }
        break;
      case "Saving":
        {
          color = Colors.white;
        }
        break;
      default:
        {
          color = Constants.expenseBgColor;
        }
        break;
    }
    return color;
  }

  /// Interface for accessing and modifying preference data
  _initPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      this.preferences = preferences;
      _getCurrency();
      getAllCategories();
      fetchTotalsFromDatabase(initialDate);
    });
  }

  /// This method gets the sum of Income, Expenses & Savings from database
  fetchTotalsFromDatabase(datetime) async {
    setState(() {
      submitting = false;
    });
    var dbHelper = SqliteRepository();
    List<Map> totals = await dbHelper.getTransactionsSum(datetime);
    setState(() {
      submitting = true;
      totalIncome = _numberFormat(totals[0]['income']);
      totalExpenses = _numberFormat(totals[0]['expenses']);
      totalSavings = _numberFormat(totals[0]['savings']);
      totalBalance = _numberFormat(
          totals[0]['income'] - (totals[0]['expenses'] + totals[0]['savings']));
    });
    return totals;
  }

  /// This method gets the current month's transactions from database
  Future<List<Transactions>> fetchTransactionsFromDatabase() async {
    var dbHelper = SqliteRepository();
    Future<List<Transactions>> finances = dbHelper.getTransactions(initialDate);
    return finances;
  }

  /// This method gets categories from database
  /// If there are no categories, insert them from
  /// the list in util/categories.dart
  Future<List<Map>> getAllCategories() async {
    var dbHelper = SqliteRepository();
    List<Map> categories = await dbHelper.getCategoriesList();
    setState(() {
      if (categories.length == 0) {
        constCategories.forEach((element) =>
            dbHelper.createCategory(context, element[0], element[1]));
      }
    });
    return null;
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

  /// Navigation Bar and a floating action button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(children: [
        PageView(
            scrollDirection: Axis.vertical,
            children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Container(
              decoration: Decorations.buildBoxDecoration(),
              child: bodyWidget(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Container(
              decoration: Decorations.buildBoxDecoration(),
              child: TransactionNewPage(),
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Container(
              decoration: Decorations.buildBoxDecoration(),
              child: TransactionsPage()),
        )
      ]),
    );
  }

  /// Body widget
  Widget bodyWidget(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(top: 20.0),
        child: new Stack(children: <Widget>[
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// Build Header widget
              new Container(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: headerWidget(context: context),
              ),

              /// Define a fixed height of size 10
              new SizedBox(height: 10.0),

              /// Build Overview widget
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: buildOverview(context: context),
              ),
              new SizedBox(height: 10.0),

              /// Build latest transactions list
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: new Text(
                  'Latest Transactions',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              new SizedBox(height: 5.0),
              buildTransactions(context: context),
            ],
          ),
        ]));
  }

  /// Header widget
  Widget headerWidget({@required BuildContext context}) {
    return new Container(
        child: new Expanded(
            flex: 4,
            child: new RichText(
              text: new TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                children: <TextSpan>[
                  new TextSpan(
                    text: DateFormat.MMMM("en_US").format(DateTime.now()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  new TextSpan(
                    text: ', ',
                  ),
                  new TextSpan(
                    text: DateFormat.y("en_US").format(DateTime.now()),
                  ),
                ],
              ),
            )));
  }

  /// Overview widget
  Widget buildOverview({@required BuildContext context}) {
    return new Container(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          /// Build Balance widget, Change colors in util/const.dart
          overviewWidget(
              context: context,
              type: 'Balance',
              total: totalBalance.toString(),
              txColor: Constants.balanceTxtColor),

          /// Build Income widget, Change colors in util/const.dart
          overviewWidget(
              context: context,
              type: 'Income',
              total: totalIncome.toString(),
              txColor: Constants.incomeTxtColor),

          /// Build Expenses widget, Change colors in util/const.dart
          overviewWidget(
              context: context,
              type: 'Expenses',
              total: totalExpenses.toString(),
              txColor: Constants.expenseTxtColor),

          /// Build Savings widget, Change colors in util/const.dart
          overviewWidget(
              context: context,
              type: 'Savings',
              total: totalSavings.toString(),
              txColor: Constants.savingTxtColor),
        ]));
  }

  /// Single overview widget
  Widget overviewWidget(
      {@required BuildContext context,
      String type,
      String total,
      Color txColor}) {
    return new Card(
      color: Color.fromRGBO(40, 40, 40, 100),
      child: new ListTile(
        dense: true,
        title:
            new Text('$type', style: TextStyle(fontSize: 12.0, color: txColor)),
        subtitle: new Text('$total',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14.0, color: txColor)),
        //onTap: () {}
      ),
    );
  }

  /// Transactions widget
  Widget buildTransactions({@required BuildContext context}) {
    return new Flexible(
        child: new Container(
      child: new FutureBuilder<List<Transactions>>(
        /// This calls the method fetchTransactionsFromDatabase()
        /// and builds the list of transactions
        future: fetchTransactionsFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        transactionsWidget(
                          context: context,
                          transactionId: snapshot.data[index].transactionId,
                          type: snapshot.data[index].type,
                          name: snapshot.data[index].name,
                          date: snapshot.data[index].transactionDate,
                          amount: _numberFormat(snapshot.data[index].amount),
                          textColor: Colors.white60,
                        ),
                      ]);
                });
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          return new Container(
            alignment: AlignmentDirectional.center,
            child: new CircularProgressIndicator(),
          );
        },
      ),
    ));
  }

  /// Single transaction widget
  Widget transactionsWidget(
      {@required BuildContext context,
      int transactionId,
      String type,
      String name,
      String date,
      String amount,
      Color textColor}) {
    Color txColor = _switchType(type);
    return new ListTile(
        contentPadding:
            new EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
        dense: true,
        title: new RichText(
          textAlign: TextAlign.start,
          text: new TextSpan(
            style: TextStyle(
              fontSize: 13,
              color: Color.fromRGBO(40, 40, 40, 100),
            ),
            children: <TextSpan>[
              new TextSpan(
                text: '$name',
                style: TextStyle(),
              ),
              new TextSpan(
                text: '\n$date',
                style: TextStyle(),
              ),
            ],
          ),
        ),
        trailing: new RichText(
          textAlign: TextAlign.end,
          text: new TextSpan(
            style: TextStyle(
              fontSize: 15,
              color: txColor,
            ),
            children: <TextSpan>[
              new TextSpan(
                text: '$amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ));
  }
}
