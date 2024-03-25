import 'package:flutter/material.dart';
import 'package:kanglei_taxi/conts/firebase/all_constants.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("KangleiTaxi"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        // You can apply other app bar properties similarly

      ),
      body: Container(
        child: Text("SignInPage"),
      ),
    );
  }
}
