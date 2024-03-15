import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otp_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required void Function() onLogin}) : super(key: key);
  static String verify = "";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryCode = TextEditingController();
  var phone = "";
  final bool _isLoading = false;

  @override
  void initState() {
    countryCode.text = '+91';
    super.initState();
    //checkUserPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(250),
        child: AppBar(
          backgroundColor: const Color(0xffffded0),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/1.png',
                width: 200,
                height: 100,
              ),
              Text(
                'Welcome',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Text(
                '💖',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white38,
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.person, color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: nameController,

                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white38,
                ),
                child: Row(
                  children: [
                    SizedBox(
                        width: 40,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextField(
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            controller: countryCode,
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '|',
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {
                            phone = value;
                          });
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Allow only numbers
                          LengthLimitingTextInputFormatter(10), // Limit length to 10 characters
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Enter your number',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  // Check if the name is empty
                  if (nameController.text.isEmpty) {
                    // Show an error message or handle it as needed
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text("Please enter your name."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // If the name is not empty, proceed with phone verification
                    await APIs.auth.verifyPhoneNumber(
                      phoneNumber: '${countryCode.text + phone}',
                      verificationCompleted: (PhoneAuthCredential credential) async {
                        // Handle verification completed
                      },
                      verificationFailed: (FirebaseAuthException e) {
                        // Handle verification failed
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        LoginScreen.verify = verificationId;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OTP(
                              enteredName: nameController.text,
                              phoneNumber: countryCode.text + phone,
                            ),
                          ),
                        );
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {
                        // Handle code auto retrieval timeout
                      },
                      timeout: Duration(seconds: 60),
                    );
                  }
                },
                child: Container(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  width: 120,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User get user => auth.currentUser!;

  static Future<bool> userExists() async {
    return (await firestore.collection('pickup_requests').doc(user.uid).get()).exists;
  }

  static Future<void> createUser() async {
    //final time = DateTime.now().millisecondsSinceEpoch.toString();
  }
}