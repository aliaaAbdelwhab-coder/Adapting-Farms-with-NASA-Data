/// Reference material only. Scores and traits here are UI illustrations,
/// NOT predictions or measurements for an individual farm.
class CropReferenceModel {
  const CropReferenceModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.role,
    required this.waterDemand,
    required this.soilContribution,
    required this.heatTolerance,
    required this.waterLevel,
    required this.soilLevel,
    required this.heatLevel,
    required this.fieldRole,
  }) : assert(waterLevel >= 0 && waterLevel <= 100),
       assert(soilLevel >= 0 && soilLevel <= 100),
       assert(heatLevel >= 0 && heatLevel <= 100);

  final String id;
  final String name;
  final String scientificName;
  final String role;
  final String waterDemand;
  final String soilContribution;
  final String heatTolerance;
  final int waterLevel;
  final int soilLevel;
  final int heatLevel;
  final String fieldRole;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scientificName': scientificName,
    'role': role,
    'waterDemand': waterDemand,
    'soilContribution': soilContribution,
    'heatTolerance': heatTolerance,
    'waterLevel': waterLevel,
    'soilLevel': soilLevel,
    'heatLevel': heatLevel,
    'fieldRole': fieldRole,
  };

  factory CropReferenceModel.fromJson(Map<String, dynamic> json) {
    String textField(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Expected a non-empty string for $key.');
      }
      return value;
    }

    int levelField(String key) {
      final value = json[key];
      if (value is! int || value < 0 || value > 100) {
        throw FormatException('$key must be an integer between 0 and 100.');
      }
      return value;
    }

    return CropReferenceModel(
      id: textField('id'),
      name: textField('name'),
      scientificName: textField('scientificName'),
      role: textField('role'),
      waterDemand: textField('waterDemand'),
      soilContribution: textField('soilContribution'),
      heatTolerance: textField('heatTolerance'),
      waterLevel: levelField('waterLevel'),
      soilLevel: levelField('soilLevel'),
      heatLevel: levelField('heatLevel'),
      fieldRole: textField('fieldRole'),
    );
  }
}

/// Static Figma reference examples; not sourced from a NASA/API request.
const figmaCropReferenceExamples = <CropReferenceModel>[
  CropReferenceModel(
    id: 'corn',
    name: 'Corn',
    scientificName: 'Zea mays (Corn)',
    role: 'Cash Crop',
    waterDemand: 'High',
    soilContribution: 'Low',
    heatTolerance: 'Moderate',
    waterLevel: 92,
    soilLevel: 25,
    heatLevel: 68,
    fieldRole: 'Example cash crop. Its irrigation requirements depend on climate, soil, and growth stage.',
  ),
  CropReferenceModel(
    id: 'wheat',
    name: 'Wheat',
    scientificName: 'Triticum (Wheat)',
    role: 'Grain Rotation',
    waterDemand: 'Medium',
    soilContribution: 'Medium',
    heatTolerance: 'High',
    waterLevel: 57,
    soilLevel: 52,
    heatLevel: 78,
    fieldRole: 'Example grain crop used in rotations. Local growing-season conditions determine suitability.',
  ),
  CropReferenceModel(
    id: 'legume',
    name: 'Legume',
    scientificName: 'Soybean (Legume)',
    role: 'Soil Builder',
    waterDemand: 'Low',
    soilContribution: 'High',
    heatTolerance: 'Moderate',
    waterLevel: 40,
    soilLevel: 86,
    heatLevel: 65,
    fieldRole: 'Some legumes can support nitrogen cycling through biological fixation under suitable conditions.',
  ),
  CropReferenceModel(
    id: 'cover',
    name: 'Cover Crop',
    scientificName: 'Trifolium (Clover Cover)',
    role: 'Soil Restoration',
    waterDemand: 'Very Low',
    soilContribution: 'Very High',
    heatTolerance: 'High',
    waterLevel: 25,
    soilLevel: 95,
    heatLevel: 78,
    fieldRole: 'Example soil-cover crop; species and management should be chosen for local field conditions.',
  ),
];
