import 'package:flutter/material.dart';

Widget loading(BuildContext context) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.60,
                child: LinearProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.60,
                child: SelectableText(
                  'This was made by lazy developers so this could take a while. Maybe go make a cup of coffee ☕️.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
