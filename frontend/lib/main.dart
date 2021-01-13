import 'dart:async';

import 'package:flutter/material.dart';
import 'package:proper_house_search/view/home.dart';

void main() {
  runZonedGuarded(
    () => runApp(MyApp()),
    (error, stackTrace) {
      print(error);
      print(stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Proper-ty Search',
        key: Key('homepage'),
      ),
    );
  }
}
