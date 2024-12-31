import 'package:maple_harvest_app/core/core.dart';

class LocationArguments {
  final String location;

  LocationArguments({required this.location});

  factory LocationArguments.fromJson(Map<String, dynamic> json) {
    return LocationArguments(
      location: json.getString('location', defaultValue: 'Default Location'),
    );
  }
}
