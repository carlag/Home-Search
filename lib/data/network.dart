import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:proper_house_search/data/secret.dart';

class NetworkManager {
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
}
