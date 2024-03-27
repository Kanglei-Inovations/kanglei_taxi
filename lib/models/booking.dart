import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:latlong2/latlong.dart'; // Import the LatLng class if not already imported

class Booking {
  final String type;
  final String fees;
  final String pickupLocation;
  final String destinationLocation;
  final DateTime date;
  final String distance;
  final LatLng currentPosition; // Change type to LatLng
  final LatLng destinationPosition;
  final status;// Change type to LatLng

  Booking({
    required this.type,
    required this.fees,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.date,
      required this.distance,
    required this.currentPosition, // Change type to LatLng
    required this.destinationPosition, // Change type to LatLng
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'feees': fees,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
      'distance': distance,
      'currentPosition': GeoPoint(currentPosition.latitude, currentPosition.longitude), // Convert LatLng to GeoPoint
      'destinationPosition': GeoPoint(destinationPosition.latitude, destinationPosition.longitude),
      'status': status// Convert LatLng to GeoPoint
    };
  }
}
