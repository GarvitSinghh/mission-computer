import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:fmtc_plus_background_downloading/fmtc_plus_background_downloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class DownloadMapScreen extends StatefulWidget {
  const DownloadMapScreen({super.key});

  @override
  State<DownloadMapScreen> createState() => DownloadMapScreenState();
}

class DownloadMapScreenState extends State<DownloadMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  Timer? _timer;
  final String urlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  int minZoom = 10;
  int maxZoom = 17;
  double mapZoom = 15;

  LatLng? topLeft;
  LatLng? bottomRight;

  bool createPolygon = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _getCurrentLocation(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation ?? LatLng(28.7041, 77.1025),
            zoom: 8,
            onTap: (tapPosition, point) => {
              if (topLeft != null && bottomRight != null)
                {
                  setState(() {
                    topLeft = null;
                    bottomRight = null;
                    createPolygon = false;
                  })
                }
              else if (topLeft == null)
                {
                  setState(() {
                    topLeft = point;
                  })
                }
              else if (bottomRight == null)
                {
                  setState(() {
                    bottomRight = point;
                    createPolygon = true;
                  })
                }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: urlTemplate,
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                if (_currentLocation != null)
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: _currentLocation!,
                    builder: (ctx) => const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                  ),
                if (topLeft != null)
                  Marker(
                    width: 30.0,
                    height: 30.0,
                    point: topLeft!,
                    builder: (ctx) => const Icon(
                      Icons.circle_rounded,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
                if (bottomRight != null)
                  Marker(
                    width: 30.0,
                    height: 30.0,
                    point: bottomRight!,
                    builder: (ctx) => const Icon(
                      Icons.circle_rounded,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
            const PolylineLayer(),
            PolygonLayer(
              polygons: [
                if (createPolygon)
                  Polygon(
                    points: [
                      topLeft!,
                      LatLng(topLeft!.latitude, bottomRight!.longitude),
                      bottomRight!,
                      LatLng(bottomRight!.latitude, topLeft!.longitude)
                    ],
                    borderColor: Colors.blue,
                    isFilled: true,
                    color: Colors.black26,
                    borderStrokeWidth: 2,
                  )
              ],
            )
          ],
        ),
        Positioned.fill(
          bottom: 30,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              child: const Text(
                "Download Map",
                style: TextStyle(fontSize: 17, fontFamily: "Poppins"),
              ),
              onPressed: () {
                if (createPolygon) {
                  final RectangleRegion region =
                      RectangleRegion(LatLngBounds(topLeft!, bottomRight!));
                  final DownloadableRegion<List<Object>> downloadable =
                      region.toDownloadable(
                    minZoom,
                    maxZoom,
                    TileLayer(
                      urlTemplate: urlTemplate,
                      userAgentPackageName: "com.example/mission_comp",
                    ),
                  );
                  print("Downloading");
                  FMTC
                      .instance('mapStore')
                      .download
                      .startBackground(region: downloadable);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
