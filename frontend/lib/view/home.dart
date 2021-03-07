import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/services/property_service.dart';

import '../data/services/property_service.dart';
import 'properties/list/properties_list_view.dart';
import 'search/postcode_search_bar.dart';
import 'search/search_form.dart';

class Home extends StatefulWidget {
  Home({required Key key, required this.title, required this.propertyService})
      : super(key: key);

  final String title;
  final PropertyService propertyService;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final GlobalKey<AutoCompleteState> _autoCompleteState =
      GlobalKey<AutoCompleteState>();

  final GlobalKey<PropertiesListViewState> _propertyListState =
      GlobalKey<PropertiesListViewState>();

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
    const padding = 16.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text('Filters'),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: padding,
                        right: padding,
                        bottom: padding,
                      ),
                      child: AutoComplete(
                        key: _autoCompleteState,
                        addedStations: selectedStations,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: padding),
                      child: SearchForm(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_isLoading) _loading(),
        Expanded(
          child: PropertiesListView(
            key: _propertyListState,
            parent: this,
            propertyService: widget.propertyService,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.network(
              "https://www.zoopla.co.uk/static/images/mashery/powered-by-zoopla-150x73.png",
              headers: {'Access-Control-Allow-Origin': '*'},
            ),
            // FloatingActionButton(
            //   onPressed: _onPressed,
            // ),
          ],
        ),
      ],
    );
  }

  Widget _loading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearProgressIndicator(),
    );
  }
}
