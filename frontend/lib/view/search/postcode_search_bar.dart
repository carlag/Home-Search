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
  final SuggestionsBoxController _suggestionsBoxController =
      SuggestionsBoxController();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.addedStations.isNotEmpty)
            SizedBox(height: 30.0, child: _selectedStations)
          else
            SizedBox(
              height: 30.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text('Add stations to search nearby'),
              ),
            ),
          ListTile(
            title: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                    hintText: 'e.g. West Hampstead',
                    hintStyle: TextStyle(color: Colors.black26),
                  ),
                  controller: this._typeAheadController,
                  onTap: () => _suggestionsBoxController.toggle(),
                ),
                suggestionsBoxController: _suggestionsBoxController,
                suggestionsBoxDecoration: SuggestionsBoxDecoration(),
                suggestionsCallback: (pattern) {
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
    );
  }

  Widget get _selectedStations => SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.addedStations.length,
              itemBuilder: (_, index) {
                final item = widget.addedStations[index];
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Chip(
                    label: Text(item.name),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        widget.addedStations.remove(item);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
}
