import 'dart:async';
import 'package:finamoonproject/components/category/categories.class.dart';
import 'package:finamoonproject/components/category/category.new.page.dart';
import 'package:finamoonproject/components/category/category.view.dart';
import 'package:finamoonproject/util/const.dart';
import 'package:finamoonproject/repos/sqlite_repository.dart';
import 'package:finamoonproject/util/singletouch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class CategoriesListPage extends StatefulWidget {
  CategoriesListPage({Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new PageState();
  }
}

class PageState extends State<CategoriesListPage> {
  bool submitting = false;

  /// Get list of categories from database
  Future<List<Categories>> getCategoriesFromDatabase() async {
    var dbHelper = SqliteRepository();
    Future<List<Categories>> categories = dbHelper.getCategories();
    return categories;
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

  /// This method is called the first time a stateful
  /// widget is inserted in the widget-tree
  @override
  void initState(){
    super.initState();

    /// This forces the orientation to be portrait up only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

  }

  /// Builds the categories page UI
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 828, height: 1792)
      ..init(context);
    return Scaffold(
      body: !submitting
          ? bodyWidget(context)
          : new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

  /// Body widget
  Widget bodyWidget(BuildContext context) {
    return new Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.bgColor,
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
                  new SizedBox(height: 10.0),

                  /// Build categories widget
                  buildCategories(context: context),

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

                    /// Header text, references to categoriesPageTxt
                    /// in util/const.dart
                    new Text(
                      Constants.categoriesPageTxt,
                      style: Theme
                          .of(context)
                          .textTheme
                          .display1
                          .copyWith(
                        color: Color(0xff000000),
                        fontSize: ScreenUtil(allowFontScaling: true).setSp(35),
                      ),
                    ),

                    new SizedBox(height: 5.0),

                  ],
                )
            ),

            /// Build new icon button to add new a category
            new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Container(
                  height: 35.0,
                  child: new IconButton(
                    padding: const EdgeInsets.all(0.0),
                    alignment: Alignment.centerRight,
                    icon: new Icon(FontAwesomeIcons.plus),
                    tooltip: 'New Category',
                    color: Color(0xff000000),
                    iconSize: ScreenUtil(allowFontScaling: true).setSp(35),
                    onPressed: () {
                      /// Shows the dialog for adding a new category
                      /// References to CategoryNew widget which is in :
                      /// components/category/category.new.dart
                      Future<void> future = showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(20.0)),
                              child: Container(
                                  child: new Padding(
                                    padding: const EdgeInsets.all(22.0),
                                    child: CategoryNew(),
                                  )
                              ),
                            );
                          });
                      /// This triggers when the above dialog is closed
                      /// It calls getCategoriesFromDatabase
                      future.then((void value) => getCategoriesFromDatabase());
                    },
                  ),
                )
              ],
            )
          ],
        )
    );
  }

  /// Categories widget
  Widget buildCategories({@required BuildContext context}) {
    return new Flexible(
        child: new Container(
          child: new FutureBuilder<List<Categories>>(
            /// This calls the method getCategoriesFromDatabase()
            /// and builds the list of categories
            future: getCategoriesFromDatabase(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                /// SingleTouchRecognizerWidget disables multi touch
                /// References to util/singletouch.dart
                return new SingleTouchRecognizerWidget(
                    child: new ListView.builder(
                      padding: const EdgeInsets.all(0.0),
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            categoriesWidget(
                              context: context,
                              id: snapshot.data[index].categoryId,
                              type: snapshot.data[index].categoryType,
                              category: snapshot.data[index].categoryName
                            ),
                          ]);
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

  /// Single category widget
  Widget categoriesWidget({@required BuildContext context,
    int id, String type, String category}) {
    Color txColor = _switchType(type);
    return new Material(
      color: Constants.bgColor,
        child: new InkWell(
          child: new ListTile(
            contentPadding: new EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
            dense:true,
            title: new Text('$category',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: ScreenUtil(allowFontScaling: true).setSp(26),
                fontWeight: FontWeight.bold,
                color: Color(0xff000000),
              ),
            ),
            trailing: new Text('$type',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: ScreenUtil(allowFontScaling: true).setSp(18),
                color: txColor,
              ),
            ),
          ),
          onTap: () {
            Future<void> future = showDialog(
              context: context,
              builder: (BuildContext context) {
                /// Shows the dialog to view/edit/delete a category
                /// References to the widget in :
                /// components/category/category.view.dart
                return new Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(20.0)),
                  child: Container(
                    child: new Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: CategoryView(
                          categoryId: id,
                          categoryName: category,
                          categoryType: type
                      ),
                    )
                  ),
                );
            });
            future.then((void value) => getCategoriesFromDatabase());
          }
      )
    );

  }

}