import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

Future<void> initializeService() async {

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {

  Timer.periodic(
    const Duration(seconds: 30),
    (timer) async {

      Position position =
          await Geolocator.getCurrentPosition();

      print(
        "${position.latitude}, ${position.longitude}",
      );

      service.invoke(
        'location',
        {
          "lat": position.latitude,
          "lng": position.longitude,
        },
      );
    },
  );
}