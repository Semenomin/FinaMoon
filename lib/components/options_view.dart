import 'package:finamoonproject/pages/categories_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuView extends StatefulWidget {
  MenuView({Key key}): super(key: key);

  @override
  MenuViewState createState() => new MenuViewState();
}

class MenuViewState extends State<MenuView> {

  /// This method is called the first time a stateful
  /// widget is inserted in the widget-tree
  @override
  void initState() {
    super.initState();
  }

  /// Contains the main widgets
  setContent() {
      return ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[

            /// Builds the header text
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              title: new Text(
                  'Options',
                style: Theme.of(context).textTheme.display1.copyWith(
                  color: Color(0xff000000),
                  fontSize: ScreenUtil(allowFontScaling: true).setSp(40),
                  fontWeight: FontWeight.bold
                ),
              )
            ),
            
            /// Builds the list tile for categories
            ListTile(
              dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                leading: Icon(
                    FontAwesomeIcons.tags,
                  color: Color(0xff000000),
                  size: ScreenUtil(allowFontScaling: true).setSp(30),
                ),
                title: Text(
                    'Categories',
                  style: Theme.of(context).textTheme.display1.copyWith(
                    color: Color(0xff000000),
                    fontSize: ScreenUtil(allowFontScaling: true).setSp(30),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute(
                        builder: (_) => CategoriesListPage()
                    ),
                  );
                }
            ),

          ],
        );

  }

  /// This builds the options UI
  @override
  Widget build(BuildContext context) {
    return setContent();
  }

}

class CurrenciesListPage {
}