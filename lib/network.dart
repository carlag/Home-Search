import 'package:http/http.dart' as http;

class NetworkManager {
  Future<http.Response> fetchAlbum() async {
    return http.get('https://jsonplaceholder.typicode.com/albums/1');
  }
}
