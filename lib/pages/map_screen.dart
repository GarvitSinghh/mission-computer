import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? target;
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  Timer? _timer;
  double? m1;
  double? m2;
  double? bearing;
  num? distance;
  // final String urlTemplate = 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png';
  // final String urlTemplate = 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png';
  // final String urlTemplate = 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
  // final String urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
  final String urlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  double mapZoom = 16;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) => _getCurrentLocation(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _latController.dispose();
    _lonController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(
          LatLng(position.latitude, position.longitude), _mapController.zoom);
    });

    setState(() {
      m1 = Geolocator.bearingBetween(
          _currentLocation?.latitude ?? 0,
          _currentLocation?.longitude ?? 0,
          position.latitude,
          position.longitude);
      m2 = Geolocator.bearingBetween(position.latitude, position.longitude,
          target?.latitude ?? 0, target?.longitude ?? 0);
      bearing = ((m1 ?? 0) - (m2 ?? 0)) % 360;
      bearing =
          (((bearing ?? 0) < 0) ? ((bearing ?? 0) + 360) : (bearing ?? 0));
      num lat1 = _currentLocation!.latitude;
      num lat2 = target!.latitude;
      num lon1 = _currentLocation!.longitude;
      num lon2 = target!.longitude;
      num a = sin((lat2 - lat1) / 2 * pi / 180) *
              sin((lat2 - lat1) / 2 * pi / 180) +
          cos(lat1 * pi / 180) *
              cos(lat2 * pi / 180) *
              sin((lon2 - lon1) / 2 * pi / 180) *
              sin((lon2 - lon1) / 2 * pi / 180);
      num c = 2 * atan2(sqrt(a), sqrt(1 - a));
      distance = 6371000 * c;
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _currentLocation ?? LatLng(28.75, 77.13),
                      zoom: mapZoom,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: urlTemplate,
                        subdomains: const ['a', 'b', 'c'],
                        tileProvider:
                            FMTC.instance('mapStore').getTileProvider(),
                      ),
                      MarkerLayer(
                        markers: [
                          if (target != null)
                            Marker(
                              width: 30.0,
                              height: 30.0,
                              point: target!,
                              builder: (ctx) => const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            ),
                          if (_currentLocation != null)
                            Marker(
                              width: 30.0,
                              height: 30.0,
                              point: _currentLocation!,
                              builder: (ctx) => const Icon(
                                Icons.location_on,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              _currentLocation ?? LatLng(0, 0),
                              (target ?? _currentLocation) ?? LatLng(0, 0)
                            ],
                            color: Colors.blue,
                            strokeWidth: 2.5,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (distance != null)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child:
                            Text('${distance!.toStringAsFixed(2)} metres away'),
                      ),
                    ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 8),
                                child: TextField(
                                  controller: _latController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  style: const TextStyle(color: Colors.white70),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      labelText: "Latitude...",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 8),
                                child: TextField(
                                  controller: _lonController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  style: const TextStyle(color: Colors.white70),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      labelText: "Longitude...",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        GestureDetector(
                          onTap: () {
                            String lat = _latController.value.text;
                            String lon = _lonController.value.text;
                            setState(() {
                              target = LatLng(
                                  double.tryParse(lat)!, double.tryParse(lon)!);
                            });
                          },
                          child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.shade900,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.check)),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        border:
                            Border.all(color: Theme.of(context).canvasColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          '${(_currentLocation?.latitude.toString() ?? 0.0).toString()}, ${(_currentLocation?.longitude.toString() ?? 0.0).toString()}',
                          style: TextStyle(color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: -75,
                      left: 15,
                      child: SizedBox(width: 120, child: direction()))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget direction() {
    return Stack(
      children: <Widget>[
        SvgPicture.asset(
          height: MediaQuery.of(context).size.width - 50,
          "assets/images/Circle.svg",
          color: Colors.black54,
        ),
        Container(
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: (bearing ?? 0) * (math.pi / 180),
            child: SvgPicture.asset(
                height: MediaQuery.of(context).size.width - 50,
                "assets/images/Dial.svg",
                color: Colors.red),
          ),
        ),
        Positioned(
          bottom: 140,
          left: 50,
          child: Container(
            child: Text(
              '${(((bearing ?? 0) > 180) ? (360 - (bearing ?? 0)) : (bearing ?? 0)).round()}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
