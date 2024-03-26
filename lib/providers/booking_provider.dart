import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart'; // Import the LatLng class if not already imported

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> submitBooking({
    required String type,
    required String fees,
    required String pickupLocation,
    required String destinationLocation,
    required DateTime date,
    required String distance,
    required LatLng currentPosition,
    required LatLng destinationPosition,
    required status,
  })  async {
    try {
      String? userId;
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
      }

      await _firestore.collection('bookings').add({
        'fees': fees,
        'type': type,
        'userId': userId,
        'pickupLocation': pickupLocation,
        'destinationLocation': destinationLocation,
        'distance': distance,
        'currentPosition': GeoPoint(currentPosition.latitude, currentPosition.longitude),
        'destinationPosition': GeoPoint(destinationPosition.latitude, destinationPosition.longitude),
        'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
        'status': status,
      });

      notifyListeners();
      print('Booking submitted successfully.');
      return true;
    } catch (error) {
      notifyListeners();
      print('Error submitting booking: $error');
      return false;
    }

  }
}
