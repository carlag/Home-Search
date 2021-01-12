import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class PostCodeService {
  List<List<dynamic>> data = [];
  String output = '';

  loadAsset() async {
    output = await rootBundle.loadString('assets/london_stations.csv');
    print(output);
  }

  stationPostcodes() {
    data = const CsvToListConverter()
        .convert(output, fieldDelimiter: ',', eol: '\n');
    print(data);
  }
}
