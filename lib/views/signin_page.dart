import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanglei_taxi/conts/bezierContainer.dart';
import 'package:kanglei_taxi/conts/resposive_settings.dart';
import 'package:kanglei_taxi/conts/text_class.dart';
import 'package:kanglei_taxi/nav_bar.dart';
import 'package:kanglei_taxi/services/validation.dart';
import 'package:kanglei_taxi/views/signup_page.dart';
import 'package:kanglei_taxi/widget/ki_info_bar.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderlocal>(context);
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -MediaQuery.of(context).size.height * .15,
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
                      Image.asset(
                        "images/logo3D.png",
                        fit: BoxFit.fill,
                        width: ResponsiveFile.screenHeight / 6,
                        height: ResponsiveFile.screenHeight / 6,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: TextStyle(
                                fontSize: ResponsiveFile.height30,
                                fontWeight: FontWeight.w700,
                                color: Color(0xffe46b10)),
                            children: [
                              TextSpan(
                                text: 'KANGLEI',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ResponsiveFile.height30),
                              ),
                              TextSpan(
                                text: ' TAXI',
                                style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontSize: ResponsiveFile.height30),
                              ),
                              TextSpan(
                                text: '',
                                style: TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: ResponsiveFile.height30),
                              ),
                              // TextSpan(
                              //   text: 'box.read('email')' ,
                              //   style: TextStyle(
                              //       color: Color(0xffe46b10), fontSize: 30),
                              // ),
                            ]),
                      ),
                      SizedBox(height: ResponsiveFile.height30),
                      Column(
                        children: <Widget>[
                          // Container(
                          //   //show error message here
                          //   margin: EdgeInsets.only(top: 20),
                          //   padding: EdgeInsets.all(10),
                          //   child: error ? errmsg(errormsg) : Container(),
                          //   //if error == true then show error message
                          //   //else set empty container as child
                          // ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveFile.font19,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: ResponsiveFile.height10),
                                  //Password

                                  TextFormField(
                                      controller: _emailTextController,
                                      focusNode: _focusEmail,
                                      autofillHints: [AutofillHints.email],
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) =>
                                          Validator.validateEmail(
                                            email: value,
                                          ),
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                              left:
                                                  ResponsiveFile.height20 + 10),
                                          //focusColor: Colors.greenAccent,
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                ResponsiveFile.height20 + 5),
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
                                          filled: true)),
                                  SizedBox(height: ResponsiveFile.height20),
                                  Text(
                                    "Password",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveFile.font19,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: ResponsiveFile.height10),
                                  TextFormField(
                                      controller: _passwordTextController,
                                      focusNode: _focusPassword,
                                      autofillHints: [AutofillHints.password],
                                      keyboardType: TextInputType.text,
                                      obscureText: true,
                                      validator: (value) =>
                                          Validator.validatePassword(
                                            password: value,
                                          ),
                                      decoration: InputDecoration(
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
                                          filled: true)),
                                ],
                              ),
                            ),
                          ),
                          // password
                        ],
                      ),
                      SizedBox(height: ResponsiveFile.height20 - 10),
                      InkWell(
                          onTap: () async {

                             await authProvider.sendPasswordResetEmail(email: _emailTextController.text);


                          },
                          child: Container(
                              width: ResponsiveFile.screenWidth,
                              child: const AppText(
                                text: "Forget Password?",
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                textAlign: TextAlign.right,
                                fontWeight: FontWeight.bold,
                              ))),
                      SizedBox(height: ResponsiveFile.height20),
                      InkWell(
                        onTap: () async {
                          _focusEmail.unfocus();
                          _focusPassword.unfocus();

                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isProcessing = true;
                            });

                            bool isSuccess =
                                await authProvider.signInUsingEmailPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text,
                            );

                            setState(() {
                              _isProcessing = false;
                            });
                            if (isSuccess) {
                              Get.offAll(Navbar());
                            }
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
                                    offset: _isProcessing
                                        ? Offset(2, 6)
                                        : Offset(2, 2),
                                    blurRadius: 5,
                                    spreadRadius: 1)
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
                                  "Login",
                                  style: TextStyle(
                                      fontSize: ResponsiveFile.font19,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: const <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Divider(
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Text('or'),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Divider(
                                  thickness: 1,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          bool isSuccess =
                              await authProvider.registerUsinggoogle();

                          if (isSuccess) {
                            Get.offAll(Navbar());
                          }
                        },
                        child: Container(
                          height: 40,
                          margin:
                              EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        topLeft: Radius.circular(5)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                      "images/Google__G__logo.svg.png"),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF836FFF),
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(5),
                                        topRight: Radius.circular(5)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('Log in with Google',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(SignupPage());
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(15),
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Don\'t have an account ?',
                                style: TextStyle(
                                    fontSize: ResponsiveFile.font16,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Register',
                                style: TextStyle(
                                    color: Color(0xfff79c4f),
                                    fontSize: ResponsiveFile.font16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
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
