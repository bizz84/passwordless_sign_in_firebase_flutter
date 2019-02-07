import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwordless/firebase_email_link_handler.dart';
import 'package:passwordless/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(MyApp(sharedPreferences: await SharedPreferences.getInstance()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.sharedPreferences}) : super(key: key);
  final SharedPreferences sharedPreferences;

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(
        linkHandler: FirebaseEmailLinkHandler(
          sharedPreferences: sharedPreferences,
        ),
      ),
    );
  }
}
