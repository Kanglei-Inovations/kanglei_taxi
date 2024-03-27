import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanglei_taxi/providers/ChatProvider.dart';
import 'package:kanglei_taxi/providers/booking_provider.dart';
import 'package:kanglei_taxi/providers/location_provider.dart';
import 'package:kanglei_taxi/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'conts/firebase/all_constants.dart';
import 'conts/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/sim_provider.dart';
import 'views/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProviderlocal>(
              create: (_) => AuthProviderlocal(
                  firebaseFirestore: firebaseFirestore,
                  prefs: prefs,
                  // googleSignIn: GoogleSignIn(),
                  firebaseAuth: FirebaseAuth.instance)),
          Provider<ProfileProvider>(
              create: (_) => ProfileProvider(
                  prefs: prefs,
                  firebaseFirestore: firebaseFirestore,
                  firebaseStorage: firebaseStorage)),
          Provider<ChatProvider>(
              create: (_) => ChatProvider(
                  prefs: prefs,
                  firebaseStorage: firebaseStorage,
                  firebaseFirestore: firebaseFirestore)),

          Provider<HomeProvider>(
              create: (_) => HomeProvider(firebaseFirestore: firebaseFirestore)),
          Provider<SimProvider>(
            create: (_) => SimProvider(),
          ),
          Provider<LocationProvider>(
            create: (_) => LocationProvider(),
          ),
          Provider<BookingProvider>(
            create: (_) => BookingProvider(),
          ),
        ],
    child: GetMaterialApp(
      title: 'Flutter Demo',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    ),
    );
  }
}
