import 'package:finamoonproject/repos/sqlite_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:sweetalert/sweetalert.dart';
import 'categories.class.dart';

/// submit data
class SubmitData {
  String category;
}

class CategoryView extends StatefulWidget {
  final int categoryId;
  final String categoryType;
  final String categoryName;
  CategoryView({Key key, this.categoryId, this.categoryType, this.categoryName}): super(key: key);

  @override
  CategoryViewState createState() => new CategoryViewState();
}

class CategoryViewState extends State<CategoryView> {
  bool submitting                     = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  SubmitData submitData               = new SubmitData();
  var selectedType;
  var categoryController              = TextEditingController();

  /// Called when delete button is tapped to delete a category
  deleteCategoryById(categoryId) async {
    this.setState((){
      submitting = true;
    });
    var dbHelper = SqliteRepository();
    dbHelper.deleteCategory(context, categoryId);
    this.setState(() {
      submitting = false;
      Navigator.of(context).pop();
    });
  }

  /// Called when edit button is tapped to update a category
  submit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        var dbHelper = SqliteRepository();
        var category = Categories(
            widget.categoryId, selectedType, submitData.category
        );
        dbHelper.updateCategory(context, category);
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

  /// This method is called the first time a stateful
  /// widget is inserted in the widget-tree
  @override
  void initState() {
    super.initState();

    /// Sets type of tapped category in selectedType
    selectedType =  widget.categoryType;

    /// set category name of tapped category in
    /// the controller categoryController
    categoryController.text = widget.categoryName;
  }

  /// Contains the main widgets
  setContent() {
    if (widget.categoryId == 0) {
      return new Container();
    }

    if (submitting == true) {
      return new Center(
          child: new CircularProgressIndicator()
      );
    } else {
      return new Form(
        key: _formKey,
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

            /// Build type text widget
            new Text(
                "Type",
                style: Theme
                    .of(context)
                    .textTheme
                    .display1
                    .copyWith(
                    color: Color(0xff2c4260),
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
                  child: buildTypeCard('Income'),
                ),
                ResponsiveGridCol(
                  xs: 4,
                  md: 4,
                  child: buildTypeCard('Expense'),
                ),
                ResponsiveGridCol(
                  xs: 4,
                  md: 4,
                  child: buildTypeCard('Saving'),
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
                    color: Color(0xff2c4260),
                    fontSize: ScreenUtil(allowFontScaling: true)
                        .setSp(26)
                )
            ),

            new SizedBox(height: 10.0),

            /// Build category text form field
            TextFormField(
                controller: categoryController,
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
                  hintText: "Category",
                  labelStyle: new TextStyle(color: Colors.black),
                  fillColor: const Color.fromRGBO(255, 255, 255, 1),
                  filled: true,
                  errorStyle: new TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                  hintStyle: const TextStyle(
                      color: Colors.black, fontSize: 15.0),
                ),
                validator: (val) => val.length == 0 ? "Enter category" : null,
                onSaved: (String value) {
                  submitData.category = value;
                }
            ),

            new SizedBox(height: 20.0),

            /// Build material buttons
            new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        /// Calls submit method
                        submit(context);
                      },
                      color: const Color(0xff2d6bf9),
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
                            fontSize: ScreenUtil(allowFontScaling: true)
                                .setSp(26)
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
                        /// and deletes the category if confirmed
                        SweetAlert.show(context,
                            title: "Are your sure?",
                            subtitle: "This will permanently delete the category",
                            cancelButtonText: "Cancel",
                            confirmButtonText: "Delete",
                            showCancelButton: true,
                            onPress: (bool isConfirm) {
                              if (isConfirm) {
                                SweetAlert.show(
                                    context,
                                    subtitle: "Deleting category...",
                                    style: SweetAlertStyle.loading
                                );
                                new Future.delayed(new Duration(seconds: 1),(){
                                  deleteCategoryById(widget.categoryId);
                                  Navigator.of(context).pop();
                                });
                                return false;
                              } else {
                                return true;
                              }
                            }
                        );
                      },
                      color: const Color(0xffff735a),
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
                            fontSize: ScreenUtil(allowFontScaling: true)
                                .setSp(26)
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

  /// This builds the view category page UI
  @override
  Widget build(BuildContext context) {
    return setContent();
  }

  /// Type card widget
  Widget buildTypeCard(String cardTitle) {
    return InkWell(
        onTap: () {
          selectCard(cardTitle);
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