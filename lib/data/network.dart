import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:proper_house_search/data/secret.dart';

class NetworkManager {
  static final client = new http.Client();
  static const zooplaEndpoint = 'https://lc.zoocdn.com/';
  static const ocrServiceEndpoint = 'http://127.0.0.1:80';

  Future<http.Response> fetchProperties() async {
    final secret = await SecretLoader(secretPath: "secrets.json").load();
    final listingsURL = 'https://api.zoopla.co.uk/api/v1/property_listings.js';
    final url = '$listingsURL?'
        'postcode=nw36hf'
        '&keywords=garden'
        '&radius=5.0'
        '&listing_status=sale'
        '&minimum_price=500000'
        '&maximum_price=800000'
        '&minimum_beds=2'
        '&property_type=houses'
        '&page_size=100'
        '&api_key=${secret.apiKey}';
    print(url);
    return http.get(url);
  }

  static Future<http.Response> fetchArea(String floorPlanURL) async {
    if (floorPlanURL.endsWith('jpg')) {
      floorPlanURL = floorPlanURL.replaceFirst('.jpg', '');
      floorPlanURL =
          floorPlanURL.replaceFirst(zooplaEndpoint, '$ocrServiceEndpoint/jpg/');
    } else if (floorPlanURL.endsWith('pdf')) {
      floorPlanURL.replaceFirst('.pdf', '');
      floorPlanURL =
          floorPlanURL.replaceFirst(zooplaEndpoint, '$ocrServiceEndpoint/pdf/');
    } else {
      throw ('Unhandled type: $floorPlanURL');
    }

    print('FLOOR PLAN URL: $floorPlanURL');
    return client.get(
      floorPlanURL,
      headers: {"Access-Control-Allow-Origin": "*"},
    );
  }
}
