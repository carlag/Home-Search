import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/property_service.dart';

class PropertiesNotifier extends ValueNotifier<List<Property>> {
  PropertiesNotifier() : super([]);

  final service = PropertyService();

  List<StationPostcode> _postCodes = [];
  List<Property> _listProperties = [];
  bool _loading = false;

  @override
  List<Property> get value => _value;
  List<Property> _value = [];
  @override
  set value(List<Property> newValue) {
    _value = newValue;
    notifyListeners();
  }

  Future<void> reload(List<StationPostcode> newPostCodes) async {
    _listProperties = <Property>[];
    _postCodes = newPostCodes; //newPostCodes.map((e) => e.postcode).toList();
    _listProperties = await service.fetchProperties(_postCodes);
    value = _listProperties;
  }

  Future<void> getMore() async {
    if (!_loading) {
      _loading = true;
      final moreProperties = await service.fetchMoreProperties(_postCodes);
      print("MORE PROPERTIES: ${moreProperties.length}");
      _listProperties.addAll(moreProperties);
      _loading = false;
      value = _listProperties;
    }
  }
}
