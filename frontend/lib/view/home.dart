import 'package:flutter/material.dart';
import 'package:proper_house_search/data/property_service.dart';
import 'package:proper_house_search/view/postcode_search_bar.dart';
import 'package:proper_house_search/view/property_summary.dart';

import '../data/models/property.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);

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
    final properties = await PropertyService().fetchProperties();
    setState(() {
      _properties = properties;
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertiesCount = _properties.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Text('Number of results: $propertiesCount'),
          AutoComplete(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: propertiesCount,
              itemBuilder: (context, index) {
                return PropertySummary(
                  property: _properties[index],
                  key: Key('property_$index'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressed,
        tooltip: 'Search',
        child: Icon(Icons.house_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
