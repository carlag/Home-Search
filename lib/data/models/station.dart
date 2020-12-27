class Station {
  double? distance; // in metres
  double? duration; //in seconds
  String? name;

  Station.fromJson(Map<String, dynamic> json)
      : name = json['address'] ?? 'No name',
        distance = json['distance'] ?? 'No distance',
        duration = json['duration'] ?? 'No time';
}
