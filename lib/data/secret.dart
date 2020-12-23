import 'dart:async' show Future;
import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;

class Secret {
  final String zooplaApiKey;
  final String googleMapsApiKey;
  Secret({this.zooplaApiKey = "", this.googleMapsApiKey = ""});

  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(
      zooplaApiKey: jsonMap["zoopla_api_key"],
      googleMapsApiKey: jsonMap["google_maps_api_key"],
    );
  }
}

class SecretLoader {
  final String secretPath;

  SecretLoader({required this.secretPath});
  Future<Secret> load() {
    return rootBundle.loadStructuredData<Secret>(this.secretPath,
        (jsonStr) async {
      final secret = Secret.fromJson(json.decode(jsonStr));
      return secret;
    });
  }
}
