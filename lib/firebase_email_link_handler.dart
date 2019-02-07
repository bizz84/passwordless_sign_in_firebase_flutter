import 'dart:async';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseEmailLinkHandler {
  final SharedPreferences sharedPreferences;

  static const _channel = EventChannel('linkHandler');
  static const _userEmailAddressKey = "userEmailAddress";

  StreamSubscription _channelStreamSubscription;

  String get email => sharedPreferences.getString(_userEmailAddressKey);

  Stream<String> get _channelStream => _channel.receiveBroadcastStream().map((event) => event as String);

  StreamController<String> _errorController = StreamController<String>();
  Stream<String> get errorStream => _errorController.stream;

  FirebaseEmailLinkHandler({@required this.sharedPreferences}) {
    _channelStreamSubscription = _channelStream.listen((String link) async {
      final email = sharedPreferences.getString(_userEmailAddressKey);

      if (email == null) {
        print("email is not set. Skipping sign in...");
        _errorController.add("Email not configured");
        return;
      }
      print('Received link: $link');
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
    sharedPreferences.setString(_userEmailAddressKey, email);

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
    _channelStreamSubscription?.cancel();
    _errorController.close();
  }
}
