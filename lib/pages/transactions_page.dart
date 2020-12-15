import 'package:finamoonproject/components/transaction/transaction.class.dart';
import 'package:finamoonproject/components/transaction/transaction.view.dart';
import 'package:finamoonproject/util/const.dart';
import 'package:finamoonproject/repos/sqlite_repository.dart';
import 'package:finamoonproject/util/singletouch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TransactionsPage extends StatefulWidget {
  TransactionsPage({Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new PageState();
  }
}

class PageState extends State<TransactionsPage> {
  dynamic preferences = SharedPreferences;
  DateTime initialDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  bool submitting = false;
  var balance;

  /// This method gets the current currency
  String _getCurrency() {
    final currency = preferences.getString("currency") ?? '';
    return currency;
  }

  /// This method converts a number into currency format with two decimals
  String _numberFormat(value) {
    return NumberFormat.currency(name: _getCurrency(), decimalDigits: 2).format(
        value).toString();
  }

  /// This method converts a type to its colors
  /// Income, Expense, Saving colors are in util/const.dart
  Color _switchType(type) {
    Color color;
    switch (type) {
      case "Income":
        {
          color = Constants.incomeBgColor;
        }
        break;
      case "Expense":
        {
          color = Constants.expenseBgColor;
        }
        break;
      case "Saving":
        {
          color = Constants.savingBgColor;
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
      fetchBalance();
    });
  }

  /// This method gets the current month's transactions from database
  Future<List<Transactions>> fetchTransactionsFromDatabase() async {
    var dbHelper = SqliteRepository();
    Future<List<Transactions>> finances = dbHelper.getTransactions(
        initialDate);
    return finances;
  }

  /// This method gets the balance of the chosen month from database
  fetchBalance() async {
    var dbHelper = SqliteRepository();
    List<Map> totals = await dbHelper.getTransactionsSum(initialDate);
    setState(() {
      balance = _numberFormat(
          totals[0]['income'] - (totals[0]['expenses'] + totals[0]['savings']));
    });
  }

  /// This method is called the first time a stateful
  /// widget is inserted in the widget-tree
  @override
  void initState() {
    super.initState();

    /// This forces the orientation to be portrait up only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    _initPreferences();
  }

  /// Builds the transactions page UI
  @override
  Widget build(BuildContext context) {
    return bodyWidget(context);
  }

  /// Body widget
  Widget bodyWidget(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(top: 50.0),
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
                  /// Define a fixed height of size 10
                  SizedBox(height: 10.0),
                  /// Build Balance widget
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: new Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color:  Color.fromRGBO(40, 40, 40, 100),
                      child: new ListTile(
                        dense: true,
                        title: new Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 15,
                              color: Constants.balanceTxtColor,
                            )
                        ),
                        subtitle: new Text(
                            (balance != null) ? balance : '0',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Constants.balanceTxtColor,
                            )
                        ),
                      ),
                    ),
                  ),
                  new SizedBox(height: 10.0),
                  buildTransactions(context: context),
                ],
              ),
            )
          ],
        )
    );
  }

  /// Header widget
  Widget headerWidget({@required BuildContext context}) {
    return new Container(
        padding: const EdgeInsets.all(0.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      Constants.transactionPageTxt,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    new SizedBox(height: 5.0),
                    new RichText(
                      text: new TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                            text: DateFormat.MMMM("en_US").format(selectedDate),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          new TextSpan(
                            text: ', ',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          new TextSpan(
                            text: DateFormat.y("en_US").format(selectedDate),
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),


            new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[

                /// Build calendar icon button to change months
                new Container(
                  height: 35.0,
                  child: new IconButton(
                    icon: new Icon(FontAwesomeIcons.calendarAlt),
                    tooltip: 'Calendar',
                    color: Colors.white,
                    iconSize: 25,
                    onPressed: () {
                      showMonthPicker(
                          context: context,
                          lastDate: DateTime(DateTime
                              .now()
                              .year + 1, 9),
                          initialDate: selectedDate ?? initialDate
                      ).then((date) {
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                            initialDate = selectedDate;
                            fetchTransactionsFromDatabase();
                            fetchBalance();
                          });
                        }
                      });
                    },
                  ),
                )

              ],
            )

          ],
        )
    );
  }

  /// Transactions widget
  Widget buildTransactions({@required BuildContext context}) {
    return new Flexible(
        child: new Container(
          child: new FutureBuilder<List<Transactions>>(
            future: fetchTransactionsFromDatabase(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new SingleTouchRecognizerWidget(
                    child: new ListView.builder(
                        padding: const EdgeInsets.all(0.0),
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  transactionsWidget(
                                    context: context,
                                    transactionId: snapshot.data[index]
                                        .transactionId,
                                    type: snapshot.data[index].type,
                                    name: snapshot.data[index].name,
                                    date: snapshot.data[index].transactionDate,
                                    amount: _numberFormat(
                                        snapshot.data[index].amount),
                                    textColor: Color(0xffffffff),
                                  ),
                                ]),
                          );
                        }
                    )
                );
              } else if (snapshot.hasError) {
                return new Text("${snapshot.error}");
              }
              return new Container(alignment: AlignmentDirectional.center,
                child: new CircularProgressIndicator(),);
            },
          ),
        )
    );
  }

  /// Single transaction widget
  Widget transactionsWidget({@required BuildContext context,
    int transactionId, String type, String name, String date,
    String amount, Color textColor}) {
    Color txColor = _switchType(type);
    return new Material(
        color: Color.fromRGBO(40, 40, 40, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new InkWell(
              child: new ListTile(
                  contentPadding: new EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 0.0),
                  dense: true,
                  title: new RichText(
                    textAlign: TextAlign.start,
                    text: new TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        new TextSpan(
                          text: '$name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        new TextSpan(
                            text: '\n$date'
                        ),
                      ],
                    ),
                  ),
                  trailing: new RichText(
                    textAlign: TextAlign.end,
                    text: new TextSpan(
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
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
                  )
              ),
              onTap: () {
                Future<void> future = showModalBottomSheet<Null>(
                    backgroundColor: Color.fromRGBO(40, 40, 40, 100),
                    context: context,
                    builder: (BuildContext context) {
                      return new Container(
                          child: new Container(
                              decoration: new BoxDecoration(
                                color: Color.fromRGBO(40, 40, 40, 100),
                                borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(15.0),
                                    topRight: const Radius.circular(15.0)
                                ),
                              ),
                              child: new Padding(
                                padding: const EdgeInsets.all(22.0),
                                child: TransactionView(
                                    transactionId: transactionId,
                                    currency: _getCurrency()
                                ),
                              )
                          )
                      );
                    }
                );
                future.then((void value) => fetchBalance());
              }
          ),
        )
    );
  }

}