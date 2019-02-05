
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:passwordless/firebase_email_link_handler.dart';
import 'package:passwordless/home_page.dart';
import 'package:passwordless/sign_in_page.dart';

class LandingPage extends StatelessWidget {
  final linkHandler = FirebaseEmailLinkHandler();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return HomePage(user: snapshot.data);
          } else {
            return SignInPage(linkHandler: linkHandler);
          }
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
