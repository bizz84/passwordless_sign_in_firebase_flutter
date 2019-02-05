

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseEmailLinkHandler {

  static const userEmailAddressKey = "userEmailAddress";

  StreamSubscription _subscription;

  void registerHandler() {

    const channel = EventChannel('linkHandler');
    _subscription = channel.receiveBroadcastStream().listen((dynamic event) async {

      final sharedPreferences = await SharedPreferences.getInstance();
      final email = sharedPreferences.getString(userEmailAddressKey);

      if (email == null) {
        print("email is not set. Skipping sign in...");
        return;
      }
      if (event is String) {
        print('Received event: $event');
        String link = event;
        if (await FirebaseAuth.instance.isSignInWithEmailLink(link: link)) {
          try {
            final user = await FirebaseAuth.instance.signInWithEmailAndLink(email: email, link: link);
            print('email: ${user.email}, uid: ${user.uid}');
          } catch (e) {
            print(e);
          }
        }
      } else {
        print('Unrecognized event: $event');
      }
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
    });
  }

  Future<void> sendLinkToEmail({String email, String url, String iOSBundleID, String androidPackageName}) async {
    // TODO: Store email securely (e.g. keychain) rather than on shared preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(userEmailAddressKey, email);

    // Send link
    await FirebaseAuth.instance.sendLinkToEmail(
      email: email,
      url: url,
      handleCodeInApp: true,
      iOSBundleID: iOSBundleID,
      androidPackageName: androidPackageName,
      androidInstallIfNotAvailable: false,
      androidMinimumVersion: '14',
    );
    print("Sent email link to $email, url: $url");
  }

  void dispose() {
    _subscription?.cancel();
  }
}