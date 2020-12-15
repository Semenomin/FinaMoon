import 'package:finamoonproject/components/transaction/transaction.class.dart';
import 'package:finamoonproject/repos/sqlite_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/utils.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sweetalert/sweetalert.dart';

import 'transaction.edit.page.dart';

/// Transaction data
class TransactionData {
  String name = "";
  String description = "";
  String transactionDate = "";
  String expiryDate;
  String expiresIn = "";
  String amount = "";
  String duration = "";
  String durationPassed = "";
  String totalAmount = "";
  String totalAmountPaid = "";
  String totalAmountPaidPercent = "";
  String totalAmountUnpaid = "";
  String totalAmountUnpaidPercent = "";
}

class TransactionView extends StatefulWidget {
  final int transactionId;
  final String currency;
  TransactionView({Key key, this.transactionId, this.currency}): super(key: key);

  @override
  TransactionViewState createState() => new TransactionViewState();
}

class TransactionViewState extends State<TransactionView> {
  Transactions transaction;
  bool submitting = false;
  TransactionData transactionData = new TransactionData();

  /// This method converts a number into currency format
  /// for a given currency, digits and format
  String customNumberFormat(String currency, int digits, double format) {
    return NumberFormat.currency(name: currency, decimalDigits: digits).format(
        format);
  }

  /// Get transaction details from database
  getTransactionById() async {
    this.setState(() {
      submitting = true;
    });
    var dbHelper = SqliteRepository();
    Transactions transaction = await dbHelper.getTransactionById(widget.transactionId);
    this.setState(() {
      submitting = false;
      transactionData.amount = customNumberFormat('', 2, transaction.amount);
      transactionData.name = transaction.name;
      transactionData.description = transaction.description;
      transactionData.transactionDate = new DateFormat('dd/MM/yyyy').format(
          DateTime.parse(transaction.transactionDate));

      if(transaction.expiryDate != null) {
        transactionData.expiryDate = new DateFormat('dd/MM/yyyy').format(
            DateTime.parse(transaction.expiryDate));

        var today = Jiffy().format("yyyy-MM-dd");
        var startDate = Jiffy(transaction.transactionDate, "yyyy-MM-dd");
        var expiryDate = Jiffy(transaction.expiryDate, "yyyy-MM-dd");

        int totalMonths = expiryDate.diff(startDate, "month").abs();
        int paidMonths = expiryDate.diff(today, "month") <= 0
            ? totalMonths : startDate.diff(today, "month").abs();

        transactionData.duration = totalMonths.toString();
        transactionData.durationPassed = paidMonths.toString();

        transactionData.totalAmount = customNumberFormat(
            widget.currency, 2, totalMonths * transaction.amount);

        transactionData.totalAmountPaid = customNumberFormat(
            widget.currency, 2, paidMonths * transaction.amount);

        transactionData.totalAmountPaidPercent =
            (((paidMonths * transaction.amount) /
                (totalMonths * transaction.amount)) * 100).round().toString();

        transactionData.totalAmountUnpaid = customNumberFormat(
            widget.currency, 2, totalMonths * transaction.amount -
            paidMonths * transaction.amount);

        transactionData.totalAmountUnpaidPercent =
            ((((totalMonths * transaction.amount -
                paidMonths * transaction.amount)) /
                (totalMonths * transaction.amount)) * 100).round().toString();
      }
    });
  }

  /// Called when delete button is tapped to delete a transaction
  deleteTransactionById(transactionId) async {
    this.setState((){
      submitting = true;
    });
    var dbHelper = SqliteRepository();
    dbHelper.deleteTransaction(context, transactionId);
    this.setState(() {
      submitting = false;
      Navigator.of(context).pop();
    });
  }

  /// This method is called the first time a stateful
  /// widget is inserted in the widget-tree
  @override
  void initState() {
    super.initState();
    getTransactionById();
  }

  /// Contains the main widgets
  setContent() {
    if (widget.transactionId == 0) {
      return new Container();
    }

    if (submitting == true && transaction != null) {
      return new Center(
          child: new CircularProgressIndicator()
      );
    } else {
      return new Form(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(
              top: 15.0,
              left: 10.0,
              right: 10.0,
              bottom: MediaQuery.of(context).viewInsets.bottom
          ),
          children: <Widget>[

            /// Build transaction name text widget
            new Text(
              transactionData.name,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1
                  .copyWith(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
              ),
            ),

            /// Define a fixed height of size 5
            SizedBox(height: 5.0),

            /// Build transaction note text widget
            new Text(
              transactionData.description,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1
                  .copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),

            SizedBox(height: 10.0),

            /// Build transaction date and transaction expiry date text widget
            new Text(
              transactionData.transactionDate
                  + ((transactionData.expiryDate != null)
                  ? ' - ' + transactionData.expiryDate.toString() : ''),
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1
                  .copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),

            SizedBox(height: 20.0),

            /// Build transaction amount text widget
            new Text(
              transactionData.amount,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1
                  .copyWith(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold
              ),
            ),

            SizedBox(height: 0.0),

            /// Build transaction currency text widget
            new Text(
              widget.currency,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1
                  .copyWith(
                color: Colors.white,
                fontSize: 25,
              ),
            ),

            SizedBox(height: 20.0),


            /// Build transaction total duration text widget
            (transactionData.expiryDate != null) ?
            new Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                          "Duration (Months)",
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          )
                      ),
                      new Text(
                          transactionData.duration.toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ]
                )
            ) : new Container(),

            /// Build transaction duration passed text widget
            (transactionData.expiryDate != null) ?
            new Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                          "Duration passed (Months)",
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          )
                      ),
                      new Text(
                          transactionData.durationPassed.toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ]
                )
            ) : new Container(),

            /// Build transaction total amount text widget
            (transactionData.expiryDate != null) ?
            new Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                          "Total Amount",
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          )
                      ),
                      new Text(
                          transactionData.totalAmount.toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ]
                )
            ) : new Container(),

            /// Build transaction amount paid text widget
            (transactionData.expiryDate != null) ?
            new Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                          "Total Paid",
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          )
                      ),
                      new Text(
                          transactionData.totalAmountPaid.toString()
                              + " (" + transactionData.totalAmountPaidPercent + "%)",
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ]
                )
            ) : new Container(),

            /// Build transaction amount unpaid text widget
            (transactionData.expiryDate != null) ?
            new Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                          "Total Unpaid",
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          )
                      ),
                      new Text(
                          transactionData.totalAmountUnpaid.toString()
                              + " ("+ transactionData.totalAmountUnpaidPercent + "%)",
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ]
                )
            ) : new Container(),

            (transactionData.expiryDate != null)
                ? SizedBox(height: 20.0) : SizedBox(height: 0.0),

            /// Build material buttons
            new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: MaterialButton(
                      elevation: 1.0,
                      highlightElevation: 1.0,
                      shape: StadiumBorder(),
                      minWidth: 100.0,
                      height: 37.0,
                      onPressed: () {
                        /// Shows transaction edit page
                        Future<void> future = Navigator.push(context, new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new TransactionEditPage(
                                transactionId: widget.transactionId
                            )
                        ));
                        future.then((void value) => Navigator.of(context).pop());
                      },
                      color: Color.fromRGBO(102, 171, 0, 100),
                      child: Text(
                        "Edit",
                        style: Theme
                            .of(context)
                            .textTheme
                            .display1
                            .copyWith(
                            color: useWhiteForeground(const Color(0xff2c4260))
                                ? const Color(0xffffffff)
                                : const Color(0xff000000),
                            fontSize: 20
                        ),
                      ),
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(5.0),
                    child: MaterialButton(
                      elevation: 1.0,
                      highlightElevation: 1.0,
                      shape: StadiumBorder(),
                      minWidth: 100.0,
                      height: 37.0,
                      onPressed: () {
                        /// Shows a confirmation alert
                        /// and deletes the transaction if confirmed
                        SweetAlert.show(context,
                            title: "Are your sure?",
                            subtitle: "This will permanently delete the transaction",
                            cancelButtonText: "Cancel",
                            confirmButtonText: "Delete",
                            showCancelButton: true,
                            onPress: (bool isConfirm) {
                              if (isConfirm) {
                                SweetAlert.show(
                                    context,
                                    subtitle: "Deleting transaction...",
                                    style: SweetAlertStyle.loading
                                );
                                new Future.delayed(new Duration(seconds: 1),(){
                                  deleteTransactionById(widget.transactionId);
                                  Navigator.of(context).pop();
                                });
                                return false;
                              } else {
                                return true;
                              }
                            }
                        );
                      },
                      color: Color.fromRGBO(102, 171, 0, 100),
                      child: Text(
                        "Delete",
                        style: Theme
                            .of(context)
                            .textTheme
                            .display1
                            .copyWith(
                            color: useWhiteForeground(const Color(0xff2c4260))
                                ? const Color(0xffffffff)
                                : const Color(0xff000000),
                            fontSize: 20
                        ),
                      ),
                    ),
                  )
                ]
            )

          ],
        ),
      );
    }
  }

  /// This builds the view transaction page UI
  @override
  Widget build(BuildContext context) {
    return setContent();
  }

}