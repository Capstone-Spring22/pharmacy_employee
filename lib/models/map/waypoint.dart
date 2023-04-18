// ignore_for_file: public_member_api_docs, sort_constructors_first
class Waypoint {
  num? waypointIndex;
  num? tripsIndex;
  String? hint;
  double? distance;
  String? name;
  List<double>? location;

  Waypoint(
      {this.waypointIndex,
      this.tripsIndex,
      this.hint,
      this.distance,
      this.name,
      this.location});

  Waypoint.fromJson(Map<String, dynamic> json) {
    waypointIndex = json['waypoint_index'];
    tripsIndex = json['trips_index'];
    hint = json['hint'];
    distance = json['distance'];
    name = json['name'];
    location = json['location'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['waypoint_index'] = waypointIndex;
    data['trips_index'] = tripsIndex;
    data['hint'] = hint;
    data['distance'] = distance;
    data['name'] = name;
    data['location'] = location;

    return data;
  }

  @override
  String toString() {
    return 'Waypoint(waypointIndex: $waypointIndex, tripsIndex: $tripsIndex, hint: $hint, distance: $distance, name: $name, location: $location)';
  }
}
