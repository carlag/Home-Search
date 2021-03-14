import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/services/property_service.dart';
import 'package:proper_house_search/view/loading.dart';
import 'package:proper_house_search/view/search/filters.dart';
import 'package:proper_house_search/view/view_state.dart';

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
  final _autoCompleteState = GlobalKey<AutoCompleteState>();
  final _propertyListState = GlobalKey<PropertiesListViewState>();
  final _filtersState = GlobalKey<FiltersState>();
  String? errorMessage;
  ViewState state = ViewState.empty;

  List<StationPostcode> selectedStations = [];

  @override
  Widget build(BuildContext context) {
    Widget? body;
    switch (state) {
      case ViewState.loaded:
        // body = _propertiesList();
        break;
      case ViewState.loading:
        body = loading(context);
        break;
      case ViewState.empty:
        body = _message('Add stations to load properties');
        break;
      case ViewState.error:
        body = _message('An error has occurred. \n\n ${errorMessage}');
        break;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _stations(),
        Filters(key: _filtersState),
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

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _logo,
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
          child: ElevatedButton.icon(
            onPressed: selectedStations.isNotEmpty ? performSearch : null,
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

  Widget _message(String message) => Expanded(
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: state == ViewState.error
                            ? Colors.red
                            : Colors.black)),
              ),
            ),
          ),
        ),
      );

  Future<void> performSearch({int pageNumber = 1}) async {
    // only validate if the form exists
    final filterValues = _filtersState.currentState?.filterValues;
    if (_filtersState.currentState != null &&
        filterValues!.isNotEmpty &&
        !_filtersState.currentState!.validate()) {
      setState(() {
        state = ViewState.error;
        errorMessage = 'Invalid form data. Expand Filters to view errors.';
      });
      return;
    }

    // TODO: Remove the defaults from the BE code
    int min = int.parse(filterValues![FilterTitles.minPrice] ?? '500000');
    int max = int.parse(filterValues[FilterTitles.maxPrice] ?? '850000');
    if (max <= min) {
      setState(() {
        state = ViewState.error;
        errorMessage = 'Invalid form data. Min is greater than max';
      });
      return;
    }

    setState(() {
      _propertyListState.currentState?.notifier.listProperties = [];
      _propertyListState.currentState?.notifier.value = [];
      _propertyListState.currentState?.pageNumber = pageNumber;
      state = ViewState.loading;
    });
    await _propertyListState.currentState!.notifier
        .reload(selectedStations, 1, _filtersState.currentState!.filterValues)
        .then((_) {
      setState(() {
        if (_propertyListState
                .currentState?.notifier.listProperties.isNotEmpty ??
            false) {
          state = ViewState.loaded;
        } else if (_propertyListState.currentState?.notifier.errorMessage !=
            null) {
          state = ViewState.error;
          errorMessage = _propertyListState.currentState?.notifier.errorMessage;
        } else {
          state = ViewState.loaded;
        }
      });
    });
  }
}

Widget get _logo => Image.network(
      "https://www.zoopla.co.uk/static/images/mashery/powered-by-zoopla-150x73.png",
      headers: {'Access-Control-Allow-Origin': '*'},
    );
