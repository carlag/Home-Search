import 'dart:html' as html;

import 'package:flutter/material.dart';

import 'property.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Property> _properties = [];

  Future<void> _onPressed() async {
    final properties = await PropertyService().fetch();
    setState(() {
      _properties = properties;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _properties.length,
          itemBuilder: (context, index) {
            return ListTile(
              subtitle: Column(
                children: [
                  FlatButton(
                    onPressed: () => html.window.open(
                        '${_properties[index].listingURL}',
                        '${_properties[index].listingURL}'),
                    child: new Text('${_properties[index].displayableAddress}'),
                  ),
                  Text('£${_properties[index].price}'),
                  Text('${_properties[index].size.toString()}'),
                  Image.network('${_properties[index].imageURL}'),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressed,
        tooltip: 'Increment',
        child: Icon(Icons.house_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
