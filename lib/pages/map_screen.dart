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
  LatLng? target = LatLng(0, 0);
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  Timer? _timer;
  double? m1;
  double? m2;
  double? bearing;

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
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(
          LatLng(position.latitude, position.longitude), _mapController.zoom);
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: "Latitude ...",
          ),
          onChanged: (value) {
            setState(() {
              target = LatLng(
                  (double.tryParse(value) ?? 0.0), (target?.longitude ?? 0.0));
            });
          },
        ),
        TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: "Longitude ...",
          ),
          onChanged: (value) {
            setState(() {
              target = LatLng(
                  (target?.latitude ?? 0.0), (double.tryParse(value) ?? 0.0));
            });
          },
        ),
        Expanded(
            child: Stack(children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation ?? LatLng(28.75, 77.13),
              zoom: mapZoom,
            ),
            children: [
              TileLayer(
                // urlTemplate: FMTC.instance('mapStore'),
                subdomains: const ['a', 'b', 'c'],
                tileProvider: FMTC.instance('mapStore').getTileProvider(),
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
          Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    border: Border.all(color: Theme.of(context).canvasColor),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        '${(_currentLocation?.latitude.toString() ?? 0.0).toString()}, ${(_currentLocation?.longitude.toString() ?? 0.0).toString()}',
                        style: TextStyle(color: Theme.of(context).cardColor),
                      )))),
          Positioned(
              bottom: -110,
              left: 5,
              child: SizedBox(width: 120, child: direction()))
        ])),
      ],
    )));
  }

  Widget direction() {
    return Stack(children: <Widget>[
      SvgPicture.asset(
        height: MediaQuery.of(context).size.width - 50,
        "assets/images/Circle.svg",
        color: Theme.of(context).canvasColor,
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
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                border: Border.all(color: Theme.of(context).canvasColor),
              ),
              child: Text(
                '${(((bearing ?? 0) > 180) ? (360 - (bearing ?? 0)) : (bearing ?? 0)).round()}',
                style: TextStyle(color: Theme.of(context).cardColor),
              )))
    ]);
  }
}
