
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:passwordless/firebase_email_link_handler.dart';
import 'package:passwordless/home_page.dart';
import 'package:passwordless/platform_alert_dialog.dart';
import 'package:passwordless/sign_in_page.dart';

class LandingPage extends StatefulWidget {
  final FirebaseEmailLinkHandler linkHandler;
  LandingPage({Key key, this.linkHandler}) : super(key: key);

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.linkHandler.errorStream.listen((error) {
      PlatformAlertDialog(
        title: "Email activation error",
        content: error,
        defaultActionText: "Dismiss",
      ).show(context);
    });
  }

  @override
  void dispose() {
    widget.linkHandler.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return HomePage(user: snapshot.data);
          } else {
            return SignInPage(linkHandler: widget.linkHandler);
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
