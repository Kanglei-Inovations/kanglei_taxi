import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
  super.initState();
  _animationController = AnimationController(
  vsync: this,
  duration: Duration(seconds: 2),
  );
  _animation = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(
  parent: _animationController,
  curve: Curves.easeInOut,
  ),
  );
  _animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  backgroundColor: Colors.white,
  body: Center(
  child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
  FadeTransition(
  opacity: _animation,
  child: Image.asset(
  'assets/taxianimation.gif',
  width: 200,
  height: 200,
  ),
  ),
  SizedBox(height: 20),
  Text(
  'Welcome to KangleiTaxi',
  style: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.blue,
  ),
  ),
  SizedBox(height: 10),
  Text(
  'Your go-to solution for booking taxis in Manipur!',
  style: TextStyle(
  fontSize: 16,
  color: Colors.black54,
  ),
  textAlign: TextAlign.center,
  ),
  ],
  ),
  ),
  );
  }

  @override
  void dispose() {
  _animationController.dispose();
  super.dispose();
  }
  }