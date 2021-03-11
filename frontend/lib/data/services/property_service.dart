import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:tuple/tuple.dart';

import '../models/access_token.dart';
import '../models/mark_type.dart';
import 'endpoints.dart';

class PropertyService {
  static final client = http.Client();
  final AccessToken accessToken;

  PropertyService(this.accessToken);

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

  Future<Tuple2<List<Property>?, String?>> fetchPropertiesPoll(
      List<StationPostcode> stations, int pageNumber) async {
    final postcodes = stations.map((e) => e.postcode).toList();

    final requestId = shortHash(UniqueKey());
    var retryCount = 0;
    var maxRetryCount = 90;
    Tuple2<List<Property>?, String?> pollResponse = Tuple2(null, null);

    while (pollResponse.item1 == null && retryCount < maxRetryCount) {
      retryCount++;
      pollResponse = await _poll(postcodes, requestId, pageNumber: pageNumber);
      await Future.delayed(const Duration(seconds: 10), () {});
    }

    if (retryCount == maxRetryCount) {
      return Tuple2(null, 'Error fetching properties. Timeout.');
    }

    return pollResponse;
  }

  Future<Tuple2<List<Property>?, String>> _poll(
    List<String> postcodes,
    String requestId, {
    int pageNumber = 1,
  }) async {
    final params = {
      'page_number': '$pageNumber',
      'min_area': '100',
      'min_price': '600000',
      'max_price': '900000',
      'min_beds': '2',
      'keywords': 'garden',
      'listing_status': 'sale',
    };
    final path = '$propertiesPollPath/$requestId';
    final uri = Uri.parse(urlBase).replace(
      path: path,
      queryParameters: params,
    );

    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: _body(postcodes),
      );

      // first request: 201, null
      // second request: 200, null
      // last request: 200, [] or [data]
      if (response.statusCode == 200) {
        if (response.body == null || response.body == 'null') {
          return Tuple2(null, null);
        }
        final propertiesJSON =
            jsonDecode(response.body)['properties'] as List<dynamic>;
        final properties = propertiesJSON
            .map((property) => Property.fromJson(property))
            .where((property) => property.floorPlan?.isNotEmpty ?? false)
            .toList();
        return Tuple2(properties, null);
      } else if (response.statusCode == 201) {
        // this should be the response for the first request only.
        // should get null back.
        if (response.body == null || response.body == 'null') {
          return Tuple2(null, null);
        } else {
          return Tuple2(null, 'Failed to initiate poll "${response.body}"');
        }
      } else {
        // If the server did not return a 200 OK response,
        // thens throw an exception.
        return Tuple2(null, 'Failed to load property: ${response.body}');
      }
    } catch (error) {
      return Tuple2(null, 'Failed to load property');
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
