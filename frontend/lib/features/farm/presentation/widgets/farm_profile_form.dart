import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/state/fieldshift_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/farm_profile_model.dart';
import 'farm_location_picker.dart';

/// Farm profile form with an interactive, user-selected farm point.
class FarmProfileForm extends StatefulWidget {
  const FarmProfileForm({super.key});

  @override
  State<FarmProfileForm> createState() => _FarmProfileFormState();
}

class _FarmProfileFormState extends State<FarmProfileForm> {
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _otherCountryController = TextEditingController();
  final _governorateController = TextEditingController();
  final _cultivatedAreaController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  LatLng? _selectedFarmPoint;
  int _mapViewVersion = 0;
  String? _selectedCountry;

  // The "Other country" option keeps this UI usable worldwide, without
  // assuming every farm is in the preset countries.
  static const _countryOptions = <String>[
    'Egypt',
    'Saudi Arabia',
    'Jordan',
    'Qatar',
    'United Arab Emirates',
    'Kuwait',
    'Bahrain',
    'Oman',
    'Morocco',
    'Tunisia',
    'Algeria',
    'Sudan',
    'Lebanon',
    'Iraq',
    'Turkey',
    'Canada',
    'South Korea',
    'United States',
    'United Kingdom',
    'India',
    'Pakistan',
    'Other country...',
  ];

  static const _initialCountryCenters = <String, LatLng>{
    'Egypt': LatLng(26.8, 30.8),
    'Saudi Arabia': LatLng(24.0, 45.0),
    'Jordan': LatLng(31.2, 36.2),
    'Qatar': LatLng(25.3, 51.2),
    'United Arab Emirates': LatLng(24.3, 54.4),
    'Kuwait': LatLng(29.3, 47.8),
    'Bahrain': LatLng(26.1, 50.5),
    'Oman': LatLng(21.4, 57.0),
    'Morocco': LatLng(31.8, -7.1),
    'Tunisia': LatLng(34.0, 9.4),
    'Algeria': LatLng(28.0, 2.6),
    'Sudan': LatLng(15.5, 30.2),
    'Lebanon': LatLng(33.9, 35.9),
    'Iraq': LatLng(33.2, 43.7),
    'Turkey': LatLng(39.0, 35.2),
    'Canada': LatLng(56.1, -106.3),
    'South Korea': LatLng(36.5, 127.9),
    'United States': LatLng(39.7, -98.5),
    'United Kingdom': LatLng(54.0, -2.5),
    'India': LatLng(22.5, 79.0),
    'Pakistan': LatLng(30.2, 69.3),
  };

  String get _countryValue => _selectedCountry == 'Other country...'
      ? _otherCountryController.text.trim()
      : (_selectedCountry ?? '');

  String? _selectedSoilType;
  String? _selectedCrop;
  String? _selectedWaterSource;
  String _areaUnit = 'Acres';

  static const _soilTypes = ['Loam', 'Clay', 'Sandy Loam'];
  static const _crops = ['Corn', 'Wheat', 'Soybean', 'Rice'];
  static const _waterSources = ['Irrigated', 'Rain-fed', 'Mixed'];

  @override
  void initState() {
    super.initState();
    final previous = FieldShiftSession.instance.takeEditProfile();
    if (previous == null) return;
    _farmNameController.text = previous.farmName;
    // New profiles serialize the display location as "City, Region, Country".
    // Strip the known suffix on Edit to avoid duplicating the region/country.
    final regionCountry =
        (previous.country?.trim().isNotEmpty ?? false) &&
        (previous.governorate?.trim().isNotEmpty ?? false)
        ? '${previous.governorate!.trim()}, ${previous.country!.trim()}'
        : null;
    if (regionCountry != null && previous.location == regionCountry) {
      _locationController.text = '';
    } else if (regionCountry != null &&
        previous.location.endsWith(', $regionCountry')) {
      _locationController.text = previous.location.substring(
        0,
        previous.location.length - regionCountry.length - 2,
      );
    } else {
      _locationController.text = previous.location;
    }
    final savedCountry = previous.country?.trim() ?? '';
    if (_countryOptions.contains(savedCountry) &&
        savedCountry != 'Other country...') {
      _selectedCountry = savedCountry;
    } else if (savedCountry.isNotEmpty) {
      _selectedCountry = 'Other country...';
      _otherCountryController.text = savedCountry;
    }
    _governorateController.text = previous.governorate ?? '';
    if (previous.hasCoordinates) {
      _setCoordinates(LatLng(previous.latitude!, previous.longitude!));
    }
    _areaUnit = previous.areaUnit;
    final amount = previous.displayArea;
    _cultivatedAreaController.text = amount.toStringAsFixed(
      amount == amount.roundToDouble() ? 0 : 2,
    );
    _selectedSoilType = _soilTypes.contains(previous.soilType)
        ? previous.soilType
        : null;
    _selectedCrop = _crops.contains(previous.currentCrop)
        ? previous.currentCrop
        : null;
    _selectedWaterSource = _waterSources.contains(previous.waterSource)
        ? previous.waterSource
        : null;
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _locationController.dispose();
    _otherCountryController.dispose();
    _governorateController.dispose();
    _cultivatedAreaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The 280px sidebar is outside this widget, in AppShell.
        final isWide = constraints.maxWidth >= 900;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 20,
            vertical: isWide ? 48 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(isWide),
              SizedBox(height: isWide ? 40 : 22),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 549, child: _buildDesktopFields()),
                    const SizedBox(width: 32),
                    Expanded(flex: 483, child: _buildDesktopMapAndWater()),
                  ],
                )
              else
                _buildMobileFields(),
              SizedBox(height: isWide ? 40 : 20),
              Align(
                alignment: isWide ? Alignment.centerRight : Alignment.center,
                child: SizedBox(
                  width: isWide ? null : double.infinity,
                  child: FilledButton.icon(
                    onPressed: _continueToPriorities,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: Text(
                      isWide ? 'Continue to Priorities' : 'Continue',
                      style: GoogleFonts.figtree(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isWide) {
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Step 1 of 4: Setup', style: _body(14)),
              const Spacer(),
              for (var i = 0; i < 4; i++) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0
                        ? AppColors.primaryGreen
                        : AppColors.borderSlate,
                  ),
                ),
                if (i != 3) const SizedBox(width: 7),
              ],
            ],
          ),
          const SizedBox(height: 28),
          Text('Set Up Your Farm', style: _heading(27)),
          const SizedBox(height: 6),
          Text(
            'Input attributes to match satellite telemetry profiles',
            style: _body(13, color: AppColors.textSecondary),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Step 1 of 4', style: _body(14)),
            const Spacer(),
            Text(
              '25% Complete',
              style: _body(14, color: AppColors.primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: const LinearProgressIndicator(
            value: 0.25,
            minHeight: 6,
            backgroundColor: AppColors.borderSlate,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Text('Set Up Your Farm Profile', style: _heading(28)),
      ],
    );
  }

  Widget _buildDesktopFields() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('General Farm Attributes', style: _heading(20)),
          const SizedBox(height: 24),
          _textField(
            label: 'Farm Name',
            helper: 'Assign a clear reference name for this operation',
            controller: _farmNameController,
            hint: 'Enter farm name',
          ),
          const SizedBox(height: 24),
          _areaField(showHelper: true),
          const SizedBox(height: 24),
          _selectionField(
            label: 'Primary Soil Composition',
            helper: 'Sourced from a local soil survey',
            hint: 'Select soil type',
            value: _selectedSoilType,
            options: _soilTypes,
            onChanged: (value) => setState(() => _selectedSoilType = value),
          ),
          const SizedBox(height: 24),
          _selectionField(
            label: 'Active Crop Cycle',
            helper: 'Crop currently planted or harvested in previous cycle',
            hint: 'Select current crop',
            value: _selectedCrop,
            options: _crops,
            onChanged: (value) => setState(() => _selectedCrop = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMapAndWater() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Geographical Location', style: _fieldLabel()),
        const SizedBox(height: 8),
        _countryAndGovernorateFields(),
        const SizedBox(height: 12),
        _locationInput(),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            return _mapPreview(
              height: constraints.maxWidth * 300 / 483,
              compact: false,
            );
          },
        ),
        const SizedBox(height: 24),
        _whiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Primary Water Source', style: _heading(16)),
              const SizedBox(height: 4),
              Text(
                'Determines crop variety options during peak hot seasons',
                style: _body(13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _waterSourceChoices(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFields() {
    return _whiteCard(
      padding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textField(
            label: 'Farm Name',
            controller: _farmNameController,
            hint: 'Enter farm name',
          ),
          const SizedBox(height: 20),
          Text('Geographical Location', style: _fieldLabel()),
          const SizedBox(height: 8),
          _countryAndGovernorateFields(),
          const SizedBox(height: 10),
          _locationInput(),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return _mapPreview(
                height: constraints.maxWidth * 300 / 483,
                compact: true,
              );
            },
          ),
          const SizedBox(height: 20),
          _areaField(),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _selectionField(
                  label: 'Soil Type',
                  hint: 'Select',
                  value: _selectedSoilType,
                  options: _soilTypes,
                  onChanged: (value) =>
                      setState(() => _selectedSoilType = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _selectionField(
                  label: 'Current Crop',
                  hint: 'Select',
                  value: _selectedCrop,
                  options: _crops,
                  onChanged: (value) => setState(() => _selectedCrop = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Primary Water Source', style: _fieldLabel()),
          const SizedBox(height: 8),
          _waterSourceChoices(),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child, double padding = 32}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: child,
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: _fieldLabel()),
        if (helper != null) ...[
          const SizedBox(height: 2),
          Text(helper, style: _body(12, color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: _body(14),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _areaField({bool showHelper = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Cultivated Area', style: _fieldLabel()),
        if (showHelper) ...[
          const SizedBox(height: 2),
          Text(
            'Enter total size of crop rotation zone',
            style: _body(12, color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cultivatedAreaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: _body(14),
                decoration: _inputDecoration('Enter area'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 136,
              child: DropdownButtonFormField<String>(
                initialValue: _areaUnit,
                isExpanded: true,
                style: _body(13),
                decoration: _inputDecoration('Unit'),
                items: const [
                  DropdownMenuItem(value: 'Acres', child: Text('Acres')),
                  DropdownMenuItem(value: 'Hectares', child: Text('Hectares')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _areaUnit = value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _selectionField({
    required String label,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: _fieldLabel()),
        if (helper != null) ...[
          const SizedBox(height: 2),
          Text(helper, style: _body(12, color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          hint: Text(
            hint,
            overflow: TextOverflow.ellipsis,
            style: _body(13, color: AppColors.textMuted),
          ),
          style: _body(13),
          decoration: _inputDecoration(null),
          items: options
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Country and first-level administrative region are explicit farmer inputs.
  /// We do not infer them from the map pin without a verified geocoding service.
  Widget _countryAndGovernorateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Country *', style: _fieldLabel()),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('country-$_selectedCountry'),
          initialValue: _selectedCountry,
          isExpanded: true,
          decoration: _inputDecoration('Select country'),
          style: _body(13),
          items: _countryOptions
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (value) {
            if (value == _selectedCountry) return;
            setState(() {
              _selectedCountry = value;
              _otherCountryController.clear();
              _governorateController.clear();
              // Avoid silently retaining a marker from a different country.
              _selectedFarmPoint = null;
              _latitudeController.clear();
              _longitudeController.clear();
              _mapViewVersion++;
            });
          },
        ),
        if (_selectedCountry == 'Other country...') ...[
          const SizedBox(height: 9),
          TextFormField(
            controller: _otherCountryController,
            style: _body(13),
            decoration: _inputDecoration('Enter country name *'),
          ),
        ],
        const SizedBox(height: 13),
        Text('Governorate / Region / Province *', style: _fieldLabel()),
        const SizedBox(height: 8),
        TextFormField(
          controller: _governorateController,
          style: _body(13),
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration('e.g. Alexandria, Makkah, Amman'),
        ),
        const SizedBox(height: 7),
        Text(
          'Confirm that the farm pin is in the country and region entered. '
          'Automatic boundary verification is not available yet.',
          style: _body(11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// An optional place name; coordinates must be selected separately.
  Widget _locationInput() {
    return TextFormField(
      controller: _locationController,
      style: _body(13),
      decoration: _inputDecoration('City / area (optional label)'),
    );
  }

  void _setCoordinates(LatLng point) {
    _selectedFarmPoint = point;
    _latitudeController.text = point.latitude.toStringAsFixed(6);
    _longitudeController.text = point.longitude.toStringAsFixed(6);
  }

  void _selectPoint(LatLng point) {
    if (!FarmProfileModel.coordinatesAreValid(point.latitude, point.longitude)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a point within valid coordinates.')),
      );
      return;
    }
    setState(() => _setCoordinates(point));
  }

  void _applyTypedCoordinates() {
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (!FarmProfileModel.coordinatesAreValid(latitude, longitude)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          'Enter latitude between -90 and 90 and longitude between -180 and 180.',
        )),
      );
      return;
    }
    setState(() {
      _setCoordinates(LatLng(latitude!, longitude!));
      // Recenter the map only for coordinates entered manually.
      _mapViewVersion++;
    });
  }

  /// The selected map point is not a survey-grade boundary or GPS reading.
  /// The map also supports typing decimal coordinates when tiles are unavailable.
  Widget _mapPreview({required double height, required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FarmLocationPicker(
          key: ValueKey(_mapViewVersion),
          height: height,
          selectedPoint: _selectedFarmPoint,
          initialCenter: _initialCountryCenters[_selectedCountry],
          onSelected: _selectPoint,
        ),
        const SizedBox(height: 9),
        Text(
          _selectedFarmPoint == null
              ? 'No farm point selected — choose a point on the map or enter coordinates.'
              : 'Selected point (WGS84 decimal degrees):',
          style: _body(12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true,
                ),
                onChanged: (_) => setState(() => _selectedFarmPoint = null),
                style: _body(13),
                decoration: _inputDecoration('Latitude (-90 to 90)').copyWith(
                  labelText: 'Latitude',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true,
                ),
                onChanged: (_) => setState(() => _selectedFarmPoint = null),
                style: _body(13),
                decoration: _inputDecoration('Longitude (-180 to 180)').copyWith(
                  labelText: 'Longitude',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _applyTypedCoordinates,
            icon: const Icon(Icons.place_outlined, size: 17),
            label: const Text('Apply coordinates'),
          ),
        ),
      ],
    );
  }

  Widget _waterSourceChoices() {
    return Row(
      children: [
        for (var i = 0; i < _waterSources.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _selectedWaterSource = _waterSources[i];
              }),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color: _selectedWaterSource == _waterSources[i]
                      ? AppColors.primaryGreen.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedWaterSource == _waterSources[i]
                        ? AppColors.primaryGreen
                        : AppColors.borderSlate,
                    width: _selectedWaterSource == _waterSources[i] ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedWaterSource == _waterSources[i]
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selectedWaterSource == _waterSources[i]
                          ? AppColors.primaryGreen
                          : AppColors.textMuted,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _waterSources[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _body(12, weight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _body(13, color: AppColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      isDense: true,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderSlate),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderSlate),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  TextStyle _heading(double fontSize) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
  }

  TextStyle _fieldLabel() {
    return GoogleFonts.figtree(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  TextStyle _body(
    double fontSize, {
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.figtree(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
    );
  }

  void _continueToPriorities() {
    final amount = double.tryParse(_cultivatedAreaController.text.trim());
    final acres = amount == null
        ? null
        : (_areaUnit == 'Hectares' ? amount * 2.471053814671653 : amount);

    final country = _countryValue;
    final governorate = _governorateController.text.trim();

    if (_farmNameController.text.trim().isEmpty ||
        country.isEmpty ||
        governorate.isEmpty ||
        _selectedFarmPoint == null ||
        !FarmProfileModel.coordinatesAreValid(
          _selectedFarmPoint?.latitude,
          _selectedFarmPoint?.longitude,
        ) ||
        acres == null ||
        !acres.isFinite ||
        acres <= 0 ||
        _selectedSoilType == null ||
        _selectedCrop == null ||
        _selectedWaterSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter country, governorate and all farm fields, then select a valid farm point.'),
        ),
      );
      return;
    }

    final city = _locationController.text.trim();
    final location = <String>[
      if (city.isNotEmpty && city.toLowerCase() != governorate.toLowerCase())
        city,
      governorate,
      country,
    ].join(', ');

    final farmProfile = FarmProfileModel(
      farmName: _farmNameController.text.trim(),
      location: location,
      country: country,
      governorate: governorate,
      latitude: _selectedFarmPoint!.latitude,
      longitude: _selectedFarmPoint!.longitude,
      cultivatedArea: acres,
      soilType: _selectedSoilType!,
      currentCrop: _selectedCrop!,
      waterSource: _selectedWaterSource!,
      areaUnit: _areaUnit,
    );

    Navigator.pushNamed(context, AppRouter.priorities, arguments: farmProfile);
  }
}
