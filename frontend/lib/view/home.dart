import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/property_service.dart';
import 'package:proper_house_search/view/postcode_search_bar.dart';
import 'package:proper_house_search/view/properties/properties_list_view.dart';

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
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final GlobalKey<AutoCompleteState> _autoCompleteState =
      GlobalKey<AutoCompleteState>();

  final GlobalKey<PropertiesListViewState> _propertyListState =
      GlobalKey<PropertiesListViewState>();

  final service = PropertyService();
  var _isLoading = false;

  List<StationPostcode> selectedStations = [];

  Future<void> _onPressed() async {
    setState(() {
      _propertyListState.currentState?.notifier.listProperties = [];
      _propertyListState.currentState?.notifier.value = [];
      _isLoading = true;
    });
    await _propertyListState.currentState?.notifier.reload(selectedStations);
    setState(() {
      _isLoading = false;
      selectedStations = _autoCompleteState.currentState?.addedStations() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loaded();
  }

  Widget _loading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearProgressIndicator(),
    );
  }

  Widget _loaded() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          AutoComplete(
            key: _autoCompleteState,
            addedStations: selectedStations,
          ),
          if (_isLoading) _loading(),
          Expanded(
            child: PropertiesListView(
              key: _propertyListState,
              parent: this,
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
