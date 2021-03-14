// Define a custom Form widget.
import 'dart:math';

import 'package:flutter/material.dart';

class FilterTitles {
  static String minFloorSize = 'Min floor size (sqm)';
  static String minPrice = 'Min price (£)';
  static String maxPrice = 'Max price (£)';
  static String maxWalkingTime = 'Max walking time to tube (min)';
  static String maxCommutingTime = 'Max total commute time to work (min)';
  static String workPostcodes = 'Work postcodes (comma separated)';
  static String minBeds = 'Min beds';
  static String keywords = 'Keywords';
}

class Filters extends StatefulWidget {
  const Filters({
    Key? key,
  }) : super(key: key);

  @override
  FiltersState createState() {
    return FiltersState();
  }
}

const padding = 16.0;

// Define a corresponding State class.
// This class holds data related to the form.
class FiltersState extends State<Filters> {
  Map<String, String> filterValues = {};
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text('Filters (${filterValues.length} selected)'),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 120.0,
            maxHeight: max(
              120.0,
              MediaQuery.of(context).size.height * 0.20,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: padding),
                  child: _form(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            children: [
              _input(
                title: FilterTitles.minPrice,
                hint: 'e.g.400000',
                validationType: ValidationType.number,
              ),
              _input(
                title: FilterTitles.maxPrice,
                hint: 'e.g. 600000',
                validationType: ValidationType.number,
              ),
              _input(
                title: FilterTitles.minFloorSize,
                hint: 'e.g. 100',
                validationType: ValidationType.number,
              ),
              _input(
                title: FilterTitles.minBeds,
                hint: 'e.g. 2',
                validationType: ValidationType.number,
              ),
              _input(
                title: FilterTitles.keywords,
                hint: 'e.g. Garden',
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool validate() {
    return _formKey.currentState != null && _formKey.currentState!.validate();
  }

  Widget _input(
      {String title = '',
      String hint = '',
      double width = 120,
      ValidationType? validationType}) {
    String? Function(String?)? validator;
    TextInputType? textInputType;
    if (validationType != null) {
      switch (validationType) {
        case ValidationType.number:
          textInputType = TextInputType.number;
          validator = (value) {
            if (value!.isNotEmpty) {
              if (double.tryParse(value) == null) {
                return '$title must be a number';
              }
            }
            return null;
          };
          break;
        case ValidationType.required:
          validator = (value) {
            if (value!.isEmpty) {
              if (double.tryParse(value) == null) {
                return '$title is required';
              }
            }
            return null;
          };
          break;
      }
    }
    return Container(
      child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 50.0, bottom: 8.0),
          child: Container(
            width: width,
            child: TextFormField(
              initialValue: filterValues[title],
              keyboardType: textInputType,
              onChanged: (text) {
                setState(() {
                  if (text.isEmpty) {
                    filterValues.remove(title);
                  } else {
                    filterValues[title] = text;
                  }
                });
              },
              validator: validator,
              decoration: InputDecoration(
                helperText: title,
                helperMaxLines: 2,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.black26),
              ),
            ),
          )),
    );
  }
}

enum ValidationType {
  number,
  required,
}
