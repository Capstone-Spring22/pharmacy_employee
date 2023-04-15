class Leg {
  List<Steps>? steps;
  String? summary;
  num? weight;
  num? duration;
  num? distance;

  Leg({this.steps, this.summary, this.weight, this.duration, this.distance});

  Leg.fromJson(Map<String, dynamic> json) {
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps!.add(Steps.fromJson(v));
      });
    }
    summary = json['summary'];
    weight = json['weight'];
    duration = json['duration'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    data['summary'] = summary;
    data['weight'] = weight;
    data['duration'] = duration;
    data['distance'] = distance;
    return data;
  }
}

class Steps {
  String? geometry;
  String? mode;
  String? drivingSide;
  String? name;
  num? weight;
  num? duration;
  num? distance;

  Steps(
      {this.geometry,
      this.mode,
      this.drivingSide,
      this.name,
      this.weight,
      this.duration,
      this.distance});

  Steps.fromJson(Map<String, dynamic> json) {
    geometry = json['geometry'];
    mode = json['mode'];
    drivingSide = json['driving_side'];
    name = json['name'];
    weight = json['weight'];
    duration = json['duration'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geometry'] = geometry;
    data['mode'] = mode;
    data['driving_side'] = drivingSide;
    data['name'] = name;
    data['weight'] = weight;
    data['duration'] = duration;
    data['distance'] = distance;
    return data;
  }
}
