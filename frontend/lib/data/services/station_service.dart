import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/station.dart';

const _endpoint = 'http://127.0.0.1:80/stations/origin';

class StationService {
  static final client = http.Client();

  Future<List<Station>?> fetchStations(LatLng origin) async {
    try {
      final request = await _fetchStationsRequest(origin);
      print('Request: $request');
      final response = await client.get(
        request,
        headers: {"Access-Control-Allow-Origin": "*"},
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
    final url = '$_endpoint/$originString';
    return url;
  }
}
