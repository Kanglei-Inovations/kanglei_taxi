import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
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
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _pickupAddressController =
      TextEditingController();
  TextEditingController destinationAddressController = TextEditingController();
  double _zoom = 15.0;
  LatLng _currentLocation = const LatLng(
      24.8072292, 93.9383859); // Initialize with default coordinates
  LatLng _destinationLocation =
      const LatLng(0.0, 0.0); // Initialize with default coordinates
// Initial value, you can adjust it
  List<LatLng> _routeCoordinates = []; // Declare _routeCoordinates as a field
  bool _isLoading = false;
  String _distance = '';
  String? selectedType;
  int? selectedCardIndex;
  BookingProvider bookingProvider = BookingProvider();
  DateTime selectedDateTime =
      DateTime.now(); // Define selectedDateTime variable
  Position? position;
  List<bool> _isSelectedRecent = [];
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
    _isLoading = true;
    String accessToken =
        "pk.eyJ1IjoiYWZzYW5veCIsImEiOiJjanhpd28wenMxdXdiM3ltanB0NjRvZGVzIn0.GpZx0z1EXZk6AJJ6bTlT1Q";
    String url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/${_currentLocation.longitude},${_currentLocation.latitude};${_destinationLocation.longitude},${_destinationLocation.latitude}?steps=true&geometries=polyline&access_token=$accessToken";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      List<dynamic> routes = decodedResponse["routes"];
      if (routes.isNotEmpty) {
        String encodedPolyline = routes[0]["geometry"];
        setState(() {
          _routeCoordinates = _decodePolyline(encodedPolyline);
          if (kDebugMode) {
            print(_routeCoordinates);
          }
          _calculateDistance();
        });
      }
    } else {
      // Handle error
      if (kDebugMode) {
        print("Error getting route: ${response.statusCode}");
      }
    }
  }

  Future<void> _calculateDistance() async {
    // Get the current position using geolocator
    Position currentPosition = await Geolocator.getCurrentPosition();

    // Calculate the distance between current position and destination
    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      _destinationLocation.latitude,
      _destinationLocation.longitude,
    );

    // Convert distance to kilometers
    double distanceInKm = distanceInMeters / 1000;

    // Update the _distance field with the calculated distance
    setState(() {
      _distance = '${distanceInKm.toStringAsFixed(2)} km';
      if (kDebugMode) {
        print(_distance);
      }
      _isLoading = false;
    });
  }

  void _initializeScreen() async {
    setState(() {
      _isLoading = true;
    });
    try {
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permission services are not enabled.');
        }
        await Geolocator.requestPermission();
      }
      position = await LocationProvider().getLatandLon();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position!.latitude, position!.longitude);
        });
        String address = await LocationProvider().getLocationAndAddress();
        if (address.isNotEmpty) {
          setState(() {
            _pickupAddressController.text = address;
            _isLoading =
                false; // Set isLoading to false after obtaining the address
          });
        } else {
          const KIinfoBar(
            title: "Error",
            message: "Can't get Location",
            bgcolor: Colors.red,
          );
        }
      } else {
        const KIinfoBar(
          title: "Error",
          message: "Can't get Location",
          bgcolor: Colors.red,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: kIsWeb
          ? AppBar(
              backgroundColor: const Color(0xFF836FFF),
              title: const Text('Download App and Install'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.file_download),
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
                visible: _isLoading,
                child: const Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.greenAccent,
                  color: AppColors.primary,
                )),
              ),
            ),
          ),
          Visibility(
            visible: !_isLoading, // Show only if not loading
            child: GestureDetector(
              onScaleUpdate: (ScaleUpdateDetails details) {
                // Update map zoom level based on pinch gesture scale
                setState(() {
                  _zoom = _zoom * details.scale.clamp(0.5, 5.0);
                });
              },
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _currentLocation != null
                      ? _currentLocation
                      : LatLng(24.8090634, 93.9436556),
                  initialZoom: _zoom,
                  // bearing: bearing,
                  // Initial zoom level
                  onTap: (tapPosition, latLng) async {
                    setState(() {
                      _destinationLocation = latLng;
                    });
                    String address = await LocationProvider()
                        .getAddressFromLatLon(
                            latLng.latitude, latLng.longitude);
                    if (kDebugMode) {
                      print("Address: $address");
                    }
                    if (address.isNotEmpty) {
                      setState(() {
                        // _zoom = _zoom +5;
                        _getRoute();
                        destinationAddressController.text = address;
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
                        point: _currentLocation,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.black,
                          size: 30.0,
                        ),
                      ),
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point:
                            _destinationLocation, // Use _destination for the destination point
                        child: const Icon(
                          Icons.business,
                          color: Colors.black,
                          size: 30.0,
                        ),
                      ),
                    ],
                  ),
                  const RichAttributionWidget(
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
                  child: Container(
                    alignment: Alignment.center,
                    width: w - 10,
                    height: 300,
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
                            margin: const EdgeInsets.all(
                                10), // Adjust margin as needed
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  15), // Adjust border radius as needed
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              style: const TextStyle(
                                color: Colors.black, // Set the text color here
                              ),
                              controller: _pickupAddressController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Pickup Address',
                                prefixIcon: const Icon(Icons.home),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.gps_fixed_sharp,
                                      color: Colors.green),
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    // Call getLatandLon function to get current location
                                    _isLoading = true;
                                    Position position =
                                        await LocationProvider().getLatandLon();
                                    if (position != null) {
                                      setState(() {
                                        // Update _center with the obtained latitude and longitude
                                        _currentLocation = LatLng(
                                            position.latitude,
                                            position.longitude);
                                      });
                                      // Update the pickup address field with the obtained address
                                      String address = await LocationProvider()
                                          .getLocationAndAddress();
                                      if (address.isNotEmpty) {
                                        setState(() {
                                          _pickupAddressController.text =
                                              address;
                                          _isLoading = false;
                                        });
                                        if (kDebugMode) {
                                          print(address);
                                        }
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
                                if (kDebugMode) {
                                  print(text);
                                }
                              },
                              onSubmitted: (data) {
                                if (kDebugMode) {
                                  print(data.length);
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 95,
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
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.transparent),
                                        ),
                                        child: const SizedBox(
                                          width: double.infinity,
                                          height: 40,
                                        )),
                                  ); // Show a loading indicator while waiting for data
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                // Initialize isSelected list with false values for each location
                                if (_isSelectedRecent.isEmpty) {
                                  _isSelectedRecent = List.generate(
                                      snapshot.data!.docs.length,
                                      (index) => false);
                                }
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot document =
                                        snapshot.data!.docs[index];
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;
                                    String locationName = data['location_name'];
                                    GeoPoint latLng = data['latlng'];
                                    return GestureDetector(
                                      onTap: () async {
                                        // Set the selected location name and index when a card is tapped
                                        setState(() {
                                          _distance = '';
                                          _isLoading = true;
                                          // Update _center with the obtained latitude and longitude
                                          _currentLocation = LatLng(
                                              latLng.latitude,
                                              latLng.longitude);
                                          // Clear previous selection
                                          if (kDebugMode) {
                                            print(_currentLocation);
                                          }
                                          _isSelectedRecent = List.generate(
                                              snapshot.data!.docs.length,
                                              (index) => false);
                                          _isSelectedRecent[index] =
                                              true; // Select the current card
                                        });
                                        String address =
                                            await LocationProvider()
                                                .getAddressFromLatLon(
                                                    latLng.latitude,
                                                    latLng.longitude);

                                        if (address.isNotEmpty) {
                                          if (kDebugMode) {
                                            print("Address: $address");
                                          }
                                          setState(() {
                                            _pickupAddressController.text =
                                                address;
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 5, 5, 0),
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: _isSelectedRecent[index]
                                              ? const Color(0xFF836FFF)
                                              : AppColors.shrinePurple,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.transparent),
                                        ),
                                        child: Text(
                                          locationName,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 140,
                          left: 5,
                          right: 5,
                          child: Container(
                            margin: const EdgeInsets.all(
                                10), // Adjust margin as needed
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  15), // Adjust border radius as needed
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              style: const TextStyle(
                                color: Colors.black, // Set the text color here
                              ),
                              controller: destinationAddressController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Destination Address:',
                                prefixIcon: const Icon(Icons.business),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.pin_drop,
                                      color: Colors.red),
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
                          top: 235,
                          left: 15,
                          right: 15,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Flexible(
                                child: Container(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                                  child: const Text(
                                    'Select Dated:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.black45),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
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
                                        // const Text.rich(
                                        //   TextSpan(
                                        //     children: [
                                        //       TextSpan(
                                        //         text: "Dated:",
                                        //         style: TextStyle(
                                        //             fontWeight:
                                        //                 FontWeight.bold,
                                        //             fontSize: 18,
                                        //             color: Colors.black),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.calendar_month_rounded,
                                          size: 25,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          DateFormat('E, dd MMM | hh:mm a')
                                              .format(selectedDateTime),
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                  destinationAddressController.text,
                              date: selectedDateTime,
                              distance: _distance,
                              currentPosition: _currentLocation,
                              destinationPosition: _destinationLocation,
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
                    child: const Row(
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
            ),
          ),
        ],
      ),
    );
  }
}
