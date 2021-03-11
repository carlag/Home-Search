import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/services/property_service.dart';
import 'package:proper_house_search/view/home.dart';
import 'package:proper_house_search/view/properties/summary/property_summary.dart';

import 'properties_notifier.dart';

class PropertiesListView extends StatefulWidget {
  const PropertiesListView(
      {required Key key, required this.parent, required this.propertyService})
      : super(key: key);

  final HomeState parent;
  final PropertyService propertyService;

  @override
  PropertiesListViewState createState() => PropertiesListViewState();
}

class PropertiesListViewState extends State<PropertiesListView> {
  late PropertiesNotifier notifier;
  var isLoading = false;
  var pageNumber = 1;
  var postCodes = <StationPostcode>[];

  @override
  void initState() {
    super.initState();
    notifier = PropertiesNotifier(widget.propertyService);
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Property>>(
      valueListenable: notifier,
      builder: (BuildContext context, List<Property>? value, Widget? child) {
        if (notifier.errorMessage != null) {
          return Text('Error: ${notifier.errorMessage}');
        }
        return value != null
            ? _propertyList(value)
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _propertyList(List<Property> value) {
    return value.isEmpty
        ? Container()
        : NotificationListener<ScrollNotification>(
            child: ListView.separated(
                separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(),
                    ),
                padding: EdgeInsets.only(top: 20),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: value.length + 1,
                // cacheExtent: 5,
                itemBuilder: (BuildContext context, int index) {
                  if (index == value.length) {
                    if (isLoading) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                          onPressed: () => _moreButtonPressed(),
                          child: Text('View more'),
                        ),
                      );
                    }
                  }
                  return PropertySummary(
                    property: value[index],
                    key: Key('property_$index'),
                    propertyService: widget.propertyService,
                  );
                }),
          );
  }

  Future<void> _moreButtonPressed() async {
    setState(() {
      isLoading = true;
      pageNumber++;
    });
    await notifier.reload(postCodes, pageNumber);
    setState(() {
      isLoading = false;
    });
  }
}
