import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';

import '../models/access_token.dart';
import '../models/mark_type.dart';
import 'endpoints.dart';

class PropertyService {
  static final client = http.Client();
  final AccessToken accessToken;

  PropertyService(this.accessToken);

  // Future<List<Property>> fetchMoreProperties(
  //     List<StationPostcode> stations) async {
  //   final postcodes = stations.map((e) => e.postcode).toList();
  //   final response = await client.post(
  //     morePropertiesEndpoint,
  //     headers: _headers(),
  //     body: _body(postcodes),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final propertiesJSON =
  //         jsonDecode(response.body)['properties'] as List<dynamic>;
  //     final properties = propertiesJSON
  //         .map((property) => Property.fromJson(property))
  //         .where((property) => property.floorPlan?.isNotEmpty ?? false)
  //         .toList();
  //     return properties;
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load property: ${response.body}');
  //   }
  // }
  //
  // Future<List<Property>> fetchProperties(List<StationPostcode> stations) async {
  //   final postcodes = stations.map((e) => e.postcode).toList();
  //   final response = await client.post(
  //     propertiesEndpoint,
  //     headers: _headers(),
  //     body: _body(postcodes),
  //   );
  //
  //   print(response.statusCode);
  //   print(response.headers);
  //   print(response.request.headers);
  //
  //   if (response.statusCode == 200) {
  //     final propertiesJSON =
  //         jsonDecode(response.body)['properties'] as List<dynamic>;
  //     final properties = propertiesJSON
  //         .map((property) => Property.fromJson(property))
  //         .where((property) => property.floorPlan?.isNotEmpty ?? false)
  //         .toList();
  //     return properties;
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load property: ${response.body}');
  //   }
  // }

  Future<bool?> markProperty(String listingUrl, MarkType markType) async {
    final encodedListingUrl = Uri.encodeComponent(listingUrl);
    final url = '$markEndpoint/$encodedListingUrl/as/${markType.string}';

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

  Future<List<Property>> fetchPropertiesPoll(
      List<StationPostcode> stations) async {
    final postcodes = stations.map((e) => e.postcode).toList();

    final requestId = shortHash(UniqueKey());
    var retryCount = 0;
    var maxRetryCount = 90;
    List<Property>? properties;

    while (properties == null && retryCount <= maxRetryCount) {
      print('Poll Count: $retryCount, ${DateTime.now()}');

      retryCount++;
      properties = await _poll(postcodes, requestId);
      await Future.delayed(const Duration(seconds: 10), () {});
    }

    if (properties == null) {
      throw Exception('Timed out');
    }

    return properties;
  }

  Future<List<Property>?> _poll(
    List<String> postcodes,
    String requestId, {
    int pageNumber = 1,
  }) async {
    print('REQUEST ID: $requestId');
    final uri = Uri.http(
      'localhost',
      '$propertiesPollPath/$requestId',
      {
        'page_number': '$pageNumber',
        'min_area': '120',
      },
    );
    print(uri);
    final response = await client.post(
      uri,
      headers: _headers(),
      body: _body(postcodes),
    );

    print(response.statusCode);
    print(response.headers);
    print(response.request.headers);

    // first request: 201, null
    // second request: 200, null
    // last request: 200, [] or [data]
    if (response.statusCode == 200) {
      if (response.body == null || response.body == 'null') {
        return null;
      }
      final propertiesJSON =
          jsonDecode(response.body)['properties'] as List<dynamic>;
      final properties = propertiesJSON
          .map((property) => Property.fromJson(property))
          .where((property) => property.floorPlan?.isNotEmpty ?? false)
          .toList();
      return properties;
    } else if (response.statusCode == 201) {
      // this should be the response for the first request only.
      // should get null back.
      if (response.body == null || response.body == 'null') {
        return null;
      } else {
        throw Exception('Failed to initiate poll "${response.body}"');
      }
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
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${accessToken.token}',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
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
