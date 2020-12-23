class Station {
  double? distance;
  double? time;
  String? name;

  Station.fromJson(Map<String, dynamic> json)
      : name = json['address'] ?? 'No name',
        distance = json['distance'] ?? 'No distance',
        time = json['duration'] ?? 'No time';
}
