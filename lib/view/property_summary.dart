import 'package:flutter/material.dart';
import 'package:proper_house_search/data/property.dart';
import 'package:universal_html/html.dart' as html;

import 'property_map.dart';

class PropertySummary extends StatefulWidget {
  PropertySummary({required Key key, required this.property}) : super(key: key);

  final Property property;

  @override
  _PropertySummaryState createState() => _PropertySummaryState();
}

class _PropertySummaryState extends State<PropertySummary> {
  String _ocrSize = 'Not loaded';

  Future<void> _fetchOcrSize() async {
    final size =
        await PropertyService().fetchOcrSize(widget.property.floorPlan?[0]);
    setState(() {
      _ocrSize = size ?? 'Error';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.property == null) {
      return ListTile(title: Text('Missing Property'));
    }
    _fetchOcrSize();
    final titleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0);
    final subTitleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2);
    return ListTile(
      title: _title(widget.property, titleStyle),
      subtitle: _body(widget.property, _ocrSize, subTitleStyle),
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

Widget _body(Property property, String ocrSize, TextStyle style) => Column(
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
        Text('OCR Floor Area: $ocrSize'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _floorPlan(property),
            _image(property),
            _map(property),
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

Widget _map(Property property) =>
    SizedBox(height: 300, width: 300, child: PropertyMap());
