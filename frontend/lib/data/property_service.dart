import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proper_house_search/data/models/property.dart';

const _endpoint = 'http://127.0.0.1:80/properties/';

class PropertyService {
  static final client = http.Client();

  Future<List<Property>> fetchProperties(List<String> postcodes) async {
    final response = await client.post(
      _endpoint,
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

  void dispose() {
    client.close();
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
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
