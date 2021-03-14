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
  String? infoMessage;

  ViewState state = ViewState.initialized;

  List<StationPostcode> selectedStations = [];

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.initialized:
        errorMessage = null;
        infoMessage =
            'Add stations to load properties. The more stations you add the slower the search unfortunately.';
        break;
      case ViewState.loaded:
        errorMessage = null;
        infoMessage = null;
        break;
      case ViewState.loading:
        errorMessage = null;
        infoMessage = null;
        break;
      case ViewState.empty:
        errorMessage = null;
        infoMessage = 'No properties found. Try updating filters and stations.';
        break;
      case ViewState.error:
        infoMessage = null;
        errorMessage = 'An error has occurred. \n\n ${errorMessage}';
        break;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _stations(),
        Filters(key: _filtersState),
        if (errorMessage != null) _errorMessage,
        if (infoMessage != null) _infoMessage,
        if (state == ViewState.loading) loading(context),
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
            onPressed: selectedStations.isNotEmpty ? searchNew : null,
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

  Widget get _errorMessage =>
      _message(errorMessage!, TextStyle(color: Colors.red));

  Widget get _infoMessage =>
      _message(infoMessage!, TextStyle(color: Colors.black));

  Widget _message(String message, TextStyle style) => Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message, textAlign: TextAlign.center, style: style),
        ),
      );

  Future<void> searchMore({required int pageNumber}) async {
    if (_validate()) {
      await _performSearch(pageNumber: pageNumber);
    }
  }

  Future<void> searchNew() async {
    if (_validate()) {
      setState(() {
        _propertyListState.currentState?.notifier.listProperties = [];
        _propertyListState.currentState?.notifier.value = [];
      });
      _performSearch(pageNumber: 1);
    }
  }

  Future<void> _performSearch({int pageNumber = 1}) async {
    final propertiesBefore =
        _propertyListState.currentState?.notifier.listProperties.length;
    setState(() {
      _propertyListState.currentState?.pageNumber = pageNumber;
      state = ViewState.loading;
    });
    await _propertyListState.currentState!.notifier
        .reload(selectedStations, pageNumber,
            _filtersState.currentState!.filterValues)
        .then((_) {
      final propertiesAfter =
          _propertyListState.currentState?.notifier.listProperties.length;
      setState(() {
        if (propertiesAfter == propertiesBefore) {
          state = ViewState.empty;
        } else if (_propertyListState
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

  bool _validate() {
    // only validate if the form exists
    final filterValues = _filtersState.currentState?.filterValues;
    // TODO: Remove the defaults from the BE code
    int min = filterValues![FilterTitles.minPrice] ?? 500000;
    int max = filterValues[FilterTitles.maxPrice] ?? 850000;
    if (_filtersState.currentState == null) {
      setState(() {
        state = ViewState.error;
        errorMessage = 'Invalid form data. Current state is null';
      });
      return false;
    } else if (filterValues.isNotEmpty &&
        !_filtersState.currentState!.validate()) {
      setState(() {
        state = ViewState.error;
        errorMessage = 'Invalid form data. Expand Filters to view errors.';
      });
      return false;
    } else if (max < min) {
      setState(() {
        state = ViewState.error;
        errorMessage = 'Invalid form data. Min is greater than max';
      });
      return false;
    }

    return true;
  }
}

Widget get _logo => Image.network(
      "https://www.zoopla.co.uk/static/images/mashery/powered-by-zoopla-150x73.png",
      headers: {'Access-Control-Allow-Origin': '*'},
    );
