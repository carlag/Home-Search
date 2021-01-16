import 'mark_type.dart';

class Property {
  String? listingURL;
  dynamic? size;
  double? ocrSize;
  double? longitude;
  double? latitude;
  String? imageURL;
  String? status;
  String? propertyType;
  dynamic? price;
  String? displayableAddress;
  List<dynamic>? floorPlan;
  MarkType? markType;

  Property(this.listingURL, this.size, this.imageURL, this.price,
      this.displayableAddress);

  Property.fromJson(Map<String, dynamic> json)
      : listingURL = json['details_url'] ?? 'No listing URL',
        ocrSize = json['ocr_size'],
        status = json['status'] ?? 'No status',
        longitude = json['longitude'] ?? 'No longitude',
        latitude = json['latitude'] ?? 'No latitude',
        propertyType = json['property_type'] ?? 'No property type',
        imageURL = json['image_url'] ?? 'No image',
        price = json['price'] ?? 'No price',
        displayableAddress = json['displayable_address'] ?? 'No Address',
        floorPlan = json['floor_plan'] ?? [],
  markType = markTypeFromJSON(json['mark']);
}
