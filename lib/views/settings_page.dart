import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kanglei_taxi/conts/firebase/color_constants.dart';
import 'package:kanglei_taxi/conts/firebase/firestore_constants.dart';
import 'package:kanglei_taxi/providers/auth_provider.dart';
import 'package:kanglei_taxi/views/signin_page.dart';


import 'package:provider/provider.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';


class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? photoUrl;
  File? _image;
  bool isLoading = false;
  late final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        if (_image != null) {
          setState(() {
            isLoading = true;
          });
          uploadFile();
        }
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    setState(() {
      isLoading = true; // Set isLoading to true to show the shimmer effect
    });
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'profile/$fileName';
    Reference reference = firebaseStorage.ref().child(path);
    try {
      TaskSnapshot snapshot = await reference.putFile(_image!);
      photoUrl = await snapshot.ref.getDownloadURL();
      print(photoUrl);
      Fluttertoast.showToast(msg: "Updated Profile Picture");
      // Update photoUrl field in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      final displayName = user?.displayName ?? "No Username";

      await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .doc(user!.uid)
          .update({'photoUrl': photoUrl});
      await user.updateProfile(
        photoURL: photoUrl,
        displayName: displayName,
      );
      // phoneNumber, you can also refresh the user to get the updated data
      await user.reload();
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        isLoading =
        false; // Set isLoading to false to hide the shimmer effect after uploading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderlocal>(context);
    User? user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "No Username";
    photoUrl = user?.photoURL ?? null;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Center(
                  child: Stack(
                    alignment: Alignment.center, // Align the children of the Stack to the center
                    children: [
                      GestureDetector(
                        onTap: getImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            photoUrl == null
                                ? CircleAvatar(backgroundImage: AssetImage("images/Profile-Pic-Demo.png"), radius: 60)
                                : CircleAvatar(
                              child: ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder: "images/Profile-Pic-Demo.png",
                                  image: photoUrl!,
                                  fit: BoxFit.cover,
                                  width: 200,
                                  height: 120,
                                ),
                              ),
                              radius: 60,
                            ),
                            if (isLoading)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: ClipOval(
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    child: WaveWidget(
                                      config: CustomConfig(
                                        gradients: [
                                          [Colors.deepPurpleAccent, Color(0xEE836FFF)],
                                          [Colors.redAccent, Color(0x77211951)],
                                          [Colors.blueGrey, Color(0x66211951)],
                                          [Colors.deepPurpleAccent, Color(0xEE836FFF)]
                                        ],
                                        durations: [35000, 19440, 10800, 6000],
                                        heightPercentages: [0.20, 0.23, 0.25, 0.30],
                                        gradientBegin: Alignment.bottomLeft,
                                        gradientEnd: Alignment.topRight,
                                        blur: MaskFilter.blur(BlurStyle.solid, 4),
                                      ),
                                      size: Size(double.infinity, double.infinity),
                                      waveAmplitude: 0,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: Colors.greenAccent,
                                size: 30,
                              ),
                            ),
                            // Add other Positioned widgets as needed
                          ],
                        ),
                      ),


                    ],
                  ),
                ),



                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(displayName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String newName = displayName; // Initialize with current display name
                            return AlertDialog(
                              title: Text("Edit Display Name"),
                              content: TextField(
                                controller: TextEditingController(text: newName),
                                decoration: InputDecoration(hintText: "Enter your new display name"),
                                onChanged: (value) {
                                  newName = value;
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    User? user = FirebaseAuth.instance.currentUser;
                                    final photoURL = user?.photoURL ?? "No Pic";
                                    await user!.updateProfile(
                                      photoURL: photoURL,
                                      displayName: newName,
                                    );
                                    // phoneNumber, you can also refresh the user to get the updated data
                                    await user.reload();
                                    setState(()  {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).pop();
                                    });
                                  // Close the dialog
                                  },
                                  child: Text("Save"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(shape: CircleBorder(), backgroundColor: AppColors.primary.withOpacity(0.16)),
                      child: Icon(Icons.edit, color: AppColors.primary),
                    ),

                  ],
                ),

                SizedBox(height: 20),
                Divider(),
                Text(
                  'General Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Notifications'),
                  trailing: Switch(
                    value: true, // Add functionality to toggle notifications
                    onChanged: (value) {},
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Language'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to language selection page
                  },
                ),
                Divider(),

                SizedBox(height: 10),
                ListTile(
                    title: Text('Reset Password'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    subtitle: Text("${user!.email}"),
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null && user.email != null && user.email!.isNotEmpty) {
                        Fluttertoast.showToast(msg: "Link Send on Email");
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                      }
                      authProvider.signOut();
                      Get.offAll(SignInPage());
                    }
                ),

                Divider(),
                ListTile(
                  title: Text('Logout'),
                  trailing: Icon(Icons.exit_to_app),
                  onTap: () {
                    authProvider.signOut();
                    Get.offAll(SignInPage());
                  },
                ),
                // Divider(),
                // Text(
                //   'Admin Section',
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // Divider(),
                // ListTile(
                //   title: Text('Admin Chat'),
                //   trailing: Icon(Icons.chat),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => AdminChatList(),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
