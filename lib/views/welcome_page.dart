import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanglei_taxi/conts/firebase/all_constants.dart';
import 'package:kanglei_taxi/conts/resposive_settings.dart';
import 'package:kanglei_taxi/nav_bar.dart';
import 'package:kanglei_taxi/views/signin_page.dart';
import 'package:kanglei_taxi/views/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _showWelcomePage = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeOpening();
  }

  Future<void> _checkFirstTimeOpening() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;

    if (isFirstTime) {
      setState(() {
        _showWelcomePage = true;
      });

      // Mark app as opened for the first time
      await prefs.setBool('first_time', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    return _showWelcomePage ? _buildWelcomePage() :
    isLoggedIn?Navbar():SignInPage();
  }

  Widget _buildWelcomePage() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: AppColors.secondary,
                height: ResponsiveFile.screenHeight / 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'At the KangleiTaxi',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                height: ResponsiveFile.screenHeight / 3,
                child: Center(
                  child: Image.asset(
                    'images/taxianimation.gif', // Change to your image path
                    width: ResponsiveFile.screenWidth,
                    height: ResponsiveFile.screenHeight / 3,
                  ),
                ),
              ),
              Container(
                color: AppColors.primary,
                height: ResponsiveFile.screenHeight / 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'We are here to make your trip memorable.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Get.off(SignupPage());
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
