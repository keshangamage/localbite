import 'package:geolocator/geolocator.dart';

enum LocationStatus { granted, denied, deniedForever, serviceDisabled }

class LocationResult {
  const LocationResult({required this.status, this.position});

  final LocationStatus status;
  final Position? position;
}

class LocationService {
  Future<LocationResult> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(status: LocationStatus.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(status: LocationStatus.deniedForever);
    }
    if (permission == LocationPermission.denied) {
      return const LocationResult(status: LocationStatus.denied);
    }

    final position = await Geolocator.getCurrentPosition();
    return LocationResult(status: LocationStatus.granted, position: position);
  }

  double distanceInKm({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    final metres = Geolocator.distanceBetween(
      fromLatitude,
      fromLongitude,
      toLatitude,
      toLongitude,
    );
    return metres / 1000;
  }
}

String locationMessage(LocationStatus status) {
  switch (status) {
    case LocationStatus.serviceDisabled:
      return 'Location services are turned off. Turn them on to see '
          'restaurants near you.';
    case LocationStatus.denied:
      return 'Location permission was denied. You can still browse all '
          'restaurants.';
    case LocationStatus.deniedForever:
      return 'Location permission is permanently denied. Enable it in '
          'Settings to see nearby restaurants.';
    case LocationStatus.granted:
      return '';
  }
}
