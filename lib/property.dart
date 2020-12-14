import 'dart:convert';

import 'package:proper_house_search/network.dart';

class Property {
  String listingURL;
  dynamic size;
  String imageURL;
  String price;
  String displayableAddress;
  List<dynamic> floorPlan;

  Property(this.listingURL, this.size, this.imageURL, this.price,
      this.displayableAddress);

  Property.fromJson(Map<String, dynamic> json)
      : listingURL = json['details_url'],
        size = json['floor_area'],
        imageURL = json['image_url'],
        price = json['price'],
        displayableAddress = json['displayable_address'],
        floorPlan = json['floor_plan'];
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
          .toList();
      return properties;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}
