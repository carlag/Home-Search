import 'package:flutter/material.dart';
import 'package:proper_house_search/data/property.dart';
import 'package:universal_html/html.dart' as html;

class PropertySummary extends StatefulWidget {
  PropertySummary({Key key, this.property}) : super(key: key);

  final Property property;

  @override
  _PropertySummaryState createState() => _PropertySummaryState();
}

class _PropertySummaryState extends State<PropertySummary> {
  Property _property;

  String _ocrSize;

  Future<void> _fetchOcrSize() async {
    final size = await PropertyService().fetchOcrSize(_property.floorPlan[0]);
    setState(() {
      _ocrSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    _fetchOcrSize();
    final titleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0);
    final subTitleStyle =
        DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2);
    return ListTile(
      title: _title(_property, titleStyle),
      subtitle: _body(_property, _ocrSize, subTitleStyle),
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
          '${property.size?.toString() ?? 'No size'}',
          style: style,
        ),
        Text('OCR Size: ${ocrSize}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _floorPlan(property),
            _image(property),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(height: 2.0),
        ),
      ],
    );

Widget _floorPlan(Property property) => FlatButton(
      onPressed: () => html.window.open('${property.floorPlan[0] ?? ''}',
          '${property.floorPlan[0] ?? ''}'), // handle your image tap here
      child: Image.network('${property.floorPlan[0] ?? ''}', height: 300),
    );

Widget _image(Property property) => FlatButton(
      onPressed: () => html.window
          .open('${property.imageURL ?? ''}', '${property.imageURL ?? ''}'),
      child: Image.network('${property.imageURL}', height: 300),
    );
