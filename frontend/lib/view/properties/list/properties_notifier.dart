import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/services/property_service.dart';

class PropertiesNotifier extends ValueNotifier<List<Property>> {
  PropertiesNotifier(this.propertyService) : super([]);

  final PropertyService propertyService;

  List<Property> listProperties = [];
  String? errorMessage;

  @override
  List<Property> get value => _value;
  List<Property> _value = [];
  @override
  set value(List<Property> newValue) {
    _value = newValue;
    notifyListeners();
  }

  Future<void> reload(List<StationPostcode> postCodes, int pageNumber) async {
    print('started');
    final response =
        await propertyService.fetchPropertiesPoll(postCodes, pageNumber);
    print('finished');
    listProperties.addAll(response.item1 ?? []);
    value = listProperties;
    errorMessage = response.item2;
  }
}
