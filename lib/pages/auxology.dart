import 'package:flutter/material.dart';
import 'package:endocrinologist/pages/bodysurfaceareatab.dart'; // Assuming this is your Body Surface Area UI
import 'package:endocrinologist/pages/genitalsizepage.dart'; // We'll create this new page
import 'package:endocrinologist/pages/finalheightoptionspage.dart'; // Your BayleyPinneauPage or a new wrapper for multiple methods
// Removed GenitalTab and Sex enum from here as GenitalSizePage will handle sex selection internally

class AuxologyPage extends StatefulWidget {
  const AuxologyPage({super.key});

  @override
  State<AuxologyPage> createState() => _AuxologyPageState();
}

class _AuxologyPageState extends State<AuxologyPage> {
  int _selectedIndex = 0; // To keep track of the selected tab

  // Define the widgets that correspond to each bottom navigation item
  // These are our "destinations" in a Flutter navigation sense
  static final List<Widget> _auxologyPages = <Widget>[
    const BodySurfaceAreaTab(), // Destination 1
    const GenitalSizePage(),    // Destination 2 (New page to create)
    const FinalHeightSelectionPage(),  // Destination 3 (Or a page that lets you select different prediction methods)
    // Add more pages here if needed, and update BottomNavigationBarItems accordingly
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This Scaffold represents the overall "Auxology" section
    // which itself might be a destination if AuxologyPage is part of a larger app navigation
    return Scaffold(
      // appBar: AppBar( // Optional: Add an AppBar if Auxology needs its own title
      //   title: const Text('Auxology'),
      //   // You might want to change the title based on _selectedIndex or remove it
      //   // if the content of each page is self-explanatory
      // ),
      body: Center(
        // Display the widget associated with the currently selected index
        child: _auxologyPages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.square_foot), // Example Icon
            label: 'BSA', // Body Surface Area
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new), // Example Icon
            label: 'Genital Size',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.height), // Example Icon
            label: 'Final Height',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary, // Use your app's theme color
        unselectedItemColor: Colors.grey, // Or another color from your theme
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Use 'fixed' if you have 3-5 items for better UX
        // Use 'shifting' for more items if needed, but 'fixed' is often preferred.
      ),
    );
  }
}
