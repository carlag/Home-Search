import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/view/stations.dart';
import 'package:universal_html/html.dart' as html;

import 'ocr_size.dart';
import 'property_map.dart';

const _rowHeight = 400.0;

class PropertySummary extends StatelessWidget {
  PropertySummary({required Key key, required this.property}) : super(key: key);

  final Property property;

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0);
    final subTitleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2);
    return ListTile(
      title: _title(property, titleStyle),
      subtitle: _body(key!, property, subTitleStyle),
    );
  }
}

Widget _title(Property property, TextStyle style) => FlatButton(
      onPressed: () =>
          html.window.open('${property.listingURL}', '${property.listingURL}'),
      child: Text(
        '${property.displayableAddress}',
        style: style,
      ),
    );

Widget _body(Key key, Property property, TextStyle style) => Column(
      children: [
        Text(
          '£${property.price}',
          style: style,
        ),
        Text(
          '${property.status}, ${property.propertyType}',
          style: style,
        ),
        OcrSize(
          key: Key('ocr_${key.hashCode}'),
          floorPlanUrl: property.floorPlan?[0],
          style: style,
        ),
        if (property.latitude != null && property.longitude != null)
          Stations(
            key: Key('station_${key.hashCode}'),
            origin: LatLng(property.latitude, property.longitude),
          ),
        _details(property),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(height: 2.0),
        ),
      ],
    );

Widget _details(Property property) => Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _floorPlan(property),
              _image(property),
              if (property.longitude != null && property.latitude != null)
                _map(property),
            ],
          ),
        ),
      ],
    );

Widget _floorPlan(Property property) => FlatButton(
      onPressed: () => html.window.open('${property.floorPlan?[0] ?? ''}',
          '${property.floorPlan?[0] ?? ''}'), // handle your image tap here
      child: Image.network(
        '${property.floorPlan?[0] ?? ''}',
        height: _rowHeight,
      ),
    );

Widget _image(Property property) => FlatButton(
      onPressed: () => html.window
          .open('${property.imageURL ?? ''}', '${property.imageURL ?? ''}'),
      child: Image.network(
        '${property.imageURL}',
        height: _rowHeight,
      ),
    );

Widget _map(Property property) => SizedBox(
      height: _rowHeight,
      width: _rowHeight,
      child: PropertyMap(
        longitude: property.longitude!,
        latitude: property.latitude!,
      ),
    );
