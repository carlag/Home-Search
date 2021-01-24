import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/services/property_service.dart';

class PropertiesNotifier extends ValueNotifier<List<Property>> {
  PropertiesNotifier(this.propertyService) : super([]);

  final PropertyService propertyService;

  List<StationPostcode> _postCodes = [];
  List<Property> listProperties = [];
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
    listProperties = <Property>[];
    _postCodes = newPostCodes; //newPostCodes.map((e) => e.postcode).toList();
    listProperties = await propertyService.fetchProperties(_postCodes);
    value = listProperties;
  }

  Future<void> getMore() async {
    if (!_loading) {
      _loading = true;
      final moreProperties =
          await propertyService.fetchMoreProperties(_postCodes);
      print("MORE PROPERTIES: ${moreProperties.length}");
      listProperties.addAll(moreProperties);
      _loading = false;
      value = listProperties;
    }
  }
}
