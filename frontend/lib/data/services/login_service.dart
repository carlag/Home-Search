import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proper_house_search/data/models/access_token.dart';

import 'endpoints.dart';

class LoginService {
  static final client = http.Client();

  Future<AccessToken> swapTokens(String idToken) async {
    print(swapTokensEndpoint);
    final response = await client.post(
      swapTokensEndpoint,
      headers: _headers(),
      body: idToken,
    );

    if (response.statusCode == 200) {
      print('Received token');
      print(response);
      print(response.body);
      final accessTokenJSON = jsonDecode(response.body);
      print(accessTokenJSON);
      final accessToken = AccessToken.fromJson(accessTokenJSON);
      return accessToken;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception(
          'Failed to authenticate with HomeSearch server: ${response.body}');
    }
  }

  void dispose() {
    client.close();
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    return headers;
  }

  // String _body(List<String> ) {
  //   final body = jsonEncode(
  //     <String, List<String>>{
  //       'postcodes': postcodes,
  //     },
  //   );
  //   return body;
  // }
}
