import 'package:flutter/material.dart';
import 'package:proper_house_search/data/models/property.dart';
import 'package:proper_house_search/data/property_service.dart';
import 'package:proper_house_search/view/home.dart';
import 'package:proper_house_search/view/properties/properties_notifier.dart';
import 'package:proper_house_search/view/property_summary.dart';

class PropertiesListView extends StatefulWidget {
  const PropertiesListView({required Key key, required this.parent})
      : super(key: key);

  final MyHomePageState parent;

  @override
  PropertiesListViewState createState() => PropertiesListViewState();
}

class PropertiesListViewState extends State<PropertiesListView> {
  late PropertiesNotifier notifier;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    notifier = PropertiesNotifier();
    notifier.getMore();
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
        return value != null
            ? _propertyList(value)
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _propertyList(List<Property> value) {
    return value.isEmpty
        ? ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return const Center(
                  child: Text('Add stations to view properties'));
            },
          )
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
                    service: PropertyService(),
                  );
                }),
          );
  }

  Future<void> _moreButtonPressed() async {
    setState(() {
      isLoading = true;
    });
    await notifier.getMore();
    setState(() {
      isLoading = false;
    });
  }
}
