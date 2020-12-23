import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/secret.dart';

class PropertyService {
  static final client = http.Client();

  Future<List<Property>> fetchProperties() async {
    final request = await _fetchPropertiesRequest();
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final propertiesJSON =
          jsonDecode(response.body)['listing'] as List<dynamic>;
      final properties = propertiesJSON
          .map((property) => Property.fromJson(property))
          .where((property) => property.floorPlan?.isNotEmpty ?? false)
          .toList();
      return properties;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load property');
    }
  }

  void dispose() {
    client.close();
  }

  Future<String> _fetchPropertiesRequest() async {
    final secret = await SecretLoader(secretPath: "secrets.json").load();
    final listingsURL = 'https://api.zoopla.co.uk/api/v1/property_listings.js';
    final url = '$listingsURL?'
        'postcode=NW36HF'
        '&keywords=garden'
        '&radius=5.0'
        '&listing_status=sale'
        '&minimum_price=500000'
        '&maximum_price=800000'
        '&minimum_beds=2'
        // '&property_type=houses'
        '&page_size=100'
        '&api_key=${secret.zooplaApiKey}';
    return url;
  }
}
