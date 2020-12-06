import 'dart:async';
import 'package:finamoonproject/components/transaction/transaction.class.dart';
import 'package:finamoonproject/util/const.dart';
import 'package:finamoonproject/repos/sqlite_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_colorpicker/utils.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:custom_switch/custom_switch.dart';


/// submit data
class SubmitData {
  double amount;
  String name;
  String description;
}

class TransactionEditPage extends StatefulWidget {
  final int transactionId;
  TransactionEditPage({Key key, this.transactionId}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new TransactionEditPageState();
  }
}

class TransactionEditPageState extends State<TransactionEditPage> {
  bool submitting                     = false;
  bool isLoaded                       = false;
  bool isRecurring                    = false;
  DateTime transactionDate            = new DateTime.now();
  DateTime expiryDate                 = new DateTime.now();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final initialValue                  = DateTime.parse(
      new DateFormat('yyyy-MM-dd').format(new DateTime.now()));
  List<String> nullList               = <String>['Empty'];
  List category;
  SubmitData submitData               = new SubmitData();
  var _currentSelectedValue           = 'Salary';
  var selectedType                    = 'Income';
  var typeController                  = TextEditingController();
  var nameController                  = TextEditingController();
  var amountController                = TextEditingController();
  var descriptionController           = TextEditingController();
  var transactionDateController;
  var expiryDateController;

  /// This method updates a transaction
  updateTransaction(Transactions transaction) async {
    this.setState((){
      submitting = true;
    });
    var dbHelper = SqliteRepository();
    dbHelper.updateTransaction(context, widget.transactionId, transaction);
    this.setState(() {
      submitting = false;
      Navigator.of(context).pop();
    });
  }

  /// Called when edit button is tapped to update a transaction
  submit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        var dbHelper = SqliteRepository();
        var finance = Transactions(
            0,
            selectedType,
            submitData.amount,
            _currentSelectedValue,
            (submitData.description != null) ? submitData.description : "",
            new DateFormat("yyyy-MM-dd").format(transactionDate).toString(),
            (expiryDate != null) ? new DateFormat("yyyy-MM-dd").format(expiryDate) : "",
            isRecurring ? 1 : 0
        );
        dbHelper.updateTransaction(context, widget.transactionId, finance);
        Navigator.of(context).pop();
      });
    }
  }

  /// This puts the selected type in selectedType
  selectCard(cardTitle) {
    setState(() {
      selectedType = cardTitle;
    });
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
      selectedType = transaction.type;
      getCategoriesByType(selectedType);
      _currentSelectedValue          = transaction.name;
      amountController.text          = transaction.amount != null ? transaction.amount.toString() : null;
      descriptionController.text     = transaction.description != null ? transaction.description : null;
      transactionDateController = transaction.transactionDate != null
          ?  DateTime.parse(new DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction.transactionDate))) : null;
      expiryDateController      = transaction.expiryDate != null
          ? DateTime.parse(new DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction.expiryDate))) : null;
      isRecurring = transaction.recurring == 0 ? false : true;
    });
  }

  /// Gets the categories list for a given
  /// type (Income, Expense, Saving) from database
  Future<List<Map>> getCategoriesByType(String type) async {
    setState(() {
      isLoaded = false;
    });
    var dbHelper = SqliteRepository();
    List categories = await dbHelper.getCategoriesByType(type);
    setState(() {
      if(categories.length > 0){
        isLoaded = true;
        category = categories;
        _currentSelectedValue = category[0];
      }
    });
    return null;
  }

  /// This method is called the first time a stateful
  /// widget is inserted in the widget-tree
  @override
  void initState(){
    super.initState();
    getTransactionById();
  }

  /// This builds the edit transaction page UI
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 828, height: 1792)
      ..init(context);
    return Scaffold(
      body: !submitting
          ? bodyWidget(context)
          : new Center(
          child: new CircularProgressIndicator()
      ),
    );
  }

  /// Body widget
  Widget bodyWidget(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.bgColor,
        padding: const EdgeInsets.only(top: 50.0),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  /// Build Header widget
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: headerWidget(context: context),
                  ),

                  /// Define a fixed height of size 10
                  SizedBox(height: 10.0),

                  /// Build Form widget
                  Flexible(
                      child: formWidget(context: context)
                  )
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
        child: Row(
          children: <Widget>[
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    /// Header text widget
                    Text(
                      'Edit Transaction',
                      style: Theme
                          .of(context)
                          .textTheme
                          .display1
                          .copyWith(
                        color: Color(0xff000000),
                        fontSize: ScreenUtil(allowFontScaling: true).setSp(35),
                      ),
                    ),

                  ],
                )
            )
          ],
        )
    );
  }

  /// Form widget
  Widget formWidget({@required BuildContext context}) {
    return new Form(
        key: _formKey,
        child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            shrinkWrap: true,
            children: <Widget>[

              /// Build type text widget
              new Text(
                  "Type",
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1
                      .copyWith(
                      color: Color(0xff000000),
                      fontSize: ScreenUtil(allowFontScaling: true).setSp(26)
                  )
              ),

              /// Define a fixed height of size 10
              new SizedBox(height: 10.0),

              /// Build a responsive grid row for types
              ResponsiveGridRow(
                children: [
                  ResponsiveGridCol(
                    xs: 4,
                    md: 4,
                    child: buildTypeCard('Income', "Salary"),
                  ),
                  ResponsiveGridCol(
                    xs: 4,
                    md: 4,
                    child: buildTypeCard('Expense', "Bills"),
                  ),
                  ResponsiveGridCol(
                    xs: 4,
                    md: 4,
                    child: buildTypeCard('Saving', "Emergency fund"),
                  ),
                ],
              ),

              new SizedBox(height: 20.0),

              /// Build category text widget
              new Text(
                  "Category",
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1
                      .copyWith(
                      color: Color(0xff000000),
                      fontSize: ScreenUtil(allowFontScaling: true)
                          .setSp(26)
                  )
              ),

              new SizedBox(height: 10.0),

              /// Build category drop down button widget
              isLoaded ? FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Please select category',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0)),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(150, 150, 150, 1),
                            width: 0.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(150, 150, 150, 1),
                            width: 0.0),
                      ),
                      labelStyle: new TextStyle(color: Colors.black),
                      fillColor: const Color.fromRGBO(255, 255, 255, 1),
                      filled: true,
                      errorStyle: new TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      hintStyle: const TextStyle(
                          color: Colors.black, fontSize: 15.0),
                    ),
                    isEmpty: _currentSelectedValue == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currentSelectedValue,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            _currentSelectedValue = newValue;
                            state.didChange(newValue);
                          });
                        },
                        items: (isLoaded ? category : nullList).map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ) : Container(),

              new SizedBox(height: 20.0),

              /// Build amount text widget
              new Text(
                  "Amount",
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1
                      .copyWith(
                      color: Color(0xff000000),
                      fontSize: ScreenUtil(allowFontScaling: true)
                          .setSp(26)
                  )
              ),

              new SizedBox(height: 10.0),

              /// Build amount text form field
              TextFormField(
                  controller: amountController,
                  style: TextStyle(
                      color: Color(0xff2c4260)
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0)),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(150, 150, 150, 1),
                          width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(150, 150, 150, 1),
                          width: 0.0),
                    ),
                    hintText: "Amount",
                    labelStyle: new TextStyle(color: Colors.black),
                    fillColor: const Color.fromRGBO(255, 255, 255, 1),
                    filled: true,
                    errorStyle: new TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                    hintStyle: const TextStyle(
                        color: Colors.black, fontSize: 15.0),
                  ),
                  validator: (val) => val.length == 0 ? "Enter Amount" : null,
                  onSaved: (String value) {
                    submitData.amount = double.parse(value);
                  }
              ),

              new SizedBox(height: 20.0),

              /// Build note text widget
              new Text(
                  "Note - optional",
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1
                      .copyWith(
                      color: Color(0xff000000),
                      fontSize: ScreenUtil(allowFontScaling: true)
                          .setSp(26)
                  )
              ),

              new SizedBox(height: 10.0),

              /// Build note text widget
              TextFormField(
                  controller: descriptionController,
                  style: TextStyle(
                      color: Color(0xff2c4260)
                  ),
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0)),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(150, 150, 150, 1),
                          width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(150, 150, 150, 1),
                          width: 0.0),
                    ),
                    hintText: "Note",
                    labelStyle: new TextStyle(color: Colors.black),
                    fillColor: const Color.fromRGBO(255, 255, 255, 1),
                    filled: true,
                    errorStyle: new TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                    hintStyle: const TextStyle(
                        color: Colors.black, fontSize: 15.0),
                  ),
                  onSaved: (String value) {
                    submitData.description = value;
                  }
              ),

              new SizedBox(height: 20.0),

              /// Build date text widget
              new Text(
                  "Date",
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1
                      .copyWith(
                      color: Color(0xff000000),
                      fontSize: ScreenUtil(allowFontScaling: true).setSp(26)
                  )
              ),

              new SizedBox(height: 10.0),

              /// Build datetime field widget for transaction date
              DateTimeField(
                initialValue: transactionDateController ?? initialValue,
                readOnly: true,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(150, 150, 150, 1),
                        width: 0.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(150, 150, 150, 1),
                        width: 0.0),
                  ),
                  hintText: "Date",
                  labelStyle: new TextStyle(color: Colors.black),
                  fillColor: const Color.fromRGBO(255, 255, 255, 1),
                  filled: true,
                  errorStyle: new TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                  hintStyle: const TextStyle(
                      color: Colors.black, fontSize: 15.0),
                ),
                format: DateFormat("dd/MM/yyyy"),
                validator: (date) => date == null ? 'Invalid date' : null,
                onChanged: (date) =>
                    setState(() {
                      transactionDate = date;
                    }),
                onSaved: (date) =>
                    setState(() {
                      transactionDate = date;
                    }),
                onShowPicker: (context, currentValue) async {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
              ),

              new SizedBox(height: 20.0),

              /// Build expiry date text widget
              new Text(
                  "Expires - optional",
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1
                      .copyWith(
                      color: Color(0xff000000),
                      fontSize: ScreenUtil(allowFontScaling: true)
                          .setSp(26)
                  )
              ),

              new SizedBox(height: 10.0),

              /// Build datetime field widget for transaction expiry date
              DateTimeField(
                initialValue: expiryDateController,
                readOnly: true,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(150, 150, 150, 1),
                        width: 0.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(150, 150, 150, 1),
                        width: 0.0),
                  ),
                  hintText: "Date",
                  labelStyle: new TextStyle(color: Colors.black),
                  fillColor: const Color.fromRGBO(255, 255, 255, 1),
                  filled: true,
                  errorStyle: new TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                  hintStyle: const TextStyle(
                      color: Colors.black, fontSize: 15.0),
                ),
                format: DateFormat("dd/MM/yyyy"),
                onChanged: (date) =>
                    setState(() {
                      expiryDate = date;
                    }),
                onSaved: (date) =>
                    setState(() {
                      expiryDate = date;
                    }),
                onShowPicker: (context, currentValue) async {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
              ),

              new SizedBox(height: 20.0),

              /// Build recurring widget text and switch option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                      "Recurring",
                      style: Theme
                          .of(context)
                          .textTheme
                          .display1
                          .copyWith(
                          color: Color(0xff000000),
                          fontSize: ScreenUtil(allowFontScaling: true)
                              .setSp(26)
                      )
                  ),
                  CustomSwitch(
                    activeColor: Colors.blue,
                    value: isRecurring,
                    onChanged: (value) {
                      setState(() {
                        isRecurring = value;
                      });
                    },
                  ),
                ],
              ),
              new SizedBox(height: 20.0),

              /// Build material button
              MaterialButton(
                elevation: 2.0,
                highlightElevation: 2.0,
                shape: StadiumBorder(),
                minWidth: 100.0,
                height: 50.0,
                onPressed: () {
                  /// Calls submit method
                  submit(context);
                },
                color: Colors.blue,
                child: Text(
                  "Save",
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1
                      .copyWith(
                      color: useWhiteForeground(const Color(0xff2c4260))
                          ? const Color(0xffffffff)
                          : const Color(0xff000000),
                      fontSize: ScreenUtil(allowFontScaling: true)
                          .setSp(26)
                  ),
                ),
              ),
            ]
        )
    );
  }

  /// Type card widget
  Widget buildTypeCard(String cardTitle, String selectedCategory) {
    return InkWell(
        onTap: () {
          selectCard(cardTitle);
          getCategoriesByType(cardTitle);
        },
        child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            decoration: BoxDecoration(
              color: cardTitle == selectedType ? Colors.grey[700] : Colors.grey[100],
            ),
            height: 50.0,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(cardTitle,
                      style: TextStyle(
                        fontSize: ScreenUtil(allowFontScaling: true).setSp(20),
                        color:
                        cardTitle == selectedType ? Colors.white : Colors.grey.withOpacity(0.7),
                      )
                  ),
                ]
            )
        )
    );
  }

}
