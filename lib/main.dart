import 'package:flutter/material.dart';
import 'package:mission_comp/pages/home_page.dart';
import 'package:mission_comp/theme/model_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool locationEnabled = false;

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    print("Checking Permission");
    if (await Permission.location.isDenied) {
      // Location permission is not granted
      final PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        // Location permission granted, do something
        setState(() {
          locationEnabled = true;
        });
        // e.g., navigate to another screen, fetch location, etc.
      } else {
        locationEnabled = false;
        // Location permission denied, show an error message or handle accordingly
      }
    } else if (await Permission.location.isGranted) {
      locationEnabled = true;
      // Location permission is already granted
      // Do something, e.g., navigate to another screen, fetch location, etc.
    } else if (await Permission.location.isPermanentlyDenied) {
      locationEnabled = false;
      // Location permission is permanently denied, show a dialog to open settings
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Please enable location permission from the app settings.'),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OPEN SETTINGS'),
              onPressed: () => openAppSettings(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
          return MaterialApp(
            home: locationEnabled
                ? const HomePage()
                : const HandleLocationPermission(),
            debugShowCheckedModeBanner: false,
            theme: themeNotifier.isDark
                ? ThemeData.dark().copyWith(
                    cardColor: const Color.fromARGB(195, 255, 255, 255))
                : ThemeData.light().copyWith(
                    cardColor: Colors.black, primaryColorDark: Colors.white),
          );
        },
      ),
    );
  }
}

class HandleLocationPermission extends StatelessWidget {
  const HandleLocationPermission({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insufficient Permissions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Text(
              "Enable Location Permission to Use the Application",
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            TextButton(
                onPressed: () => {openAppSettings()},
                child: const Text(
                  "Grant Permission from App Settings",
                  style: TextStyle(fontSize: 18),
                ))
          ],
        ),
      ),
    );
  }
}
