import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/postcode_service.dart';

class AutoComplete extends StatefulWidget {
  @override
  _AutoCompleteState createState() => new _AutoCompleteState();
}

class _AutoCompleteState extends State<AutoComplete> {
  final TextEditingController _typeAheadController = TextEditingController();
  final service = PostCodeService();
  final _addedStations = <StationPostcode>[];

  void _loadData() async {
    await service.loadAsset();
  }

  TextEditingController controller = new TextEditingController();

  _AutoCompleteState();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add stations to search nearby:'),
            if (_addedStations.isNotEmpty)
              Row(children: _addedStations.map((e) => Text(e.name)).toList())
            else
              Text('No stations'),
            ListTile(
              title: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(labelText: 'Station'),
                    controller: this._typeAheadController,
                  ),
                  suggestionsCallback: (pattern) {
                    print(pattern);
                    return service.getSuggestions(pattern);
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  itemBuilder: (context, suggestion) {
                    final station = suggestion as StationPostcode;
                    return ListTile(
                      title: Text(station.name),
                      subtitle: Text(station.postcode),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    final station = suggestion as StationPostcode;
                    _addedStations.add(station);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
