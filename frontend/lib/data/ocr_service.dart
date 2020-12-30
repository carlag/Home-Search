import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const _zooplaEndpoint = 'https://lc.zoocdn.com/';
const _ocrServiceEndpoint = 'http://127.0.0.1:80';

class OcrService {
  final key;

  static final client = http.Client();

  OcrService({this.key});

  Future<double?> fetchOcrSize(String floorPlanURL) async {
    final request = _fetchOcrSizeRequest(floorPlanURL);
    final response = await client.get(
      request,
      headers: {"Access-Control-Allow-Origin": "*"},
    );

    try {
      if (response.statusCode == 200) {
        final areaJSON = jsonDecode(response.body)['area'] as double;
        return areaJSON;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        final message = jsonDecode(response.body)['detail'] as String;
        throw Exception('Request Failed: $request, \n Error: $message');
      }
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
    }
  }

  void dispose() {
    client.close();
  }

  String _fetchOcrSizeRequest(String floorPlanURL) {
    if (floorPlanURL.endsWith('pdf')) {
      floorPlanURL = floorPlanURL.replaceFirst(
          _zooplaEndpoint, '$_ocrServiceEndpoint/pdf/');
    } else {
      floorPlanURL = floorPlanURL.replaceFirst(
          _zooplaEndpoint, '$_ocrServiceEndpoint/image/');
    }
    return floorPlanURL;
  }
}
