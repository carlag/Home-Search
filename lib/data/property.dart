import 'dart:convert';

import 'package:proper_house_search/data/network.dart';

class Property {
  String listingURL;
  dynamic size;
  String ocrSize;
  String imageURL;
  String status;
  String propertyType;
  dynamic price;
  String displayableAddress;
  List<dynamic> floorPlan;

  Property(this.listingURL, this.size, this.imageURL, this.price,
      this.displayableAddress);

  Property.fromJson(Map<String, dynamic> json)
      : listingURL = json['details_url'] ?? 'No listing URL',
        status = json['status'] ?? 'No status',
        propertyType = json['property_type'] ?? 'No property type',
        size = json['floor_area'] ?? 'No floor area',
        imageURL = json['image_url'] ?? 'No image',
        price = json['price'] ?? 'No price',
        displayableAddress = json['displayable_address'] ?? 'No Address',
        floorPlan = json['floor_plan'] ?? [];
}

class PropertyService {
  final networkManager = NetworkManager();

  Future<List<Property>> fetch() async {
    final response = await networkManager.fetchProperties();

    if (response.statusCode == 200) {
      final propertiesJSON =
          jsonDecode(response.body)['listing'] as List<dynamic>;
      final properties = propertiesJSON
          .map((property) => Property.fromJson(property))
          .where((property) => property.floorPlan.isNotEmpty)
          .toList();
      return properties;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load property');
    }
  }

  Future<String> fetchOcrSize(String floorPlanURL) async {
    final response = await NetworkManager.fetchArea(floorPlanURL);

    if (response.statusCode == 200) {
      final areaJSON = jsonDecode(response.body)['area'] as String;
      return areaJSON;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load ocr size');
    }
  }
}
