import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:proper_house_search/data/property.dart';

Widget PropertySummary(BuildContext context, Property property) {
  final titleStyle =
      DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0);
  final subTitleStyle =
      DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2);
  return ListTile(
    title: _title(property, titleStyle),
    subtitle: _body(property, subTitleStyle),
  );
}

Widget _title(Property property, TextStyle style) => FlatButton(
      onPressed: () =>
          html.window.open('${property.listingURL}', '${property.listingURL}'),
      child: Text(
        '${property.displayableAddress}',
        style: style,
      ),
    );

Widget _body(Property property, TextStyle style) => Column(
      children: [
        Text(
          '£${property.price}',
          style: style,
        ),
        Text(
          '${property.size?.toString() ?? 'No size'}',
          style: style,
        ),
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
