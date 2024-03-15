import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'confirmbooking.dart';
import 'truck.dart';

class ConfirmationPage extends StatelessWidget {
  final String selectedGoodsType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Truck selectedTruck;
  final String selectedImageName;
  final String fromLocation;
  final String toLocation;

  final Color outlinedBoxColor = Colors.orange;
  final Color containerOutlineColor = Colors.white;

  ConfirmationPage({
    required this.selectedGoodsType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedTruck,
    required this.selectedImageName,
    required this.fromLocation,
    required this.toLocation,
  });
  void _confirmPickup(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        String name = userData.get('name');
        String phoneNumber = userData.get('phoneNumber');

        // Construct the data to be stored in Firebase
        Map<String, dynamic> pickupData = {
          'selectedGoodsType': selectedGoodsType,
          'selectedDate': selectedDate,
          'selectedTime': selectedTime.toString(),
          'selectedTruck': {
            'name': selectedTruck?.name ?? '',
            'price': selectedTruck?.price ?? 0,
            'weightCapacity': selectedTruck?.weightCapacity ?? 0,
          },
          'customerName': name,
          'customerphoneNumber': phoneNumber,
          'fromLocation': fromLocation ?? '',
          'toLocation': toLocation ?? '',
          // Add any other relevant data fields here
        };

        // Store the data in Firebase Firestore
        await FirebaseFirestore.instance
            .collection('pickup_requests')
            .add(pickupData);
        print('Data stored in Firebase successfully');

        // Navigate to the confirmation screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => confirm()),
        );
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Error storing data in Firebase: $e');
      // Handle the error as needed
      // Optionally, show a snackbar or dialog to inform the user of the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('back'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Details',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Divider(color: outlinedBoxColor),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: containerOutlineColor),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.transparent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Image.asset(
                            selectedImageName,
                            width: 120.0,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      Container(
                        height: 80.0,
                        width: 1.0,
                        color: outlinedBoxColor,
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${selectedTruck.name}',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '${selectedTruck.weightCapacity} Tons',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '\$${selectedTruck.price}',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(color: outlinedBoxColor),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: outlinedBoxColor),
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.orange[300],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.black,
                                      size: 20.0,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      '${selectedDate.day}/${selectedDate
                                          .month}/${selectedDate.year}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: outlinedBoxColor),
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.orange[300],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.black,
                                      size: 20.0,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      selectedTime.format(context),
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: outlinedBoxColor),
                  SizedBox(height: 8.0),
                  Text(
                    'From Location:',
                    style:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  buildBoxTextFieldWithIcon(fromLocation, Icons.location_on),
                  SizedBox(height: 16.0),
                  Text(
                    'To Location:',
                    style:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  buildBoxTextFieldWithIcon(toLocation, Icons.location_on),
                  Divider(color: outlinedBoxColor),
                  SizedBox(height: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _confirmPickup(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.black,
          ),
          child: Text(
            'Confirm Pickup',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget buildBoxTextFieldWithIcon(String labelText, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: outlinedBoxColor),
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.orange[300],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              iconData,
              color: Colors.black,
              size: 20.0,
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  labelText,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
