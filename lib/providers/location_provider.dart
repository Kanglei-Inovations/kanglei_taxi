import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


class LocationProvider {
  Future<String> getLocationAndAddress() async {

    String currentAddress='';
    // Initialize Firebase Analytics
    bool isLoading = true;
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print(
          'Error Location permissions are permanently denied, we cannot request permissions.');
    }
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (kDebugMode) {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
      }
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          forceAndroidLocationManager: true);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks[0];

      String currentAddress = "";

      if (place.name != null && place.name!.isNotEmpty) {
        currentAddress += place.name! + ",";
      }

      if (placemarks.length >= 2 && placemarks[1].thoroughfare != null && placemarks[1].thoroughfare!.isNotEmpty) {
        currentAddress += placemarks[1].thoroughfare! + ",";
      }

      if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
        currentAddress += place.thoroughfare! + ",";
      }

      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        currentAddress += place.subLocality! + ",";
      }

      if (place.locality != null && place.locality!.isNotEmpty) {
        currentAddress += place.locality! + ",";
      }

      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        currentAddress += place.administrativeArea! + ",";
      }

      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        currentAddress += "Pin-${place.postalCode}";
      }

// Remove trailing comma if currentAddress is not empty
      if (currentAddress.isNotEmpty && currentAddress.endsWith(',')) {
        currentAddress = currentAddress.substring(0, currentAddress.length - 1);
      }

      isLoading = false;
      return currentAddress;
    } catch (e) {
      print(e);
      return ''; // Return an empty string if there's an error
    }
  }

  Future<Position> getLatandLon() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print(
          'Error Location permissions are permanently denied, we cannot request permissions.');
    }
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (kDebugMode) {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
      }
    });
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      );

      // Print position details for debugging
      if (kDebugMode) {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
      }

      return position; // Return the obtained position

  }
  Future<String> getAddressFromLatLon(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      String address = "";

      if (placemarks.length >= 2 && placemarks[1].thoroughfare != null && placemarks[1].thoroughfare!.isNotEmpty) {
        address += (placemarks[1].thoroughfare! + ",");
      }

      if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
        address += (place.thoroughfare! + ",");
      }

      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        address += place.subLocality! + ",";
      }

      if (place.locality != null && place.locality!.isNotEmpty) {
        address += place.locality! + ",";
      }

      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        address += place.administrativeArea! + ",";
      }

      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        address += "Pin-${place.postalCode}";
      }

// Remove trailing comma if address is not empty
      if (address.isNotEmpty && address.endsWith(',')) {
        address = address.substring(0, address.length - 1);
      }

      return address;
    } catch (e) {
      print(e);
      return ''; // Return an empty string if there's an error
    }
  }

}

