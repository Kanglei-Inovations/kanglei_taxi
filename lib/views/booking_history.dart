
import 'dart:convert';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kanglei_taxi/conts/firebase/color_constants.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
class BookingHistory extends StatefulWidget {
  const BookingHistory({Key? key}) : super(key: key);

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
    Future<void> _downloadTicket(String type, String pickupLocation, String destinationLocation, String distance, String date, String fees) async {
    // Create a new PDF document
    final PdfDocument document = PdfDocument();

    // Add a page to the document
    final PdfPage page = document.pages.add();

    // Create a PDF font
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

    // Draw text on the page
    page.graphics.drawString('Ride Ticket', font, bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 20));

    page.graphics.drawString('Type: $type', font, bounds: Rect.fromLTWH(0, 30, page.getClientSize().width, 20));
    page.graphics.drawString('Pickup: $pickupLocation', font, bounds: Rect.fromLTWH(0, 60, page.getClientSize().width, 20));
    page.graphics.drawString('Destination: $destinationLocation', font, bounds: Rect.fromLTWH(0, 90, page.getClientSize().width, 20));
    page.graphics.drawString('Distance: $distance', font, bounds: Rect.fromLTWH(0, 120, page.getClientSize().width, 20));
    page.graphics.drawString('Date: $date', font, bounds: Rect.fromLTWH(0, 150, page.getClientSize().width, 20));
    page.graphics.drawString('Fees: $fees', font, bounds: Rect.fromLTWH(0, 180, page.getClientSize().width, 20));

    // Save the document
    final List<int> bytes = await document.save();

    // Dispose the document
    document.dispose();

    // Write PDF to a file
    final String dir = (await getExternalStorageDirectory())!.path;
    final String path = '$dir/ride_ticket.pdf';
    final File file = File(path);
    await file.writeAsBytes(bytes);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PDFViewerPage(path: path),
    //   ),
    // );

  }


  Future<void> initiateTransaction({required String paymentLink}) async {
        if (await canLaunch(paymentLink)) {
      await launch(paymentLink);
    } else {
      throw 'Could not launch $paymentLink';
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No ride history available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot booking = snapshot.data!.docs[index];
              String type = booking['type'];
              String fees = booking['fees'];
              String docId = booking.id; // Get the document ID

              String pickupLocation = booking['pickupLocation'];
              String destinationLocation = booking['destinationLocation'];
              String distance = booking['distance'];
              DateTime dateTime = (booking['date'] as Timestamp).toDate();
              String date = DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
              String status= booking['status'];
              String userId = booking['userId'];
              String paymentLink = booking['paymentLink'];
              return Dismissible(
                key: UniqueKey(), // Unique key for each Dismissible widget
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.burningorage,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    // Show a confirmation dialog before deletion (optional)
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Deletion"),
                        content: Text("Are you sure you want to Cancel Booking"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // Cancel deletion
                            },
                            child: Text("Close"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // Confirm deletion
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      ),
                    );
                  }
                  return false;
                },
                onDismissed: (direction) {
                  // Delete the document from Firestore
                  FirebaseFirestore.instance.collection('bookings').doc(docId).delete();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.topLeft,

                            child: Text(
                              'Booking Date :' +
                                  date,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Divider(
                            height: 10.0,
                            color: Colors.amber.shade500,
                          ),
                          Row(
                            children: [
                              Icon(Icons.place,color:Colors.green),
                              SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  ' $pickupLocation',

                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.business),
                              SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  ' $destinationLocation',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 10.0,
                            color: Colors.amber.shade500,
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // Display order ID
                              Container(
                                padding: EdgeInsets.all(3.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Payment Status',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 3.0),
                                      child: Text(
                                        status,
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Display order amount
                              Container(
                                padding: EdgeInsets.all(3.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Fare Amount',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 3.0),
                                      child: Text(
                                        '₹ ' + fees.toString(),
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Display payment status
                              Container(
                                padding: EdgeInsets.all(3.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Car Type',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: 3.0),
                                        child: Text(type,
                                          style: Theme.of(context).textTheme.subtitle1,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              // Display payment type

                            ],
                          ),
                          Divider(
                            height: 10.0,
                            color: Colors.amber.shade500,
                          ),
                          Visibility(
                            visible: fees.isNotEmpty,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: ElevatedButton.icon(
                                    label: Text(
                                      "Print Invoice",
                                      style: TextStyle(color: Colors.white,fontSize: 14),
                                    ),
                                    icon: const Icon(
                                      Icons.print,
                                      size: 18.0,
                                      color: Colors.white, // Set icon color to white
                                    ),
                                    onPressed: () {
                                      _downloadTicket(type, pickupLocation, destinationLocation, distance, date, fees);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary, // Set the background color to red
                                    ),
                                  ),
                                ),
                                Center(
                                  child: ElevatedButton.icon(
                                    label: Text('Pay Now'),
                                    icon: const Icon(
                                      Icons.print,
                                      size: 18.0,
                                      color: Colors.white, // Set icon color to white
                                    ),
                                    onPressed: () {
                                      print(paymentLink);
                                      initiateTransaction( paymentLink: paymentLink);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary, // Set the background color to red
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



                ),
              );
            },
          );
        },
      ),
    );
  }
}
