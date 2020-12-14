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
              title: FlatButton(
                onPressed: () => html.window.open(
                    '${_properties[index].listingURL}',
                    '${_properties[index].listingURL}'),
                child: Text(
                  '${_properties[index].displayableAddress}',
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 2.0),
                ),
              ),
              subtitle: Column(
                children: [
                  Text(
                    '£${_properties[index].price}',
                    style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: 1.2),
                  ),
                  Text(
                    '${_properties[index].size.toString()}',
                    style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: 1.2),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        onPressed: () => html.window.open(
                            '${_properties[index].floorPlan[0] ?? ''}',
                            '${_properties[index].floorPlan[0] ?? ''}'), // handle your image tap here
                        child: Image.network(
                            '${_properties[index].floorPlan[0] ?? ''}',
                            height: 300),
                      ),
                      FlatButton(
                        onPressed: () => html.window.open(
                            '${_properties[index].imageURL ?? ''}',
                            '${_properties[index].imageURL ?? ''}'),
                        child: Image.network('${_properties[index].imageURL}',
                            height: 300),
                      ),
                    ],
                  ),
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
