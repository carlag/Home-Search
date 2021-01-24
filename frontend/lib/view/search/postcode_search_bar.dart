import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/services/postcode_service.dart';

class AutoComplete extends StatefulWidget {
  List<StationPostcode> addedStations;

  AutoComplete({required Key key, this.addedStations = const []})
      : super(key: key);

  @override
  AutoCompleteState createState() => new AutoCompleteState();
}

class AutoCompleteState extends State<AutoComplete> {
  final TextEditingController _typeAheadController = TextEditingController();
  final service = PostCodeService();

  void _loadData() async {
    await service.loadAsset();
  }

  List<StationPostcode> addedStations() => widget.addedStations;

  TextEditingController controller = new TextEditingController();

  AutoCompleteState();

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
            if (widget.addedStations.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: widget.addedStations
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Chip(
                          label: Text(e.name),
                          deleteIcon: Icon(Icons.close),
                          onDeleted: () {
                            setState(() {
                              widget.addedStations.remove(e);
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              )
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
                    this._typeAheadController.text = '';
                    setState(() {
                      if (!widget.addedStations.contains(station)) {
                        widget.addedStations.add(station);
                      }
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
