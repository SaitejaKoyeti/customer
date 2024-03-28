import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bottom_navigation_screens/myhome.dart';
import 'login_page.dart';

class OTP extends StatefulWidget {
  final String enteredName;
  final String phoneNumber;

  const OTP({Key? key, required this.enteredName, required this.phoneNumber}) : super(key: key);

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  String errorMessage = '';
  late FocusNode _otpFocusNode;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Timer _timer;
  int _start = 60;

  @override
  void initState() {
    super.initState();
    _otpFocusNode = FocusNode();
    _otpFocusNode.requestFocus();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.repeat(reverse: true);

    // Start the timer
    startTimer();
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    _otpController.dispose();
    _animationController.dispose();
    // Dispose of the timer
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          // If timer reaches zero, cancel the timer
          timer.cancel();
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250),
        child: AppBar(
          backgroundColor: Color(0xffffded0),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'assets/1.png',
                  width: 200,
                  height: 100,
                ),
              ),
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white, Colors.white]),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  'Verify your Phone Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(
                  height: 30,
                ),
                Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  showCursor: true,
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  onChanged: (value) {
                    // Check if entered OTP is correct
                    if (value.length == 6) {
                      _verifyOTP(value,
                          widget.phoneNumber); // Pass phoneNumber parameter
                    } else {
                      // Clear the error message if OTP is not 6 digits
                      setState(() {
                        errorMessage = '';
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 18,
                ),
                // Display error message or timer
                Text(
                  errorMessage.isNotEmpty
                      ? errorMessage
                      : '$_start seconds remaining',
                  style: TextStyle(color: Colors.red),
                ),
                // Button to resend OTP
                ElevatedButton(
                  onPressed: _start == 0 ? _resendOTP : null,
                  child: Text('Resend OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOTP(String enteredOTP, String phoneNumber) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: LoginScreen.verify,
        smsCode: enteredOTP,
      );

      // Sign in with the provided credential
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the current user's ID
      String userId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('user').doc(userId).set({
        'name': widget.enteredName,
        'phoneNumber': phoneNumber, // Include country code with phone number
        // Add more fields as needed
      });

      // Save collection with entered name

      // Set the logged-in state
      await _setLoggedIn(true);

      // Check if the timer has expired
      if (_start == 0) {
        setState(() {
          errorMessage = 'Your OTP has expired. Please click "Resend OTP" to try again.';
        });
      } else {
        // Navigate to the next screen on successful verification
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(enteredName: '', phoneNumber: '',),
          ),
        );
      }
    } catch (e) {
      // Handle verification errors
      print("Error verifying OTP: $e");

      setState(() {
        if (e is FirebaseAuthException) {
          // Map error codes to custom messages
          const errorMessages = {
            'invalid-verification-code': 'Incorrect OTP. Please try again.',
            'invalid-verification-id': 'Invalid verification ID. Please restart the process.',
            // Add more error codes and messages as needed
          };

          // Use custom message if available, otherwise use a generic message
          errorMessage = errorMessages[e.code] ?? 'An unexpected error occurred. Please try again.';
        } else {
          errorMessage = 'An unexpected error occurred. Please try again.';
        }
      });
    }
  }


  Future<void> _setLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // Function to handle resend OTP
// Function to handle resend OTP
  void _resendOTP() async {
    _otpController.clear();
    // Reset the timer
    setState(() {
      _start = 60;
    });
    // Start the timer again
    startTimer();

    try {
      await APIs.auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Handle verification completed
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle verification failed
        },
        codeSent: (String verificationId, int? resendToken) {
          LoginScreen.verify = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle code auto retrieval timeout
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      print('Error resending OTP: $e');
      // Handle error
    }
  }
}