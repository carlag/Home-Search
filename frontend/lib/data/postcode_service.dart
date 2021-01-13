import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';

class PostCodeService {
  String output = '';

  loadAsset() async {
    output = await rootBundle.loadString('assets/london_stations.csv');
  }

  List<StationPostcode> getSuggestions(String pattern) {
    return stationPostcodes()
        .where((element) =>
            element.name.toLowerCase().contains(pattern.toLowerCase()))
        .toList();
  }

  List<StationPostcode> stationPostcodes() {
    List<List<dynamic>> data = const CsvToListConverter()
        .convert(output, fieldDelimiter: ',', eol: '\n');
    final headers = data[0];
    final nameIndex = headers.indexWhere((element) => element == 'Station');
    final postcodeIndex =
        headers.indexWhere((element) => element == 'Postcode');
    data.removeAt(0);
    List<StationPostcode> postcodes = data
        .map(
          (row) => StationPostcode(
            name: row[nameIndex],
            postcode: row[postcodeIndex],
          ),
        )
        .toList();
    return postcodes;
  }
}
