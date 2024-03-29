import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/station.dart';
import 'endpoints.dart';

class StationService {
  static final client = http.Client();

  Future<List<Station>?> fetchStations(LatLng origin) async {
    try {
      final request = await _fetchStationsRequest(origin);
      final response = await client.get(
        request,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
        },
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body)['stations'] as List<dynamic>;
        final stations =
            json.map((station) => Station.fromJson(station)).toList();
        return stations;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Request Failed: $request');
      }
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
    }
  }

  void dispose() {
    client.close();
  }

  Future<String> _fetchStationsRequest(LatLng origin) async {
    final originString = '${origin.latitude},${origin.longitude}';
    final url = '$stationsEndpoint/$originString';
    return url;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
    };
    return headers;
  }
}
