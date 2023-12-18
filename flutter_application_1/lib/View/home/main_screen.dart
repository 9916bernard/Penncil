import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      hintText: 'Enter search term'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextButton(
                      onPressed: () {
                        // Your button press logic here.
                      },
                      child: Text('Class 101'),
                    ),
                  ),
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextButton(
                      onPressed: () {
                        // Your button press logic here.
                      },
                      child: Text('Class 102'),
                    ),
                  ),
                ],
              ),
              Container(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextButton(
                      onPressed: () {
                        // Your button press logic here.
                      },
                      child: Text('Class 103'),
                    ),
                  ),
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextButton(
                      onPressed: () {
                        // Your button press logic here.
                      },
                      child: Text('Class 104'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )); // Home screen content 
  }
}
