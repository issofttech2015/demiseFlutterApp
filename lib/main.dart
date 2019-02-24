import 'package:demise/page/homepage.dart';
import 'package:flutter/material.dart';
import 'login/loginpage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demise - v1',
      theme: new ThemeData(
          primaryColor: Color.fromRGBO(58, 66, 86, 1.0), fontFamily: 'Raleway'),
      home: LoginPage(),
      routes: setRoute(),
    );
  }

  Map<String, WidgetBuilder> setRoute() {
    return <String, WidgetBuilder>{
      '/logout': (BuildContext context) => new LoginPage(),
      '/homepage': (BuildContext context) => new HomePage(),
    };
  }
}
