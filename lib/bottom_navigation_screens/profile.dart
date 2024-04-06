import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_page.dart';
import '../profile/aboutpage.dart';
import '../profile/help.dart';
import '../profile/history.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _showAnimation = false;
  String userName = '';
  String phoneNumber = '';


  @override
  void initState() {
    super.initState();

    fetchUserData();
    Future.delayed(Duration(milliseconds: 15), () {
      setState(() {
        _showAnimation = true;
      });
    });
  }

  Future<void> fetchUserData() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();

      // Extract user data from the document
      setState(() {
        userName = userDoc['name'];
        phoneNumber = userDoc['phoneNumber'];
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20), // Adjust the padding values as needed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the contents vertically
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the avatar horizontally
                  children: [
                    Container(
                      width: 120, // Adjust the width of the container
                      height: 120, // Adjust the height of the container
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orangeAccent,
                        image: DecorationImage(
                          image: AssetImage('assets/prof3.jpg'), // Replace 'images/prof1.jpg' with the actual asset path of the profile photo
                          // fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10), // Add spacing between the avatar and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center the text horizontally
                  children: [
                    Center( // Center the name horizontally
                      child: Text(
                        ' $userName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center( // Center the phone number horizontally
                      child: Text(
                        ' $phoneNumber',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [

                buildListItem(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  color: Colors.orangeAccent,
                  onTap: () {
                  },
                ),
                SizedBox(height: 20),
                buildListItem(
                  icon: Icons.history_edu_outlined,
                  title: 'History',
                  color: Colors.orangeAccent,
                  onTap: () {
                    _navigateToPage(HistoryScreen()); // Pass customer number
                  },
                ),
                SizedBox(height: 20),
                buildListItem(
                  icon: Icons.help_outline,
                  title: 'Help',
                  color: Colors.orangeAccent,
                  onTap: () {
                    _navigateToPage(HelpPage());
                  },
                ),
                SizedBox(height: 20),
                buildListItem(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  color: Colors.orangeAccent,
                  onTap: () {
                    _navigateToPage(AboutUs());
                  },
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 50,left: 50,bottom: 50),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(5.0),
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.orangeAccent;
                            }
                            return Colors.grey.shade500;
                          },
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero, // No border radius
                              ),
                              backgroundColor: Colors.white, // Set background color
                              child: SizedBox(
                                width: 250, // Set width
                                height: 150, // Set height
                                child: Column(
                                  //mainAxisAlignment: MainAxisAlignment.,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10,right: 40),
                                      child: Text(
                                        "Confirm Logging Out",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10,left: 20,right: 20),
                                      child: Text(
                                        "Booking load is faster when you are logged in. Are you sure you want to logout?",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                            await prefs.remove('isLoggedIn');
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LoginScreen(onLogin: () {},),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 120,top: 30),
                                            child: Text(
                                              "Yes",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 30,),
                                            child: Text(
                                              "No",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 800),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: page,
          );
        },
      ),
    );
  }

  Widget buildListItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      height: _showAnimation ? 50 : 0,
      child: ClipPath(
        clipper: ShapeClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.orange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            onTap: onTap,
            contentPadding: EdgeInsets.only(left: 10),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width - 20, 0.0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 20, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}