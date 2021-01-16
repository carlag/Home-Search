import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/mark_type.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
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
  final GlobalKey<AutoCompleteState> _autoCompleteState =
      GlobalKey<AutoCompleteState>();

  final service = PropertyService();

  var _isLoading = false;
  List<Property> _properties = [];
  List<StationPostcode> _stations = [];

  Future<void> _onPressed() async {
    setState(() {
      _isLoading = true;
      _properties = [];
      _stations = _autoCompleteState.currentState?.addedStations() ?? [];
    });
    final stations = _autoCompleteState.currentState?.addedStations() ?? [];
    final postcodes = stations.map((e) => e.postcode).toList();
    final properties = await service.fetchProperties(postcodes);
    setState(() {
      _isLoading = false;
      _properties = properties;
    });
  }

  Future<void> _onMorePressed() async {
    setState(() {
      _isLoading = true;
      _stations = _autoCompleteState.currentState?.addedStations() ?? [];
    });
    final stations = _autoCompleteState.currentState?.addedStations() ?? [];
    final postcodes = stations.map((e) => e.postcode).toList();
    final properties = await service.fetchMoreProperties(postcodes);
    setState(() {
      _isLoading = false;
      _properties
          .removeWhere((property) => property.markType == MarkType.rejected);
      _properties.addAll(properties);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _loading();
    }
    return _loaded();
  }

  Widget _loading() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }

  Widget _loaded() {
    final propertiesCount = _properties.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Text('Number of results: $propertiesCount'),
          AutoComplete(
            key: _autoCompleteState,
            addedStations: _stations,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: propertiesCount + 1,
              itemBuilder: (context, index) {
                // last item
                if (index == propertiesCount) {
                  return FlatButton(
                      onPressed: _onMorePressed, child: Text('Fetch more'));
                }
                return PropertySummary(
                  property: _properties[index],
                  key: Key('property_$index'),
                  service: service,
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
