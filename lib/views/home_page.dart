import 'package:flutter/material.dart';
import 'package:kanglei_taxi/conts/firebase/all_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: AppColors.secondary,
    );
  }
}
