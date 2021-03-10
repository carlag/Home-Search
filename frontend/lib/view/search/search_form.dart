// Define a custom Form widget.
import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  @override
  SearchFormState createState() {
    return SearchFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SearchFormState extends State<SearchForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            children: [
              _input(
                title: 'Max price (£)',
                hint: 'e.g. 600000',
                validator: (value) {
                  if (value!.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Min floor size (sqm) must be a number';
                    }
                  }
                  return null;
                },
              ),
              _input(
                title: 'Min floor size (sqm)',
                hint: 'e.g. 100',
                validator: (value) {
                  if (value!.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Min floor size (sqm) must be a number';
                    }
                  }
                  return null;
                },
              ),
              _input(
                title: 'Max walking time to tube (min)',
                hint: 'e.g. 10',
              ),
              _input(
                title: 'Max total commute time to work (min)',
                hint: 'e.g. 45',
              ),
              _input(
                title: 'Work postcodes (comma separated)',
                hint: 'e.g. N1C 4AG, W1T 1FB',
                width: 200,
              ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       // Validate returns true if the form is valid, otherwise false.
          //       if (_formKey.currentState != null &&
          //           _formKey.currentState!.validate()) {
          //         // If the form is valid, display a snackbar. In the real world,
          //         // you'd often call a server or save the information in a database.
          //         ScaffoldMessenger.of(context)
          //             .showSnackBar(SnackBar(content: Text('Processing Data')));
          //       }
          //     },
          //     child: Text('Search'),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _input(
      {String title = '',
      String hint = '',
      double width = 120,
      String? Function(String?)? validator}) {
    return Container(
      child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 50.0, bottom: 8.0),
          child: Container(
            width: width,
            child: TextFormField(
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
