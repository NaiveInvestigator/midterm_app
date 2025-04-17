import 'package:flutter/material.dart';
import 'pages/map_screen.dart';
import 'pages/entity_form_screen.dart';
import 'pages/entity_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Initialize with the MapScreen as the default
  Widget _currentScreen = MapScreen();

  void _selectScreen(Widget screen) {
    setState(() {
      _currentScreen = screen; // Update the content of the body
    });
    Navigator.pop(context); // Close the Drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Midterm App')),
      drawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 200, child: Container(color: Colors.blue)),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
              onTap: () {
                _selectScreen(MapScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Entity Form'),
              onTap: () {
                _selectScreen(EntityFormScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Entity List'),
              onTap: () {
                _selectScreen(EntityListScreen());
              },
            ),
          ],
        ),
      ),
      body:
          _currentScreen, // Displays the selected screen (defaults to MapScreen)
    );
  }
}
