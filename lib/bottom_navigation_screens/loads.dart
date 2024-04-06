import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../truckbooking/my_form.dart';

class PlaceSuggestion {
  final String displayName;

  PlaceSuggestion({
    required this.displayName,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      displayName: json['display_name'] ?? '',
    );
  }
}

class Loads extends StatefulWidget {
  final String enteredName;
  final String phoneNumber;

  Loads({required this.enteredName, required this.phoneNumber});
  @override
  _LoadsState createState() => _LoadsState();
}

class _LoadsState extends State<Loads> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  late Timer timer;
  List<String> _imageUrls = [];

  late TextEditingController _fromController;
  late TextEditingController _toController;

  List<PlaceSuggestion> _fromSuggestions = [];
  List<PlaceSuggestion> _toSuggestions = [];


  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _pageController = PageController(initialPage: 0);
    _imageUrls = []; // Initialize the list
    _fetchImagesAndUpdate();

    _fromController = TextEditingController();
    _toController = TextEditingController();

  }

  @override
  void dispose() {
    timer.cancel();
    _pageController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
  void _fetchImagesAndUpdate() async {
    _imageUrls = await _getFirebaseImages();
    setState(() {});
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPageIndex < _imageUrls.length - 1) {
        _currentPageIndex++;
      } else {
        _currentPageIndex = 0;
      }
      _pageController.animateToPage(
        _currentPageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }
  Widget _buildSlideIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _imageUrls.length,
            (index) => Container(
          width: index == _currentPageIndex ? 14 : 10, // Adjust width for current indicator
          height: 5, // Set a fixed height for all indicators
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3), // Make it rectangular
            color: index == _currentPageIndex ? Colors.orangeAccent : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> fetchUserData() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();

      // Extract user data from the document
      setState(() {
        userName = userDoc['name'];
      });
    }
  }


  Future<List<PlaceSuggestion>> fetchFromSuggestions(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=$query&format=json&viewbox=68.1,6.5,97.4,35.5&bounded=1&countrycodes=in'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<PlaceSuggestion> suggestions =
        data.map((json) => PlaceSuggestion.fromJson(json)).toList();
        return suggestions;
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }
  Future<String?> _getImageUrlFromFirestore() async {
    try {
      // Fetch the image URL from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('Discount').get();

      // Assuming the field name storing the image URL is 'imageUrl'
      if (querySnapshot.docs.isNotEmpty) {
        String? ImageURL = querySnapshot.docs.first.data()['ImageURL'];
        return ImageURL;
      } else {
        print('No documents found in the collection.');
        return null;
      }
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  }
  Future<List<String>> _getFirebaseImages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Advertisement').get();
      List<String> imageUrls = [];
      querySnapshot.docs.forEach((doc) {
        // Assuming 'imageUrl' is the field name where image URLs are stored in Firestore
        String? ImageURL = doc['ImageURL'];
        if (ImageURL != null) {
          imageUrls.add(ImageURL);
        }
      });
      return imageUrls;
    } catch (e) {
      print("Error fetching image URLs: $e");
      return []; // Return an empty list in case of error
    }
  }

  void _swapTextFields() {
    String temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 18, top: 15),
              child: Text(
                "Hi $userName", // Display user name here
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  bottom: BorderSide(color: Colors.orange, width: 6),
                  top: BorderSide(color: Colors.orange),
                  right: BorderSide(color: Colors.orange),
                  left: BorderSide(color: Colors.orange),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(63, 0, 10, 5),
                        child: Text(
                          "From,",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 30, 5),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: Icon(Icons.circle_outlined,
                                  color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _fromController,
                                decoration: InputDecoration(
                                  hintText: 'Load from...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                onChanged: (value) async {
                                  List<PlaceSuggestion> suggestions =
                                  await fetchFromSuggestions(value);
                                  setState(() {
                                    _fromSuggestions = suggestions;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_fromSuggestions.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width, // Match the width of the text field
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _fromSuggestions
                                .map((suggestion) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _fromController.text =
                                      suggestion.displayName;
                                  _fromSuggestions.clear();
                                });
                              },
                              child: ListTile(
                                title: Text(suggestion.displayName),
                              ),
                            ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: CustomPaint(
                          size: Size(30, 20),
                          painter: DottedLinePainter(),
                        ),
                      ),
                      SizedBox(width: 9),
                      Text("To,"),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                          onPressed: _swapTextFields,
                          icon: Icon(Icons.swap_vert, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 30, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orangeAccent,
                          ),
                          child: Icon(Icons.location_on_outlined,
                              color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _toController,
                            decoration: InputDecoration(
                              hintText: 'Unload to...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onChanged: (value) async {
                              List<PlaceSuggestion> suggestions =
                              await fetchFromSuggestions(value);
                              setState(() {
                                _toSuggestions = suggestions;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_toSuggestions.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _toSuggestions
                            .map((suggestion) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _toController.text =
                                  suggestion.displayName;
                              _toSuggestions.clear();
                            });
                          },
                          child: ListTile(
                            title: Text(suggestion.displayName),
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(60, 10, 30, 10),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            // Update button position based on drag
                          });
                        },
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(5.0),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            fixedSize: MaterialStateProperty.all<Size>(
                              Size(double.maxFinite, 35),
                            ),
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return Colors.orangeAccent;
                                  }
                                  return Colors.grey.shade500;
                                }),
                          ),
                          onPressed: () {
                            // Check if both text fields are not empty
                            if (_fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
                              // Both fields are filled, navigate to the next screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyForm(
                                    enteredName: widget.enteredName,
                                    phoneNumber: widget.phoneNumber,
                                    fromLocation: _fromController.text,
                                    toLocation: _toController.text,
                                  ),
                                ),
                              );
                            } else {
                              String errorMessage = '';
                              if (_fromController.text.isEmpty) {
                                errorMessage += "Please fill 'From' field.\n";
                              }
                              if (_toController.text.isEmpty) {
                                errorMessage += "Please fill 'To' field.\n";
                              }

                              // Show error message indicating empty field(s)
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text(errorMessage),
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
                            }
                          },
                          child: Text(
                            "Confirm",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Center(
                child: FutureBuilder<String?>(
                  future: _getImageUrlFromFirestore(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final imageURL = snapshot.data;
                      if (imageURL != null) {
                        return Image.network(imageURL); // Display the fetched image
                      } else {
                        return Text('No image found');
                      }
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    child: _imageUrls.isEmpty
                        ? Container() // Show an empty container
                        : PageView.builder(
                      controller: _pageController,
                      itemCount: _imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Image.network(_imageUrls[index]),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildSlideIndicator(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Center(
                child: Image.asset('assets/delivery.png'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double startY = 0;
    double startX = size.width / 2;

    while (startY < size.height) {
      canvas.drawLine(
          Offset(startX, startY), Offset(startX, startY + 4), paint);
      startY += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
