import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String latitude = "--";
  String longitude = "--";
  String status = "Esperando ubicación...";

  @override
  void initState() {
    super.initState();
    initializeGPS();
  }

  Future<void> initializeGPS() async {
    await requestPermissions();
    await getLocation();
  }

  Future<void> requestPermissions() async {
    var locationStatus = await Permission.location.request();

    if (!locationStatus.isGranted) {
      setState(() {
        status = "Permiso de ubicación denegado";
      });
      return;
    }

    await Permission.locationAlways.request();
  }

  Future<void> getLocation() async {
    try {
      setState(() {
        status = "Obteniendo ubicación...";
      });

      final position = await LocationService.getCurrentLocation();

      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        status = "Ubicación obtenida correctamente";
      });
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPS Tracker"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 80,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Latitud",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),

                  Text(
                    latitude,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Longitud",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),

                  Text(
                    longitude,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: getLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Actualizar ubicación"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}