import 'package:flutter/material.dart';
import 'package:proper_house_search/data/ocr_service.dart';

class OcrSize extends StatelessWidget {
  final floorPlanUrl;
  final _ocrService;

  OcrSize({required Key key, this.floorPlanUrl})
      : _ocrService = OcrService(key: key),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: downloadData(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text('...');
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return new Text('${snapshot.data}');
        }
      },
    );
  }

  Future<String> downloadData() async {
    final size = await _ocrService.fetchOcrSize(floorPlanUrl);
    final value = size != null ? '$size sqm' : 'Unknown';
    return Future.value(value);
  }
}
