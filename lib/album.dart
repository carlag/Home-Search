import 'package:proper_house_search/network.dart';

class Album {}

class AlbumService {
  final networkManager = NetworkManager();

  Future<String> fetch() async {
    final response = await networkManager.fetchAlbum();
    print(response);
    return response.body;
  }
}
