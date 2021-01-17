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
  _PropertiesListViewState createState() => _PropertiesListViewState();
}

class _PropertiesListViewState extends State<PropertiesListView> {
  late PropertiesNotifier notifier;

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
              ? RefreshIndicator(
                  onRefresh: () async {
                    return await notifier
                        .reload(widget.parent.selectedStations);
                  },
                  child: value.isEmpty
                      ? ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return const Center(child: Text('No Properties!'));
                          })
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo is ScrollEndNotification &&
                                scrollInfo.metrics.extentAfter == 0) {
                              notifier.getMore();
                              return true;
                            }
                            return false;
                          },
                          child: ListView.separated(
                              separatorBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Divider(),
                                  ),
                              padding: EdgeInsets.only(top: 20),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: value.length,
                              // cacheExtent: 5,
                              itemBuilder: (BuildContext context, int index) {
                                return PropertySummary(
                                  property: value[index],
                                  key: Key('property_$index'),
                                  service: PropertyService(),
                                );
                              }),
                        ),
                )
              : Center(child: CircularProgressIndicator());
        });
  }
}
