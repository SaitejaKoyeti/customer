import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'confirmation_page.dart';
import 'truck.dart';

class MyForm extends StatefulWidget {
  final String fromLocation;
  final String toLocation;
  final String enteredName;
  final String phoneNumber;


  const MyForm({
    Key? key,
    required this.fromLocation,
    required this.toLocation,
    required this.enteredName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  String? selectedGoodsType;
  DateTime? selectedDate = DateTime.now();
  TimeOfDay? selectedTime = TimeOfDay.now();
  Truck? selectedTruck;
  String? selectedLoad;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  List<String> goodsList = [
    'Timber/Plywood/Laminate',
    'Electrical/Electronics/Home Appliances',
    'General',
    'Building/Construction',
    'Catering/Restaurant/Event Management',
    'Machines/Equipments/Spare Parts/Metals',
    'Textile/Garments/Fashion Accessories',
    'Furniture/Home Furnishing',
    'House Shifting',
    'Ceramics/Sanitary/Hardware',
    'Paper/Packaging/Printed Material',
  ];

  List<Truck> trucks = [
    Truck(imagePath: 'assets/truck2-removebg-preview.png', name: 'Tipper', price: 500.0, weightCapacity: 4 - 30),
    Truck(imagePath: 'assets/truck22 remove.png', name: ' Container', price: 600.0, weightCapacity: 4 - 30),
    Truck(imagePath: 'assets/truck_3-removebg-preview.png', name: 'Open', price: 700.0, weightCapacity: 4 - 30),
    Truck(imagePath: 'assets/truck_4-removebg-preview.png', name: 'Double Container', price: 800.0, weightCapacity: 1800.0),
    Truck(imagePath: 'assets/truck_5-removebg-preview.png', name: 'Tanker', price: 900.0, weightCapacity: 2000.0),
  ];

  @override
  void initState() {
    super.initState();
    selectedGoodsType = goodsList.first;
    _updateDateAndTimeControllers();
  }

  void _updateDateAndTimeControllers() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _dateController.text = DateFormat('d/M/yyyy').format(selectedDate!);
      _timeController.text = selectedTime!.format(context);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _updateDateAndTimeControllers();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        _updateDateAndTimeControllers();
      });
    }
  }

  void _showPopup(BuildContext context, int index) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final double screenHeight = overlay.size.height;
    final double popupHeight = 240.0; // Adjust the height of the popup as needed

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 180, // Right edge of the screen
        (screenHeight - popupHeight) / 2, // Center vertically
        overlay.size.width, // Right edge of the screen
        (screenHeight + popupHeight) / 2, // Center vertically
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              SizedBox(width: 8),
              Text('4-7 Tons'),
            ],
          ),
          value: '4-7 Tons',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SizedBox(width: 8),
              Text('8-10 Tons'),
            ],
          ),
          value: '8-10 Tons',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SizedBox(width: 8),
              Text('11-14 Tons'),
            ],
          ),
          value: '11-14 Tons',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SizedBox(width: 8),
              Text('15-17 Tons'),
            ],
          ),
          value: '15-17 Tons',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SizedBox(width: 8),
              Text('18-25 Tons'),
            ],
          ),
          value: '18-25 Tons',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SizedBox(width: 8),
              Text('26-30 Tons'),
            ],
          ),
          value: '26-30 Tons',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SizedBox(width: 8),
              Text('30+ Tons'),
            ],
          ),
          value: '30+ Tons',
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          // Deselect previously selected truck
          trucks.forEach((truck) {
            truck.isSelected = false;
          });
          // Select the current truck
          selectedTruck = trucks[index];
          selectedTruck!.isSelected = true;

          selectedLoad = value as String;
        });
      }
    });
  }
  void _navigateToConfirmationPage() {
    if (selectedTruck != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationPage(
            selectedGoodsType: selectedGoodsType!,
            selectedDate: selectedDate!,
            selectedTime: selectedTime!,
            selectedTruck: selectedTruck!,
            selectedImageName: selectedTruck!.imagePath,
            fromLocation: widget.fromLocation, // Pass fromLocation here
            toLocation: widget.toLocation, // Pass toLocation here
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Select Date and Time',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orangeAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: selectedDate == null
                          ? Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Select Date',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                          : Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orangeAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: selectedTime == null
                          ? Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Select Time',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                          : Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            selectedTime!.format(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orangeAccent),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedGoodsType,
                      items: goodsList.map((goods) {
                        return DropdownMenuItem<String>(
                          value: goods,
                          child: Text(goods),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGoodsType = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Goods Type',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: Text(
                'Choose Trucks',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            for (int index = 0; index < trucks.length; index++)
              Container(
                margin: EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showPopup(context, index);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.orange, backgroundColor: selectedTruck == trucks[index] ? Colors.orange[300] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            trucks[index].imagePath,
                            height: 60.0,
                            width: 120.0,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            trucks[index].name,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            'Price: \$${trucks[index].price.toString()}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Capacity: ${trucks[index].weightCapacity.toString()} Tons',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (selectedTruck == trucks[index]) // Display only for the selected truck
                         Text(
                            selectedLoad ?? 'Select Load', // Display the selected load or 'Select Load' if no load is selected
                            style: TextStyle(color: Colors.black),
                          ),

                    ],
                  ),
                ),
              ),
            SizedBox(height: 130.0),
            ElevatedButton(
              onPressed: () {
                _navigateToConfirmationPage();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.black,
              ),
              child: Text(
                'Book Pickup',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}