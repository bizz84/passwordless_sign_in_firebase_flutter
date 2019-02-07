import 'dart:async';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseEmailLinkHandler {
  final SharedPreferences sharedPreferences;
  final EventChannel channel;

  static const userEmailAddressKey = "userEmailAddress";

  StreamSubscription _subscription;

  String get email => sharedPreferences.getString(userEmailAddressKey);

  Stream<String> get channelStream => channel.receiveBroadcastStream().map((event) => event as String);

  StreamController<String> _errorController = StreamController<String>();
  Stream<String> get errorStream => _errorController.stream;

  FirebaseEmailLinkHandler({@required this.channel, @required this.sharedPreferences}) {
    _subscription = channelStream.listen((String event) async {
      final email = sharedPreferences.getString(userEmailAddressKey);

      if (email == null) {
        print("email is not set. Skipping sign in...");
        return;
      }
      print('Received event: $event');
      String link = event;
      if (await FirebaseAuth.instance.isSignInWithEmailLink(link: link)) {
        try {
          final user = await FirebaseAuth.instance.signInWithEmailAndLink(email: email, link: link);
          print('email: ${user.email}, uid: ${user.uid}');
        } catch (e) {
          print(e);
          _errorController.add(e.toString());
        }
      }
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
      _errorController.add(error.toString());
    });
  }

  Future<void> sendLinkToEmail({String email, String url, String iOSBundleID, String androidPackageName}) async {
    // TODO: Store email securely (e.g. keychain) rather than on shared preferences
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
    _errorController.close();
  }
}
