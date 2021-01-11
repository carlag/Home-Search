import 'package:flutter_test/flutter_test.dart';
import 'package:proper_house_search/data/models/station_postcode.dart';
import 'package:proper_house_search/data/postcode_service.dart';

void main() {
  group(PostCodeService, () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('loads csv', () {
      final service = PostCodeService();
      service.loadAsset();

      expect(service.output, isNotNull);
    });

    test('converts csv to list of station postcodes', () {
      final service = PostCodeService();
      service.output = '''Station,Postcode
station1,postcode1
station2,postcode2
station3,postcode3''';
      List<StationPostcode> actual = service.stationPostcodes();

      expect(actual, [
        StationPostcode(name: 'station1', postcode: 'postcode1'),
        StationPostcode(name: 'station2', postcode: 'postcode2'),
        StationPostcode(name: 'station3', postcode: 'postcode3'),
      ]);
    });
  });
}
