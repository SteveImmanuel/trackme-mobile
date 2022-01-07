class Location {
  String latitude;
  String longitude;
  String name;
  bool alertOnLeave;
  bool alertOnArrive;

  Location(
    this.latitude,
    this.longitude,
    this.name,
    this.alertOnLeave,
    this.alertOnArrive,
  );

  Location.fromJson(Map<String, dynamic> data)
      : latitude = data['latitude'],
        longitude = data['longitude'],
        name = data['name'],
        alertOnLeave = data['alert_on_leave'],
        alertOnArrive = data['alert_on_arrive'];

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'name': name,
        'alert_on_leave': alertOnLeave,
        'alert_on_arrive': alertOnArrive,
      };
}
