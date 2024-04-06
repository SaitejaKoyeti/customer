import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'help.dart';
import 'notifications.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  User? customer;
  String currentUser = '';
  late Map<int, bool> isExpandedMap;

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
    isExpandedMap = {};
  }

  Future<void> fetchCustomerData() async {
    // Get the current user
    User? customer = FirebaseAuth.instance.currentUser;

    if (customer != null) {
      setState(() {
        this.customer = customer;
      });
      // Fetch data for DriversAcceptedOrders collection
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('DriversAcceptedOrders')
          .where('customerphoneNumber', isEqualTo: customer.phoneNumber)
          .get();
      if (ordersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot orderDoc = ordersSnapshot.docs.first;

        Map<String, dynamic>? orderData =
        orderDoc.data() as Map<String, dynamic>?;

        if (orderData != null) {
          print('Order data: $orderData');
        } else {
          print('Order data is null.');
        }
      } else {
        print('No order document found for the current user.');
      }

      // Fetch data for pickup_requests collection
      QuerySnapshot pickupSnapshot = await FirebaseFirestore.instance
          .collection('pickup_requests')
          .where('customerphoneNumber', isEqualTo: customer.phoneNumber)
          .get();
      if (pickupSnapshot.docs.isNotEmpty) {
        DocumentSnapshot pickupDoc = pickupSnapshot.docs.first;

        Map<String, dynamic>? pickupData =
        pickupDoc.data() as Map<String, dynamic>?;

        if (pickupData != null) {
          print('Pickup data: $pickupData');
        } else {
          print('Pickup data is null.');
        }
      } else {
        print('No pickup document found for the current user.');
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Delivered':
        return Colors.blue;
      case 'Orders to be delivered':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            width: double.infinity,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                  child: Container(
                    child: Image.asset(
                      'assets/transmaa_logo.png',
                      fit: BoxFit.cover,
                      height: 45,
                      width: 161,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Tooltip(
                          message: 'Notifications',
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Tooltip(
                          message: 'Help',
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            Icons.help_outline_outlined,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HelpPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 10, bottom: 5),
            child: Row(
              children: [
                Text(
                  "History..",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('pickup_requests')
                          .where('customerphoneNumber',
                          isEqualTo: FirebaseAuth.instance.currentUser!.phoneNumber)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.hasData) {
                          List<DocumentSnapshot> docs = snapshot.data!.docs;
                          return Column(
                            children: docs.map((doc) {
                              String docId = doc.id; // Get the document ID
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 7.0),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 3000),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'From Location:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'From Location:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '${doc['fromLocation'] ?? 'Not provided'}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'To Location:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '${doc['toLocation'] ?? 'Not provided'}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(height: 10),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Date:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '${doc['selectedDate'] is String ? _formatStringToTimestamp(doc['selectedDate']) : _formatTimestamp(doc['selectedDate'])}',
                                                style: TextStyle(fontSize: 14),
                                              ),

                                              SizedBox(height: 10),
                                              Text(
                                                'Time:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '${doc['selectedTime'] ?? 'Not provided'}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Goods Type:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '${doc['selectedGoodsType'] ?? 'Not provided'}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Truck:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '${doc['selectedTruck'] ?? 'Not provided'}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Divider(),
                                              Text(
                                                'Status:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.orangeAccent, // Choose your desired color here
                                                  borderRadius: BorderRadius.circular(8), // Adjust the border radius as needed
                                                ),
                                                child: Text(
                                                  'Waiting for Transmaa confirmation',
                                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ));
                            }).toList(),
                          );
                        }

                        return Text('No historical data available');
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('DriversAcceptedOrders')
                          .where('customerPhoneNumber',
                          isEqualTo: FirebaseAuth.instance.currentUser!
                              .phoneNumber)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.hasData) {
                          List<DocumentSnapshot> docs = snapshot.data!.docs;
                          return Column(
                            children: docs.asMap().entries.map((entry) {
                              int index = entry.key;
                              DocumentSnapshot doc = entry.value;
                              bool isExpanded = isExpandedMap[index] ?? false;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 7.0),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 3000),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(15),
                                  //height: isExpanded ? 510 : 260, // Adjust the height as needed
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'From Location:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${doc['fromLocation'] ?? 'Not provided'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'To Location:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${doc['toLocation'] ?? 'Not provided'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 10),
                                      if (isExpanded)
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '${doc['selectedDate'] is String ? _formatStringToTimestamp(doc['selectedDate']) : _formatTimestamp(doc['selectedDate'])}',
                                              style: TextStyle(fontSize: 14),
                                            ),

                                            SizedBox(height: 10),
                                            Text(
                                              'Time:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '${doc['selectedTime'] ?? 'Not provided'}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Goods Type:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '${doc['selectedGoodsType'] ?? 'Not provided'}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Truck:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '${doc['selectedTruck'] ?? 'Not provided'}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Divider(),
                                      Text(
                                        'Status:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                  doc['status'] ??
                                                      'Not provided'),
                                              borderRadius:
                                              BorderRadius.circular(5),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${doc['status'] ?? 'Not provided'}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                isExpandedMap[index] =
                                                !(isExpandedMap[index] ??
                                                    false);
                                              });
                                            },
                                            child: Text(
                                              isExpandedMap[index] ?? false
                                                  ? "Hide Details"
                                                  : "View Details",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.blue,
                                                decoration:
                                                TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }

                        return Text('No historical data available');
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Timestamp _formatStringToTimestamp(String selectedDate) {
    // Parse the string and create a DateTime object
    DateTime dateTime = DateTime.parse(selectedDate);
    // Convert DateTime to Timestamp
    return Timestamp.fromDate(dateTime);
  }
}

String _formatTimestamp(Timestamp? timestamp) {
  if (timestamp != null) {
    // Convert the Timestamp to a DateTime object
    DateTime dateTime = timestamp.toDate();
    // Format the DateTime object as a string
    return DateFormat('yyyy-MM-dd').format(dateTime);
  } else {
    return 'Not provided';
  }
}