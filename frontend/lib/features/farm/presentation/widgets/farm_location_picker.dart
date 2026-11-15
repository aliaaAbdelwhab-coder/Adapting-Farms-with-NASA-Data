import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';

/// A real interactive map: a tap selects a WGS84 point.
/// No point is assumed from the device location or from the old Figma image.
class FarmLocationPicker extends StatelessWidget {
  const FarmLocationPicker({
    super.key,
    required this.height,
    required this.selectedPoint,
    this.initialCenter,
    required this.onSelected,
  });

  final double height;
  final LatLng? selectedPoint;
  /// Approximate country center for initial navigation, never farm coordinates.
  final LatLng? initialCenter;
  final ValueChanged<LatLng> onSelected;

  @override
  Widget build(BuildContext context) {
    final initialPoint = selectedPoint ?? initialCenter ?? const LatLng(18, 10);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: initialPoint,
                initialZoom: selectedPoint != null ? 14 : initialCenter != null ? 5 : 2.5,
                minZoom: 2,
                maxZoom: 19,
                onTap: (_, point) => onSelected(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.fieldshift.app',
                  maxNativeZoom: 19,
                ),
                if (selectedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedPoint!,
                        width: 48,
                        height: 48,
                        alignment: Alignment.bottomCenter,
                        child: const Icon(
                          Icons.location_pin,
                          size: 46,
                          color: AppColors.primaryGreen,
                          shadows: [Shadow(blurRadius: 5, color: Colors.white)],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      child: Text(
                        'Zoom in and tap the exact farm point',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 5,
              bottom: 5,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Text('© OpenStreetMap contributors',
                        style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
