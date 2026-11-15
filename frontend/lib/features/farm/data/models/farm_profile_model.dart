class FarmProfileModel {
  const FarmProfileModel({
    required this.farmName,
    required this.location,
    required this.cultivatedArea,
    required this.soilType,
    required this.currentCrop,
    required this.waterSource,
    this.areaUnit = 'Acres',
    this.country,
    this.governorate,
    this.latitude,
    this.longitude,
  });

  final String farmName;
  final String location;
  final double cultivatedArea;
  final String soilType;
  final String currentCrop;
  final String waterSource;

  /// Original input unit; cultivatedArea remains normalized to acres.
  final String areaUnit;

  /// The country and first-level administrative region selected by the farmer.
  /// Nullable for backwards compatibility with previously saved profiles.
  final String? country;
  final String? governorate;

  /// WGS84 decimal degrees (EPSG:4326), as selected by the farmer.
  /// Legacy profiles may have no coordinates.
  final double? latitude;
  final double? longitude;

  static bool coordinatesAreValid(double? lat, double? lon) =>
      lat != null &&
      lon != null &&
      lat.isFinite &&
      lon.isFinite &&
      lat >= -90 &&
      lat <= 90 &&
      lon >= -180 &&
      lon <= 180;

  bool get hasCoordinates => coordinatesAreValid(latitude, longitude);

  /// Ready for the backend location request: no inferred or sample values.
  bool get hasCompleteLocation =>
      hasCoordinates &&
      (country?.trim().isNotEmpty ?? false) &&
      (governorate?.trim().isNotEmpty ?? false);

  /// Only the four fields agreed on with the backend team.
  /// Caller should verify hasCompleteLocation before submitting.
  Map<String, dynamic> toBackendLocationJson() => {
    'country': country,
    'governorate': governorate,
    'latitude': latitude,
    'longitude': longitude,
  };

  double get displayArea => areaUnit == 'Hectares'
      ? cultivatedArea / 2.471053814671653
      : cultivatedArea;

  Map<String, dynamic> toJson() {
    return {
      'farmName': farmName,
      'location': location,
      'cultivatedArea': cultivatedArea,
      'soilType': soilType,
      'currentCrop': currentCrop,
      'waterSource': waterSource,
      'areaUnit': areaUnit,
      'country': country,
      'governorate': governorate,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory FarmProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmProfileModel(
      farmName: json['farmName'] as String,
      location: json['location'] as String,
      cultivatedArea: (json['cultivatedArea'] as num).toDouble(),
      soilType: json['soilType'] as String,
      currentCrop: json['currentCrop'] as String,
      waterSource: json['waterSource'] as String,
      areaUnit: json['areaUnit'] == 'Hectares' ? 'Hectares' : 'Acres',
      country: json['country'] as String?,
      governorate: json['governorate'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
