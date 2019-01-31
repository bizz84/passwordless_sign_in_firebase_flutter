

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseEmailLinkHandler {

  String email;

  StreamSubscription _subscription;

  void registerHandler() {

    const channel = EventChannel('linkHandler');
    _subscription = channel.receiveBroadcastStream().listen((dynamic event) async {
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

  void dispose() {
    _subscription?.cancel();
  }

}