import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/station.dart';
import 'package:proper_house_search/data/station_service.dart';

class Stations extends StatelessWidget {
  final origin;
  final _stationService;
  final style;

  Stations({required Key key, this.origin, this.style})
      : _stationService = StationService(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.8);
    final subTitleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0);

    return FutureBuilder<List<Station>>(
      future: downloadData(),
      builder: (BuildContext context, AsyncSnapshot<List<Station>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Text('Loading...', style: style);
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}', style: style);
            else
              return Table(
                defaultColumnWidth: IntrinsicColumnWidth(),
                children: List.generate(
                  snapshot.data?.length ?? 0,
                  (index) {
                    final station = snapshot.data![index];
                    return _station(station, titleStyle, subTitleStyle);
                  },
                ),
              );
        }
      },
    );
  }

  TableRow _station(Station station, TextStyle title, TextStyle subtitle) {
    final accentedStyle =
        TextStyle(color: Colors.blueAccent, fontStyle: subtitle.fontStyle);
    var parts = station.name?.split(',') ?? ['Unknown name'];
    var prefix = parts[0].trim();
    return TableRow(
      children: [
        TableCell(
          child: Text(prefix, style: subtitle),
        ),
        TableCell(
          child: Text(' Distance: ', style: subtitle),
        ),
        TableCell(
          child: Text('${(station.distance! / 1000.0).toStringAsFixed(2)} km, ',
              style: accentedStyle),
        ),
        TableCell(
          child: Text(' Walking: ', style: subtitle),
        ),
        TableCell(
          child: Text('${(station.duration! / 60.0).toStringAsFixed(2)} mins',
              style: accentedStyle),
        ),
      ],
    );
  }

  Future<List<Station>> downloadData() async {
    final stations = await _stationService.fetchStations(origin);
    return Future.value(stations ?? []);
  }
}
