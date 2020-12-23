import 'package:flutter/material.dart';
import 'package:proper_house_search/data/ocr_service.dart';

class OcrSize extends StatelessWidget {
  final floorPlanUrl;
  final _ocrService;
  final style;

  OcrSize({required Key key, this.floorPlanUrl, this.style})
      : _ocrService = OcrService(key: key),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: downloadData(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Text('Loading...', style: style);
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}', style: style);
            else
              return new Text('Total floor area: ${snapshot.data}',
                  style: style);
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
