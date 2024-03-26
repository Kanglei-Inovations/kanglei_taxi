import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'package:http/http.dart' as http;
import 'package:kanglei_taxi/conts/firebase/color_constants.dart';
import 'package:kanglei_taxi/providers/booking_provider.dart';
import 'package:kanglei_taxi/providers/location_provider.dart';
import 'package:kanglei_taxi/views/taxi_list.dart';
import 'package:kanglei_taxi/widget/ki_info_bar.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _pickupAddressController = TextEditingController();
  TextEditingController distinationaddressController = TextEditingController();
  double _zoom = 15.0;
  LatLng _currentlocation =
      LatLng(24.8072292, 93.9383859); // Initialize with default coordinates
  LatLng _destinationlocation =
      LatLng(0.0, 0.0); // Initialize with default coordinates
// Initial value, you can adjust it
  List<LatLng> _routeCoordinates = []; // Declare _routeCoordinates as a field
  bool _isloading = false;
  String _distance = '';
  String? selectedType;
  int? selectedCardIndex;
  BookingProvider bookingProvider = BookingProvider();
  DateTime selectedDateTime =
      DateTime.now(); // Define selectedDateTime variable
  Position? position;
  List<bool> _isSelectedrecent = [];
  List<LatLng> _decodePolyline(String encodedPolyline) {
    // Initialize PolylinePoints
    PolylinePoints polylinePoints =
        PolylinePoints(); // Decode encoded polyline to list of LatLng points
    List<PointLatLng> decodedPolyline = polylinePoints.decodePolyline(
        encodedPolyline); // Convert list of PointLatLng to list of LatLng
    List<LatLng> points = decodedPolyline
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    return points;
  }

  Future<void> _getRoute() async {
    _isloading = true;
    String accessToken =
        "pk.eyJ1IjoiYWZzYW5veCIsImEiOiJjanhpd28wenMxdXdiM3ltanB0NjRvZGVzIn0.GpZx0z1EXZk6AJJ6bTlT1Q";
    String url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/${_currentlocation.longitude},${_currentlocation.latitude};${_destinationlocation.longitude},${_destinationlocation.latitude}?steps=true&geometries=polyline&access_token=$accessToken";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      List<dynamic> routes = decodedResponse["routes"];
      if (routes.isNotEmpty) {
        String encodedPolyline = routes[0]["geometry"];
        setState(() {
          _routeCoordinates = _decodePolyline(encodedPolyline);
          print(_routeCoordinates);
          _calculateDistance();
        });
      }
    } else {
      // Handle error
      print("Error getting route: ${response.statusCode}");
    }
  }

  Future<void> _calculateDistance() async {
    // Get the current position using geolocator
    Position currentPosition = await Geolocator.getCurrentPosition();

    // Calculate the distance between current position and destination
    double distanceInMeters = await Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      _destinationlocation.latitude,
      _destinationlocation.longitude,
    );

    // Convert distance to kilometers
    double distanceInKm = distanceInMeters / 1000;

    // Update the _distance field with the calculated distance
    setState(() {
      _distance = '${distanceInKm.toStringAsFixed(2)} km';
      print(_distance);
      _isloading = false;
    });
  }

  void _initializeScreen() async {
    setState(() {
      _isloading = true;
    });
    try {
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission services are not enabled.');
        await Geolocator.requestPermission();
      }
      position = await LocationProvider().getLatandLon();
      if (position != null) {
        setState(() {
          _currentlocation = LatLng(position!.latitude, position!.longitude);
        });
        String address = await LocationProvider().getLocationAndAddress();
        if (address.isNotEmpty) {
          setState(() {
            _pickupAddressController.text = address;
            _isloading =
                false; // Set isLoading to false after obtaining the address
          });
        } else {
          KIinfoBar(
            title: "Error",
            message: "Can't get Location",
            bgcolor: Colors.red,
          );
        }
      } else {
        KIinfoBar(
          title: "Error",
          message: "Can't get Location",
          bgcolor: Colors.red,
        );
      }
    } catch (e) {
      print(e);
      _initializeScreen();
    }

    //
  }

  Stream<String> getLatestAppLinkStream() {
    return FirebaseFirestore.instance
        .collection('app_links')
        .orderBy('upload_timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Extract the latest app link from the snapshot
        final latestAppLink = snapshot.docs.first;
        launchUrl(latestAppLink['link']);
        return latestAppLink['link'];
      } else {
        // Return a default value or throw an error if no app link found
        throw 'No app link found';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: kIsWeb
          ? AppBar(
              backgroundColor: Color(0xFF836FFF),
              title: Text('Download App and Install'),
              actions: [
                IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () {
                    getLatestAppLinkStream();
                  },
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Positioned(
            top: 150,
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 20,
              width: 20,
              child: Visibility(
                visible: _isloading,
                child: Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.greenAccent,
                  color: AppColors.primary,
                )),
              ),
            ),
          ),
          Visibility(
            visible: !_isloading, // Show only if not loading
            child: GestureDetector(
              onScaleUpdate: (ScaleUpdateDetails details) {
                // Update map zoom level based on pinch gesture scale
                setState(() {
                  _zoom = _zoom * details.scale.clamp(0.5, 5.0);
                });
              },
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _currentlocation != null
                      ? _currentlocation
                      : LatLng(24.8090634, 93.9436556),
                  initialZoom: _zoom,
                  // bearing: bearing,
                  // Initial zoom level
                  onTap: (tapPosition, latLng) async {
                    setState(() {
                      _destinationlocation = latLng;
                    });
                    String address = await LocationProvider()
                        .getAddressFromLatLon(
                            latLng.latitude, latLng.longitude);
                    print("Address: $address");
                    if (address.isNotEmpty) {
                      setState(() {
                        // _zoom = _zoom +5;
                        _getRoute();
                        distinationaddressController.text = address;
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.kangleiinovations.kanglei_taxi',
                  ),
                  PolylineLayer(
                    polylines: [
                      if (_routeCoordinates
                          .isNotEmpty) // Check if _routeCoordinates is not empty
                        Polyline(
                          points:
                              _routeCoordinates, // Pass _routeCoordinates directly
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _currentlocation,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.black,
                          size: 30.0,
                        ),
                      ),
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point:
                            _destinationlocation, // Use _destination for the destination point
                        child: Icon(
                          Icons.business,
                          color: Colors.black,
                          size: 30.0,
                        ),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [],
                  ),
                  // MarkerLayerOptions(
                  //   markers: [
                  //     Marker(
                  //       width: 80.0,
                  //       height: 80.0,
                  //       point: _currentlocation,
                  //       builder: (ctx) => Container(
                  //         child: Icon(
                  //           Icons.location_pin,
                  //           color: Colors.black,
                  //           size: 30.0,
                  //         ),
                  //       ),
                  //     ),
                  //     Marker(
                  //       width: 80.0,
                  //       height: 80.0,
                  //       point:
                  //       _destinationlocation, // Use _destination for the destination point
                  //       builder: (ctx) => Icon(
                  //         Icons.business,
                  //         color: Colors.black,
                  //         size: 30.0,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          Positioned(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 45,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: w - 10,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            left: 5,
                            right: 5,
                            child: Container(
                              margin:
                                  EdgeInsets.all(10), // Adjust margin as needed
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    15), // Adjust border radius as needed
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                style: TextStyle(
                                  color:
                                      Colors.black, // Set the text color here
                                ),
                                controller: _pickupAddressController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Pickup Address',
                                  prefixIcon: Icon(Icons.home),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.gps_fixed_sharp,
                                        color: Colors.green),
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      // Call getLatandLon function to get current location
                                      _isloading = true;
                                      Position position =
                                          await LocationProvider()
                                              .getLatandLon();
                                      if (position != null) {
                                        setState(() {
                                          // Update _center with the obtained latitude and longitude
                                          _currentlocation = LatLng(
                                              position.latitude,
                                              position.longitude);
                                        });
                                        // Update the pickup address field with the obtained address
                                        String address =
                                            await LocationProvider()
                                                .getLocationAndAddress();
                                        if (address.isNotEmpty) {
                                          setState(() {
                                            _pickupAddressController.text =
                                                address;
                                            _isloading = false;
                                          });
                                          print(address);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Can't Locate",
                                              backgroundColor: Colors.red);
                                        }
                                      } else {
                                        // Handle the case where the current location couldn't be obtained
                                        Fluttertoast.showToast(
                                            msg: "Can't Locate",
                                            backgroundColor: Colors.red);
                                      }
                                    },
                                  ),
                                ),
                                onChanged: (text) {
                                  print(text);
                                },
                                onSubmitted: (data) {
                                  print(data.length);
                                },
                              ),
                            ),
                          ),
                          Positioned(
                              top: 85,
                              left: 20,
                              right: 20,
                              child: SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('recent_location')
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.transparent),
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 40,
                                            )),
                                      ); // Show a loading indicator while waiting for data
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    // Initialize isSelected list with false values for each location
                                    if (_isSelectedrecent.isEmpty) {
                                      _isSelectedrecent = List.generate(
                                          snapshot.data!.docs.length,
                                          (index) => false);
                                    }
                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot document =
                                            snapshot.data!.docs[index];
                                        Map<String, dynamic> data = document
                                            .data() as Map<String, dynamic>;
                                        String locationName =
                                            data['location_name'];
                                        GeoPoint latLng = data['latlng'];
                                        return GestureDetector(
                                          onTap: () async {
                                            // Set the selected location name and index when a card is tapped
                                            setState(() {
                                              _distance = '';
                                              _isloading = true;
                                              // Update _center with the obtained latitude and longitude
                                              _currentlocation = LatLng(
                                                  latLng.latitude,
                                                  latLng.longitude);
                                              // Clear previous selection
                                              print(_currentlocation);
                                              _isSelectedrecent = List.generate(
                                                  snapshot.data!.docs.length,
                                                  (index) => false);
                                              _isSelectedrecent[index] =
                                                  true; // Select the current card
                                            });
                                            String address =
                                                await LocationProvider()
                                                    .getAddressFromLatLon(
                                                        latLng.latitude,
                                                        latLng.longitude);

                                            if (address.isNotEmpty) {
                                              print("Address: $address");
                                              setState(() {
                                                _pickupAddressController.text =
                                                    address;
                                                _isloading = false;
                                              });
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: _isSelectedrecent[index]
                                                    ? Color(0xFF836FFF)
                                                    : AppColors.shrinePurple,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.transparent),
                                              ),
                                              child: Text(
                                                locationName,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              )),
                          Positioned(
                            top: 120,
                            left: 5,
                            right: 5,
                            child: Container(
                              margin:
                                  EdgeInsets.all(10), // Adjust margin as needed
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    15), // Adjust border radius as needed
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                style: TextStyle(
                                  color:
                                      Colors.black, // Set the text color here
                                ),
                                controller: distinationaddressController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Distination Address:',
                                  prefixIcon: Icon(Icons.business),
                                  suffixIcon: IconButton(
                                    icon:
                                        Icon(Icons.pin_drop, color: Colors.red),
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      Fluttertoast.showToast(
                                        msg: "Select From Map",
                                        backgroundColor: Colors.red,
                                      );
                                    },
                                  ),
                                ),
                                onChanged: (text) {
                                  Fluttertoast.showToast(
                                    msg: "Select From Map",
                                    backgroundColor: Colors.red,
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 210,
                            left: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  // Row instead of Expanded
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final DateTime? selectedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                        );
                                        if (selectedDate != null) {
                                          final TimeOfDay? selectedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (selectedTime != null) {
                                            setState(() {
                                              selectedDateTime = DateTime(
                                                selectedDate.year,
                                                selectedDate.month,
                                                selectedDate.day,
                                                selectedTime.hour,
                                                selectedTime.minute,
                                              );
                                            });
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Date:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.calendar_month_rounded,
                                            size: 25,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            "${DateFormat('E, dd MMM | hh:mm a').format(selectedDateTime)}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  SizedBox(
                    // Added SizedBox to limit button width
                    width: MediaQuery.of(context).size.width / 2,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaxiList(
                                type: selectedType ?? '',
                                pickupLocation: _pickupAddressController.text,
                                destinationLocation:
                                    distinationaddressController.text,
                                date: selectedDateTime,
                                distance: _distance,
                                currentPosition: _currentlocation,
                                destinationPosition: _destinationlocation,
                                fees: '',
                                status: 'Pending'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.burningorage,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "FIND TAXI",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.local_taxi,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
