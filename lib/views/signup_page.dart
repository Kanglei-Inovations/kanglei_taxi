import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kanglei_taxi/conts/bezierContainer.dart';
import 'package:kanglei_taxi/conts/resposive_settings.dart';
import 'package:kanglei_taxi/providers/auth_provider.dart';
import 'package:kanglei_taxi/services/validation.dart';
import 'package:kanglei_taxi/views/signin_page.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../nav_bar.dart';



class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _registerFormKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _focusName = FocusNode();
  final _focusPhone = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool isLoading = false;
  File? _image;
  String photoUrl = '';
  bool _isProcessing = false;
  late final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  String _mobileNumber = '';


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
      Fluttertoast.showToast(msg: "Uploaded Profile Picture");
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        isLoading =
        false; // Set isLoading to false to hide the shimmer effect after uploading
      });
    }
  }
  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _mobileNumber = (await MobileNumber.mobileNumber)!;
      _mobileNumber = _mobileNumber.substring(max(0, _mobileNumber.length - 10));
      setState(() {
        phoneNumberController.text = _mobileNumber;
        print(_mobileNumber.toString());
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }
    if (!mounted) return;

  }




  @override
  void initState() {
    super.initState();
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
      } else {}
    });
    initMobileNumberState();
  }

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProviderlocal>(context);
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusPhone.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar:AppBar(
          title: Text('Register'),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -MediaQuery.of(context).size.height * .20,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: const BezierContainer()),
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: ResponsiveFile.height20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 50),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: getImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.deepPurpleAccent,
                              backgroundImage: _image != null ? FileImage(_image!) : null,
                              child: _image == null
                                  ? Icon(Icons.person, size: 100, color: Colors.white)
                                  : null,
                            ),
                          ),
                          if (photoUrl
                              .isNotEmpty) // Show tick mark if photoUrl is not empty
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Image.asset("images/verified.png")),
                          if (_image == null)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: Colors.greenAccent,
                                size: 30,
                              ),
                            ),
                          if (isLoading)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 100, // Diameter of the CircleAvatar (radius * 2)
                                height: 100, // Diameter of the CircleAvatar (radius * 2)
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
                        ],
                      ),

                      SizedBox(height: ResponsiveFile.height30),
                      Column(
                        children: <Widget>[

                          Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: Form(
                                  key: _registerFormKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      TextFormField(
                                        validator: (value) => Validator.validateName(
                                          name: value,
                                        ),

                                        controller: nameController,
                                        focusNode: _focusName,
                                        autofillHints: [AutofillHints.name],
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(color: Colors.black),
                                            contentPadding:
                                            const EdgeInsets.only(left: 25.0),
                                            focusColor: Colors.redAccent,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(25),
                                              borderSide: const BorderSide(
                                                  color: Colors.deepOrange),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            //border: InputBorder.none,
                                            fillColor: const Color(0xFF836FFF),
                                            filled: true,
                                            labelStyle: TextStyle(
                                                color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold // Change the color of the label text here
                                            ),
                                            labelText: "Enter Name"),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(height: 20.0),
                                      TextFormField(
                                        validator: (value) => Validator.validatePhone(
                                          phone: value,
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: phoneNumberController,
                                        autofillHints: [AutofillHints.telephoneNumber ],
                                        focusNode: _focusPhone,
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(color: Colors.black),
                                            contentPadding:
                                            const EdgeInsets.only(left: 25.0),
                                            focusColor: Colors.greenAccent,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(25),
                                              borderSide: const BorderSide(
                                                  color: Colors.deepOrange),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            //border: InputBorder.none,
                                            labelStyle: TextStyle(
                                                color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold // Change the color of the label text here
                                            ),
                                            fillColor: const Color(0xFF836FFF),
                                            filled: true,
                                            labelText: "Enter Phone No."),style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(height: 20.0),
                                      TextFormField(
                                        validator: (value) => Validator.validateEmail(
                                          email: value,
                                        ),
                                        controller: emailController,
                                        focusNode: _focusEmail,
                                        autofillHints: [AutofillHints.email],
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(color: Colors.black),
                                            contentPadding:
                                            const EdgeInsets.only(left: 25.0),
                                            focusColor: Colors.greenAccent,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(25),
                                              borderSide: const BorderSide(
                                                  color: Colors.deepOrange),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            //border: InputBorder.none,
                                            fillColor: const Color(0xFF836FFF),
                                            filled: true,
                                            labelStyle: TextStyle(
                                                color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold // Change the color of the label text here
                                            ),
                                            labelText: "Enter Email."),style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(height: 20.0),
                                      TextFormField(
                                        validator: (value) => Validator.validatePassword(
                                          password: value,
                                        ),
                                        controller: passwordController,
                                        focusNode: _focusPassword,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(color: Colors.black),
                                            contentPadding:
                                            const EdgeInsets.only(left: 25.0),
                                            focusColor: Colors.greenAccent,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(25),
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            //border: InputBorder.none,
                                            fillColor: const Color(0xFF836FFF),
                                            filled: true,
                                            labelStyle: TextStyle(
                                                color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold // Change the color of the label text here
                                            ),
                                            labelText: "Enter Password"),
                                        style: TextStyle(color: Colors.white),

                                      ),
                                      SizedBox(height: 20.0),
                                    ],
                                  ))

                          ),
                          // password
                        ],
                      ),
                      SizedBox(height: ResponsiveFile.height20 - 10),
                      InkWell(
                        onTap: () async {
                          _focusName.unfocus();
                          _focusPhone.unfocus();
                          _focusEmail.unfocus();
                          _focusPassword.unfocus();
                          setState(() {
                            _isProcessing = true;
                          });
                          if (_registerFormKey.currentState!.validate()) {
                            bool isSuccess = await authProvider.registerUsingEmailPassword(
                              name: nameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                              phoneNumber: phoneNumberController.text,
                              photoURL: photoUrl,
                            );
                            if (isSuccess) {
                              setState(() {
                                _isProcessing = false;
                              });
                              Get.offAll(Navbar());
                            } else  if (authProvider.lastAuthenticationError == 'email-already-in-use') {
                              Get.snackbar(
                                "Failed", // Snackbar title
                                "Email Already in use", // Snackbar message
                                duration: Duration(seconds: 3), // Duration for which snackbar will be visible (optional)
                                backgroundColor: Colors.grey, // Background color of the snackbar (optional)
                                snackPosition: SnackPosition.BOTTOM, // Position of the snackbar (optional)
                                borderRadius: 10, // Border radius of the snackbar (optional)
                                margin: EdgeInsets.all(10), // Margin around the snackbar (optional)
                                isDismissible: true, // Whether the snackbar can be dismissed by tapping outside (optional)

                                forwardAnimationCurve: Curves.easeOut, // Animation curve for showing the snackbar (optional)
                                reverseAnimationCurve: Curves.easeIn, // Animation curve for dismissing the snackbar (optional)
                              );
                              Get.offAll(SignInPage());
                              await authProvider.sendPasswordResetEmail(email: emailController.text);
                              const String uri = 'mailto:';
                              if (await canLaunch(uri)) { // Use canLaunch directly with the String URI
                                await launch(uri);
                              } else {
                                throw 'Could not launch $uri';
                              }
                            }


                          }
                          else{
                            _isProcessing = false;
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5 * 2,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(30)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    offset: Offset(2, 4),
                                    blurRadius: 5,
                                    spreadRadius: 2)
                              ],
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xff673AB7),
                                    Color(0xff512DA8)
                                  ])),
                          child: _isProcessing
                              ? SizedBox(
                            height: ResponsiveFile.height20,
                            width: ResponsiveFile.height20,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.orange[100],
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  Colors.deepOrangeAccent),
                            ),
                          )
                              : Text(
                            "Register",
                            style: TextStyle(
                                fontSize: ResponsiveFile.font19,
                                color: Colors.white),
                          ),
                        ),

                      ),



                    ],
                  ),
                ),
              ),
              if (authProvider.status == Status.authenticating)
                const Opacity(
                  opacity: 0.6,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                )
              else
                Container(),


            ],
          ),
        ),
      ),

    );
  }

}
