import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanglei_taxi/conts/firebase/color_constants.dart';
import 'package:kanglei_taxi/nav_bar.dart';
import 'package:latlong2/latlong.dart';
class TankYou extends StatefulWidget {
  final String type;
  final String pickupLocation;
  final String destinationLocation;
  final String distance;
  final LatLng currentPosition;
  final LatLng destinationPosition;
  final String fees;
  final String status;
  final DateTime date;
  const TankYou({Key? key, required this.type,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.distance,
    required this.currentPosition,
    required this.destinationPosition,
    required this.fees,
    required this.status,
    required this.date}) : super(key: key);

  @override
  State<TankYou> createState() => _TankYouState();
}

class _TankYouState extends State<TankYou> {
  timeout() async{
    await Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(Navbar());

    });
  }
  @override
  void initState() {
    super.initState();
    timeout();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          title: Text("Chouse Taxi",
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
     body: ListView(
    children: [
    Container(
    child: Column(
    children: [
    Column(
    mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(left: 100, right: 100, top: 100),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('images/verified.png')
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text("Order Completed",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.left),
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
                "Your booking is completed",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3a3a3b),
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.left),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 100, right: 100, top: 10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    textStyle: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Navbar(),
                      ));
                },
                child: Center(
                  child: Text(
                    "HOME",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    )
    ],
    ),
    )
    ],
    ),
    );
  }
}
