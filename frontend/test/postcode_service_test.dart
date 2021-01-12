import 'package:flutter_test/flutter_test.dart';
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
      service.output = '''station1,postcode1
station2,postcode2
station3,postcode3''';
      service.stationPostcodes();

      expect(service.data, [
        ['station1', 'postcode1'],
        ['station2', 'postcode2'],
        ['station3', 'postcode3'],
      ]);
    });
  });
}
