import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proper_house_search/data/models/mark_type.dart';
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/services/property_service.dart';
import 'package:proper_house_search/view/properties/summary/stations.dart';
import 'package:universal_html/html.dart' as html;

import 'property_map.dart';

class PropertySummary extends StatefulWidget {
  PropertySummary(
      {required Key key, required this.property, required this.propertyService})
      : super(key: key);

  final Property property;
  final PropertyService propertyService;

  @override
  _PropertySummaryState createState() => _PropertySummaryState();
}

class _PropertySummaryState extends State<PropertySummary> {
  MarkType? _markType;

  @override
  Widget build(BuildContext context) {
    final _rowHeight = MediaQuery.of(context).size.width * 0.3;
    if (_markType == null) {
      _markType = widget.property.markType;
    }
    final titleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0);
    final subTitleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2);
    return ListTile(
      title: _title(widget.property, titleStyle),
      subtitle: _body(widget.key!, widget.property, subTitleStyle,
          widget.propertyService, _rowHeight),
    );
  }

  Widget _title(Property property, TextStyle style) => FlatButton(
        onPressed: () => html.window
            .open('${property.listingURL}', '${property.listingURL}'),
        child: Text(
          '${property.displayableAddress}',
          style: style,
        ),
      );

  Widget _body(Key key, Property property, TextStyle style,
          PropertyService service, double rowHeight) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _markButton(service, property, MarkType.rejected),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _markButton(service, property, MarkType.liked),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _markButton(service, property, MarkType.unsure),
              ),
            ],
          ),
          Text(
            '£${property.price}',
            style: style,
          ),
          Text(
            '${property.propertyType}',
            style: style,
          ),
          Text(
            'Size: ${property.ocrSize != null ? '${property.ocrSize} sqm' : 'None'}',
            style: style,
          ),
          if (property.latitude != null && property.longitude != null)
            Stations(
              key: Key('station_${key.hashCode}'),
              origin: LatLng(property.latitude, property.longitude),
            ),
          _details(property, rowHeight),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(height: 2.0),
          ),
        ],
      );

  Widget _markButton(
      PropertyService service, Property property, MarkType type) {
    return FlatButton(
      onPressed: (_markType != null)
          ? null
          : () async {
              setState(() {
                widget.property.markType = type;
                _markType = type;
              });
              await service.markProperty(
                property.listingURL!,
                type,
              );
            },
      child: Text(type.string.toUpperCase()),
      color: _markType == type ? Colors.blue : Colors.grey,
      disabledColor: _markType == type ? Colors.blue : Colors.grey,
    );
  }
}

Widget _details(Property property, double rowHeight) => Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _floorPlan(property, rowHeight),
              _image(property, rowHeight),
              if (property.longitude != null && property.latitude != null)
                _map(property, rowHeight),
            ],
          ),
        ),
      ],
    );

Widget _floorPlan(Property property, double rowHeight) => FlatButton(
      onPressed: () => html.window.open('${property.floorPlan?[0] ?? ''}',
          '${property.floorPlan?[0] ?? ''}'), // handle your image tap here
      child: Image.network(
        '${property.floorPlan?[0] ?? ''}',
        height: rowHeight,
        headers: {'Access-Control-Allow-Origin': '*'},
      ),
    );

Widget _image(Property property, double rowHeight) => FlatButton(
      onPressed: () => html.window
          .open('${property.imageURL ?? ''}', '${property.imageURL ?? ''}'),
      child: Image.network(
        '${property.imageURL}',
        height: rowHeight,
        headers: {'Access-Control-Allow-Origin': '*'},
      ),
    );

Widget _map(Property property, double rowHeight) {
  return SizedBox(
    height: rowHeight,
    width: rowHeight,
    child: PropertyMap(
      longitude: property.longitude!,
      latitude: property.latitude!,
    ),
  );
}
