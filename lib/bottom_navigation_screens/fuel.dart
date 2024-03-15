import 'package:flutter/material.dart';

class Fuel extends StatefulWidget {
  const Fuel({super.key});

  @override
  State<Fuel> createState() => _FuelState();
}

class _FuelState extends State<Fuel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel'),
      ),
      body: Center(
        child: Text('Comming Soon....',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
      ),
    );
  }
}
