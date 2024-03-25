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
    return _showWelcomePage ? _buildWelcomePage() : _buildWelcomePage()
        // isLoggedIn?Navbar():SignInPage()
        ;
  }

  Widget _buildWelcomePage() {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image(
                              image: AssetImage("images/taxi_booking_welcome.jpg"),
                            ),
                            Column(
                              children: [
                Text(
                  'Welcome to KangleiTaxi!',
                  style: Theme.of(context).textTheme.headline1
                ),
                Text(
                  'Are you ready to explore Manipur like never before?',
                    style: Theme.of(context).textTheme.subtitle1
                ),
                Text(
                  'Say goodbye to waiting for taxis and hello to convenient and reliable transportation with KangleiTaxi.',
                  style: Theme.of(context).textTheme.subtitle1
                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                OutlinedButton(onPressed: () {}, child: Text("Log In")),
                SizedBox(width: 10,),
                OutlinedButton(onPressed: () {}, child: Text("Sign Up"))
                              ],
                            )
                          ],
                ),
              ),
            ));
  }
}
