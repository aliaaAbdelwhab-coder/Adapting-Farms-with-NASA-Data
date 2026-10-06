class FarmProfileModel {
  const FarmProfileModel({
    required this.farmName,
    required this.location,
    required this.cultivatedArea,
    required this.soilType,
    required this.currentCrop,
    required this.waterSource,
  });

  final String farmName;
  final String location;
  final double cultivatedArea;
  final String soilType;
  final String currentCrop;
  final String waterSource;

  Map<String, dynamic> toJson() {
    return {
      'farmName': farmName,
      'location': location,
      'cultivatedArea': cultivatedArea,
      'soilType': soilType,
      'currentCrop': currentCrop,
      'waterSource': waterSource,
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
    );
  }
}
