import 'dart:math';

import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/services/property_service.dart';
import 'package:proper_house_search/view/search/search_form.dart';

import '../data/services/property_service.dart';
import 'properties/list/properties_list_view.dart';
import 'search/postcode_search_bar.dart';

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

  ViewState state = ViewState.empty;

  List<StationPostcode> selectedStations = [];

  Future<void> _onSearchPressed() async {
    setState(() {
      _propertyListState.currentState?.notifier.listProperties = [];
      _propertyListState.currentState?.notifier.value = [];
      _propertyListState.currentState?.pageNumber = 1;
      state = ViewState.loading;
    });
    await _propertyListState.currentState!.notifier
        .reload(selectedStations, 1)
        .then((_) {
      setState(() {
        if (_propertyListState
                .currentState?.notifier.listProperties.isNotEmpty ??
            false) {
          state = ViewState.loaded;
        } else if (_propertyListState.currentState?.notifier.errorMessage !=
            null) {
          state = ViewState.error;
        } else {
          state = ViewState.loaded;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    switch (state) {
      case ViewState.loaded:
        // body = _propertiesList();
        break;
      case ViewState.loading:
        body = _loading();
        break;
      case ViewState.empty:
        body = _message('Add stations to load properties');
        break;
      case ViewState.error:
        body = _message(
            'An error has occurred. \n\n ${_propertyListState.currentState?.notifier.errorMessage}');
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stations(),
        _filters(),
        if (body != null) body,
        _propertiesList(),
        _footer(),
      ],
    );
  }

  Widget _stations() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: AutoComplete(
        key: _autoCompleteState,
        addedStations: selectedStations,
        onStationsUpdated: (stations) {
          setState(() {
            selectedStations = stations;
          });
        },
      ),
    );
  }

  Widget _propertiesList() {
    return Expanded(
      child: PropertiesListView(
        key: _propertyListState,
        parent: this,
        propertyService: widget.propertyService,
      ),
    );
  }

  Widget _filters() {
    const padding = 16.0;

    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text('Filters'),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 120.0,
            maxHeight: max(
              120.0,
              MediaQuery.of(context).size.height * 0.20,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: padding),
                  child: SearchForm(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.network(
          "https://www.zoopla.co.uk/static/images/mashery/powered-by-zoopla-150x73.png",
          headers: {'Access-Control-Allow-Origin': '*'},
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
          child: ElevatedButton.icon(
            onPressed: selectedStations.isNotEmpty ? _onSearchPressed : null,
            label: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('Search'),
            ),
            icon: Icon(Icons.house_outlined),
          ),
        ),
      ],
    );
  }

  Widget _loading() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: LinearProgressIndicator(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: SelectableText(
                    'This was made by lazy developers so this could take a while. Maybe go make a cup of coffee ☕️.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(String message) => Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}

enum ViewState {
  loading,
  loaded,
  empty,
  error,
}
