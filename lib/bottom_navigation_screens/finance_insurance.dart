import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceAndInsurance extends StatefulWidget {
  final String documentId;

  FinanceAndInsurance({required this.documentId});

  @override
  _FinanceAndInsuranceState createState() => _FinanceAndInsuranceState();
}

class _FinanceAndInsuranceState extends State<FinanceAndInsurance> {
  String selectedButton = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController rcNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> submitData() async {
    if (nameController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        vehicleTypeController.text.isNotEmpty &&
        rcNumberController.text.isNotEmpty) {
      try {
        String collectionName =
        selectedButton == 'finance' ? 'Finance' : 'Insurance';

        await FirebaseFirestore.instance.collection(collectionName).add({
          'name': nameController.text,
          'phoneNumber': phoneNumberController.text,
          'vehicleType': vehicleTypeController.text,
          'rcNumber': rcNumberController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data submitted successfully!'),
          ),
        );

        nameController.clear();
        phoneNumberController.clear();
        vehicleTypeController.clear();
        rcNumberController.clear();
      } catch (error) {
        print('Error submitting data to Firestore: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit data. Please try again later.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [

                  Text(
                    'Commercial Vehicles',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = 'finance';
                      });
                    },
                    child: Text('Finance',style: TextStyle(color: Colors.white,fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedButton == 'finance' ? Colors.green : Colors.orangeAccent,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 180,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = 'insurance';
                      });
                    },
                    child: Text('Insurance',style: TextStyle(color: Colors.white,fontSize: 18),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedButton == 'insurance'
                          ? Colors.green
                          : Colors.orangeAccent,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTextField('Name', nameController),
                  SizedBox(height: 7),
                  buildTextField('Phone Number', phoneNumberController),
                  SizedBox(height: 7),
                  buildTextField('Type of Vehicle', vehicleTypeController),
                  SizedBox(height: 7),
                  buildTextField('RC Number', rcNumberController),
                  SizedBox(height: 25),
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: submitData,
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.cyan[300],
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
