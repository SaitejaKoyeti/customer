import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_navigation_screens/myhome.dart';
import 'firebase_options.dart';
import 'login/login_page.dart';
// Import your main screen file here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {});
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthenticationWrapper(enteredName: '', phoneNumber: '',),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {

  final String enteredName;
  final String phoneNumber;
  AuthenticationWrapper({required this.enteredName,
    required this.phoneNumber});
  @override

  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Check authentication state when the app starts
    checkAuthenticationStatus();
  }

  Future<void> checkAuthenticationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void setAuthenticationStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? MyHomePage(enteredName: widget.enteredName, phoneNumber:widget.phoneNumber,) : LoginScreen(onLogin: () => setAuthenticationStatus(true));
  }
}