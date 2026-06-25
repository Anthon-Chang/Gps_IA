import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class SavedLocation {
  final double latitude;
  final double longitude;
  final DateTime time;
  final String formattedTime;

  SavedLocation({
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.formattedTime,
  });
}

class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  // Notificadores de estado para vincular con la UI
  final ValueNotifier<bool> isTracking = ValueNotifier<bool>(false);
  final ValueNotifier<List<SavedLocation>> locations = ValueNotifier<List<SavedLocation>>([]);

  // 1. Inicializar y solicitar permisos
  Future<bool> requestPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Verificar si el servicio de GPS está activo
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        debugPrint("El servicio de ubicación está desactivado.");
        return false;
      }
    }

    // Verificar permisos de ubicación
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        debugPrint("Permisos de ubicación denegados.");
        return false;
      }
    }
    
    return true;
  }

  // 2. Iniciar el rastreo en segundo plano
  Future<void> startBackgroundTracking() async {
    if (isTracking.value) return;

    bool hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      debugPrint("No se pudieron otorgar los permisos necesarios.");
      return;
    }

    try {
      // Intentar habilitar el modo en segundo plano (requiere permisos de Background Location en Android)
      bool bgEnabled = await _location.enableBackgroundMode(enable: true);
      debugPrint("Modo segundo plano habilitado: $bgEnabled");
    } catch (e) {
      debugPrint("Error habilitando segundo plano (común en emuladores): $e");
    }

    // Configurar la precisión y el filtro de distancia
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 5000,   // Obtener actualizaciones cada 5 segundos
      distanceFilter: 2, // Registrar al moverse más de 2 metros
    );

    // Configurar la notificación persistente (requerida por Android para Foreground Service)
    await _location.changeNotificationOptions(
      title: 'GPS de BG-Tracker Activo',
      subtitle: 'Registrando tu ubicación en segundo plano...',
      iconName: 'mipmap/ic_launcher',
    );

    // Comenzar a escuchar la corriente de ubicaciones
    _locationSubscription = _location.onLocationChanged.listen((LocationData data) {
      if (data.latitude != null && data.longitude != null) {
        _saveLocation(data.latitude!, data.longitude!, data.time);
      }
    });

    isTracking.value = true;
    debugPrint("Servicio de ubicación en segundo plano iniciado.");
  }

  // 3. Detener el rastreo
  Future<void> stopBackgroundTracking() async {
    if (!isTracking.value) return;

    await _locationSubscription?.cancel();
    _locationSubscription = null;
    
    try {
      await _location.enableBackgroundMode(enable: false);
    } catch (e) {
      debugPrint("Error al desactivar el modo segundo plano: $e");
    }

    isTracking.value = false;
    debugPrint("Servicio de ubicación en segundo plano detenido.");
  }

  // Guardar ubicación y notificar a la UI
  void _saveLocation(double lat, double lng, double? timeMs) {
    final time = timeMs != null
        ? DateTime.fromMillisecondsSinceEpoch(timeMs.toInt())
        : DateTime.now();
        
    final formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";

    final newLoc = SavedLocation(
      latitude: lat,
      longitude: lng,
      time: time,
      formattedTime: formattedTime,
    );

    // Agregar al principio del historial (ubicación más reciente primero)
    locations.value = [newLoc, ...locations.value];
    debugPrint("Nueva ubicación registrada: Lat $lat, Lng $lng a las $formattedTime");
  }

  // Limpiar historial
  void clearHistory() {
    locations.value = [];
  }
}
