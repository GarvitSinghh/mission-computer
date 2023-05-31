import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class SatellitePage extends StatefulWidget {
  const SatellitePage({super.key});

  @override
  State<SatellitePage> createState() => _SatellitePageState();
}

class _SatellitePageState extends State<SatellitePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Satellite Page'),
        ),
        body: Center(
          child: SizedBox(
              height: 50,
              width: 300,
              child: FloatingActionButton(
                  onPressed: () async {
                    await LaunchApp.openApp(
                        androidPackageName: 'se.tg3.gpsviewer');
                  },
                  child: const Center(
                    child: Text(
                      "Open",
                      textAlign: TextAlign.center,
                    ),
                  ))),
        ),
      ),
    );
  }
}
