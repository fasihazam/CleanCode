import 'package:maple_harvest_app/core/core.dart';

class LocationModel {
  static const longNameKey = 'long_name';
  static const shortNameKey = 'short_name';
  static const typesKey = 'types';
  static const resultsKey = 'results';
  static const addressComponentsKey = 'address_components';
  static const formattedAddressKey = 'formatted_address';
  static const mainTextKey = 'main_text';
  static const secondaryTextKey = 'secondary_text';
  static const placeIdKey = 'place_id';
  static const descriptionKey = 'description';
  static const administrativeAreaLevel1 = 'administrative_area_level_1';
  static const administrativeAreaLevel2 = 'administrative_area_level_2';
  static const postalCodeKey = 'postal_code';
  static const String latitudeKey = 'latitude';
  static const String longitudeKey = 'longitude';

  final String? longName;
  final String? shortName;
  final List<String> types;
  final String? formattedAddress;
  final String? mainText;
  final String? secondaryText;
  final String? placeId;
  final String? description;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  const LocationModel({
    this.longName,
    this.shortName,
    this.types = const [],
    this.formattedAddress,
    this.mainText,
    this.secondaryText,
    this.placeId,
    this.description,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory LocationModel.fromAddressComponentJson(Map<String, dynamic> json) {
    return LocationModel(
      longName: json.getString(longNameKey),
      shortName: json.getString(shortNameKey),
      types: json.getList<String>(typesKey, (item) => item as String),
    );
  }

  factory LocationModel.fromGeocodeResponseJson(Map<String, dynamic> json) {
    final results = json.getList<Map<String, dynamic>>(
      resultsKey,
      (item) => item as Map<String, dynamic>,
    );

    final addressComponents = results.isNotEmpty
        ? results.first.getList<Map<String, dynamic>>(
            addressComponentsKey,
            (item) => item as Map<String, dynamic>,
          )
        : [];

    return LocationModel(
      formattedAddress: results.first.getString(formattedAddressKey),
      city: addressComponents
          .cast<Map<String, dynamic>>()
          .getComponentByType(administrativeAreaLevel2),
      state: addressComponents
          .cast<Map<String, dynamic>>()
          .getComponentByType(administrativeAreaLevel1, useShortName: true)
          ?.toUpperCase(),
      postalCode: addressComponents
          .cast<Map<String, dynamic>>()
          .getComponentByType(postalCodeKey),
    );
  }

  factory LocationModel.fromIOSLocationJson(Map<String, dynamic> json) {
    return LocationModel(
      mainText: json['mainText'] ?? '',
      secondaryText: json['secondaryText'] ?? '',
      placeId: json['placeId'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
  factory LocationModel.fromLocationJson(Map<String, dynamic> json) {
    return LocationModel(
      mainText: json.getString(mainTextKey),
      secondaryText: json.getString(secondaryTextKey),
      placeId: json.getStringOrNull(placeIdKey),
    );
  }
  factory LocationModel.fromPredictionJson(Map<String, dynamic> json) {
    return LocationModel(
      mainText: json['structured_formatting']?[mainTextKey] ?? '',
      secondaryText: json['structured_formatting']?[secondaryTextKey] ?? '',
      placeId: json[placeIdKey] ?? '',
      latitude: json[latitudeKey] as double?,
      longitude: json[longitudeKey] as double?,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      longNameKey: longName,
      shortNameKey: shortName,
      typesKey: types,
      formattedAddressKey: formattedAddress,
      mainTextKey: mainText,
      secondaryTextKey: secondaryText,
      placeIdKey: placeId,
      descriptionKey: description,
      administrativeAreaLevel2: city,
      administrativeAreaLevel1: state,
      postalCodeKey: postalCode,
      latitudeKey: latitude,
      longitudeKey: longitude,
    }.removeEmptyOrNull;
  }
}

extension GetComponentByType on List<Map<String, dynamic>> {
  /// Extension to extract a specific component by type
  String? getComponentByType(String type, {bool useShortName = false}) {
    try {
      final component = firstWhere(
        (c) => (c[LocationModel.typesKey] as List?)?.contains(type) == true,
        orElse: () => {},
      );

      return useShortName
          ? component[LocationModel.shortNameKey] as String?
          : component[LocationModel.longNameKey] as String?;
    } catch (e) {
      return null;
    }
  }
}
