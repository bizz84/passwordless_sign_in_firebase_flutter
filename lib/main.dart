import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:passwordless/firebase_email_link_handler.dart';
import 'package:passwordless/platform_alert_dialog.dart';

void main() {
  final linkHandler = FirebaseEmailLinkHandler();
  linkHandler.registerHandler();
  runApp(MyApp(linkHandler: linkHandler));
}

class MyApp extends StatelessWidget {
  MyApp({this.linkHandler});
  final FirebaseEmailLinkHandler linkHandler;

  // This widget is the root of your application.
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(linkHandler: linkHandler),
    );
  }
}

class LandingPage extends StatelessWidget {
  LandingPage({this.linkHandler});
  final FirebaseEmailLinkHandler linkHandler;

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

class SignInPage extends StatefulWidget {
  SignInPage({this.linkHandler});
  final FirebaseEmailLinkHandler linkHandler;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String _email;

  final _formKey = GlobalKey<FormState>();

  Future<void> _sendEmailLink() async {
    try {
      await widget.linkHandler.sendLinkToEmail(
        email: _email,
        url: 'https://passwordless-5346f.firebaseapp.com',
        iOSBundleID: 'com.codingwithflutter.passwordless',
        androidPackageName: 'com.codingwithflutter.passwordless',
      );
      PlatformAlertDialog(
        title: 'Check your email',
        content: 'We have sent an activation link to $_email',
        defaultActionText: 'OK',
      ).show(context);
    } catch (e) {
      // Show error
      PlatformAlertDialog(
        title: 'Error sending email',
        content: e.toString(), // TODO: Show a more user friendly error
        defaultActionText: 'OK',
      ).show(context);
    }
  }

  void _validateAndSubmit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _sendEmailLink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Email Address',
            ),
            validator: (email) => email.length > 0 ? null : 'Enter an email',
            onSaved: (email) => _email = email,
          ),
          RaisedButton(
            child: Text("Send email link"),
            onPressed: _validateAndSubmit,
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout', style: TextStyle(fontSize: 16.0, color: Colors.white)),
            onPressed: _signOut,
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Text(
            'Your uid:\n\n${user.uid}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}
