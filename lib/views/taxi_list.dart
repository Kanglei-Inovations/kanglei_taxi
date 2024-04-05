import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanglei_taxi/conts/firebase/color_constants.dart';
import 'package:kanglei_taxi/conts/resposive_settings.dart';
import 'package:kanglei_taxi/providers/booking_provider.dart';
import 'package:kanglei_taxi/views/thank_you.dart';
import 'package:latlong2/latlong.dart';

class TaxiList extends StatefulWidget {
  final String type;
  final String pickupLocation;
  final String destinationLocation;
  final String distance;
  final LatLng currentPosition;
  final LatLng destinationPosition;
  final String fees;
  final String status;
  final DateTime date;

  const TaxiList(
      {Key? key,
      required this.type,
        required this.pickupLocation,
        required this.destinationLocation,
        required this.distance,
        required this.currentPosition,
        required this.destinationPosition,
        required this.fees,
        required this.status,
        required this.date})
      : super(key: key);

  @override
  State<TaxiList> createState() => _TaxiListState();
}

class _TaxiListState extends State<TaxiList> {
  String? selectedType;
  int? selectedCardIndex;
  BookingProvider bookingProvider = BookingProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          title: Text("Choose Taxi",
              style: TextStyle(color: Colors.black, fontSize: 18)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
          iconTheme: IconThemeData(
            color: AppColors.primary,
          )),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('taxi_fees').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    SizedBox(height: 100, child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No taxi details available.'));
          }
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String carName = data['driver_name'];
              double pricePerKm = data['fare_fees'];
              String driverNo = data['driver_contact_no'];
              String carPic = data['vehicle_photo'];
              String location = data['location']?? "Unknown";
              return GestureDetector(
                  onTap: () {
                    // Set the selected type and card index when a taxi card is tapped
                    setState(() {
                      selectedType = carName;
                      selectedCardIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ListTile(
                        onTap: () {},
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.black26,
                          ),
                          borderRadius:
                              BorderRadius.circular(ResponsiveFile.radius20 / 3),
                        ),
                      splashColor: Colors.deepPurpleAccent,
                        hoverColor: Colors.greenAccent.withOpacity(0.9),
                        leading: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(ResponsiveFile.radius20 / 4),
                          child: SizedBox(
                            height: ResponsiveFile.height130+30,
                            width: ResponsiveFile.height50+30,
                            child: CachedNetworkImage(
                              imageUrl: carPic,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.greenAccent,
                                        value: downloadProgress.progress),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                        title: Text(carName, style: Theme.of(context).textTheme.subtitle1,),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 18,color: AppColors.primary,),
                                Text(
                                  "${location.length > 15 ? location.substring(0, 15) + '...' : location}",
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.call,size:18, color: AppColors.primary,),
                                Text(driverNo, style:Theme.of(context).textTheme.subtitle2,),
                              ],
                            ),

                          ],
                        ),
                        trailing: SizedBox(
                          // Added SizedBox to limit button width
                          width: MediaQuery.of(context).size.width / 5,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async  {
                              bool isSuccess = await bookingProvider.submitBooking(
                                type: carName ?? '',
                                pickupLocation: widget.pickupLocation,
                                destinationLocation: widget.destinationLocation,
                                date: widget.date,
                                distance: widget.distance,
                                currentPosition: widget.currentPosition,
                                destinationPosition: widget.destinationPosition,
                                fees: "",
                                status: 'Pending',
                              );

                              if (isSuccess) {
                                Get.offAll(TankYou(
                                  type: carName ?? '',
                                  pickupLocation: widget.pickupLocation,
                                  destinationLocation: widget.destinationLocation,
                                  date: widget.date,
                                  distance: widget.distance,
                                  currentPosition: widget.currentPosition,
                                  destinationPosition: widget.destinationPosition,
                                  fees: '',
                                  status: 'Pending',
                                ));
                              } else {
                                // There was an error submitting the booking
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.burningorage,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "BOOK",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                    ),
                  )
              );
            },
          );
        },
      ),
    );
  }
}
