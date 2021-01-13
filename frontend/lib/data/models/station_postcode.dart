class StationPostcode {
  final String name;
  final String postcode;

  StationPostcode({required this.name, required this.postcode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationPostcode &&
          name == other.name &&
          postcode == other.postcode;

  @override
  int get hashCode => name.hashCode;
}
