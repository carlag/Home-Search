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
  Map<String, dynamic> filterValues = {};
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
              _dropdown<int>(
                  title: FilterTitles.minPrice,
                  items:
                      List.generate(25, (index) => (100000 + index * (50000)))
                          .toList(),
                  display: (value) =>
                      value != null ? Text('£$value') : Text(' ')),
              _dropdown<int>(
                  title: FilterTitles.maxPrice,
                  items:
                      List.generate(25, (index) => (100000 + index * (50000)))
                          .toList(),
                  display: (value) =>
                      value != null ? Text('£$value') : Text(' ')),
              _dropdown<int>(
                  title: FilterTitles.minFloorSize,
                  items: List.generate(20, (index) => (30 + index * (10)))
                      .toList(),
                  display: (value) =>
                      value != null ? Text('$value sqm') : Text(' ')),
              _dropdown<int>(
                  title: FilterTitles.minBeds,
                  items:
                      List.generate(10, (index) => (1 + index * (1))).toList(),
                  display: (value) =>
                      value != null ? Text('$value') : Text(' ')),
              _checkbox(title: 'Garden'),
              _checkbox(title: 'Parking'),
            ],
          ),
        ],
      ),
    );
  }

  bool validate() {
    return _formKey.currentState != null && _formKey.currentState!.validate();
  }

  Widget _checkbox({required String title}) {
    return SizedBox(
      width: 120,
      child: CheckboxListTile(
        title: Text(title),
        contentPadding: EdgeInsets.all(2.0),
        controlAffinity: ListTileControlAffinity.leading,
        value: (filterValues[FilterTitles.keywords] ?? []).contains(title),
        onChanged: (checked) {
          setState(() {
            List<String>? values = filterValues[FilterTitles.keywords];
            if (checked != null && checked) {
              values = values ?? [];
              values.add(title);
              filterValues[FilterTitles.keywords] = values;
            }
            if (checked != null && !checked) {
              values!.remove(title);
              if (values.isEmpty) {
                filterValues[FilterTitles.keywords] = values;
                filterValues.remove(FilterTitles.keywords);
              }
            }
          });
        },
      ),
    );
  }

  Widget _dropdown<T>({
    required String title,
    double width = 120,
    required List<T?> items,
    required Widget Function(T?) display,
    bool shouldHandleOnchanged = true,
  }) {
    items.insert(0, null);
    final textField = DropdownButtonFormField<T>(
      value: shouldHandleOnchanged ? filterValues[title] : 'Garden',
      onChanged: shouldHandleOnchanged
          ? (value) {
              setState(() {
                if (value == null) {
                  filterValues.remove(title);
                } else {
                  filterValues[title] = value;
                }
              });
            }
          : (_) {},
      items: items
          .map((item) => DropdownMenuItem<T>(
                child: display(item),
                value: item,
              ))
          .toList(),
      decoration: InputDecoration(
        helperText: title,
        helperMaxLines: 2,
      ),
    );

    return _textFieldContainer(textField, width);
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
    final textField = TextFormField(
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
    );
    return _textFieldContainer(textField, width);
  }

  Widget _textFieldContainer(Widget textField, double width) {
    return Container(
      child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 50.0, bottom: 8.0),
          child: Container(
            width: width,
            child: textField,
          )),
    );
  }
}

enum ValidationType {
  number,
  required,
}
