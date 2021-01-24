import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';

import '../models/access_token.dart';
import '../models/mark_type.dart';

const _morePropertiesEndpoint = 'http://127.0.0.1:80/properties/';
const _propertiesEndpoint = 'http://127.0.0.1:80/properties/reset/';
const _markEndpoint = 'http://127.0.0.1:80/mark';

class PropertyService {
  static final client = http.Client();
  final AccessToken accessToken;

  PropertyService(this.accessToken);

  Future<List<Property>> fetchMoreProperties(
      List<StationPostcode> stations) async {
    final postcodes = stations.map((e) => e.postcode).toList();
    final response = await client.post(
      _morePropertiesEndpoint,
      headers: _headers(),
      body: _body(postcodes),
    );

    if (response.statusCode == 200) {
      final propertiesJSON =
          jsonDecode(response.body)['properties'] as List<dynamic>;
      final properties = propertiesJSON
          .map((property) => Property.fromJson(property))
          .where((property) => property.floorPlan?.isNotEmpty ?? false)
          .toList();
      return properties;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load property: ${response.body}');
    }
  }

  Future<List<Property>> fetchProperties(List<StationPostcode> stations) async {
    final postcodes = stations.map((e) => e.postcode).toList();
    final response = await client.post(
      _propertiesEndpoint,
      headers: _headers(),
      body: _body(postcodes),
    );

    print(response.statusCode);
    print(response.headers);
    print(response.request.headers);

    if (response.statusCode == 200) {
      final propertiesJSON =
          jsonDecode(response.body)['properties'] as List<dynamic>;
      final properties = propertiesJSON
          .map((property) => Property.fromJson(property))
          .where((property) => property.floorPlan?.isNotEmpty ?? false)
          .toList();
      return properties;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load property: ${response.body}');
    }
  }

  Future<bool?> markProperty(String listingUrl, MarkType markType) async {
    final encodedListingUrl = Uri.encodeComponent(listingUrl);
    final url = '$_markEndpoint/$encodedListingUrl/as/${markType.string}';

    final response = await client.get(
      url,
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return true;
    }
    if (response.statusCode != 200) {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load property: ${response.body}');
    }
  }

  void dispose() {
    client.close();
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${accessToken.token}',
    };
    return headers;
  }

  String _body(List<String> postcodes) {
    final body = jsonEncode(
      <String, List<String>>{
        'postcodes': postcodes,
      },
    );
    return body;
  }
}
