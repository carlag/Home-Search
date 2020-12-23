import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/property.dart';
import 'package:universal_html/html.dart' as html;

import 'ocr_size.dart';
import 'property_map.dart';

class PropertySummary extends StatelessWidget {
  PropertySummary({required Key key, required this.property}) : super(key: key);

  final Property property;

  @override
  Widget build(BuildContext context) {
    print(property);
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
        Text(
          'Floor Area: ${property.size?.toString() ?? 'Unknown'}',
          style: style,
        ),
        OcrSize(
          key: key,
          floorPlanUrl: property.floorPlan?[0],
          style: style,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _floorPlan(property),
            _image(property),
            if (property.longitude != null && property.latitude != null)
              Expanded(child: _map(property)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(height: 2.0),
        ),
      ],
    );

Widget _floorPlan(Property property) => FlatButton(
      onPressed: () => html.window.open('${property.floorPlan?[0] ?? ''}',
          '${property.floorPlan?[0] ?? ''}'), // handle your image tap here
      child: Image.network('${property.floorPlan?[0] ?? ''}', height: 300),
    );

Widget _image(Property property) => FlatButton(
      onPressed: () => html.window
          .open('${property.imageURL ?? ''}', '${property.imageURL ?? ''}'),
      child: Image.network('${property.imageURL}', height: 300),
    );

Widget _map(Property property) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          height: 300,
          child: PropertyMap(
            longitude: property.longitude!,
            latitude: property.latitude!,
          )),
    );
