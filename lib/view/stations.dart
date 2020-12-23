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
              return Column(
                children: List.generate(
                  snapshot.data?.length ?? 0,
                  (index) {
                    final station = snapshot.data![index];
                    return ListTile(
                      title: Text(station.name ?? 'Unknown station'),
                      subtitle: Text('Distance: ${station.distance}, '
                          'Walking: ${station.time} mins'),
                    );
                  },
                ),
              );
        }
      },
    );
  }

  Future<List<Station>> downloadData() async {
    final stations = await _stationService.fetchStations(origin);
    return Future.value(stations ?? []);
  }
}
