import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'package:provider/provider.dart';
import 'picture_block/pictureblock.dart'; // Import PictureBlockPage
import 'wordblock.dart'; 
import 'textblock.dart';    // Import TextBlockPage

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()), // Provider for MyAppState
        ChangeNotifierProvider(create: (_) => VirtualController()),  // Provider for VirtualController
      ],
      child: const MyApp(), // Start the app with MyApp widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduKate', // Title of the application
      theme: ThemeData(
        useMaterial3: true, // Enable Material 3 design
        scaffoldBackgroundColor: Color(0xFFFFD2E2), // Set background color of the scaffold
      ),
      home: MyHomePage(), // Set home page
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // Random word pair state

  void getNext() {
    current = WordPair.random(); // Generate the next random word pair
    notifyListeners(); // Notify listeners about the state change
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Track the selected index for navigation

  @override
  Widget build(BuildContext context) {
    Widget page; // Variable to hold the current page

    // Determine which page to show based on the selected index
    switch (selectedIndex) {
      case 0:
        page = HomePage(
          onNavigate: () {
            setState(() {
              selectedIndex = 1; // Navigate to PictureBlockPage
            });
          },
          onWordBlockNavigate: () {
            setState(() {
              selectedIndex = 2; // Navigate to WordBlockPage
            });
          },
          onTextBlockNavigate: () {
            setState(() {
              selectedIndex = 3; // Navigate to TextBlockPage
            });
          },
        );
      case 1:
        page = PictureBlockPage(); // Show PictureBlockPage
      case 2:
        page = WordBlockPage(); // Show WordBlockPage
      case 3:
        page = TextBlockPage(); // Show TextBlockPage
      default:
        throw UnimplementedError('no widget for $selectedIndex'); // Handle unimplemented cases
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 1400, // Extend the rail for larger screens
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home), // Icon for Home
                    label: Text('Home'), // Label for Home
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.image), // Icon for Picture Block
                    label: Text('Picture Block'), // Label for Picture Block
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.book), // Icon for Word Block
                    label: Text('Word Block'), // Label for Word Block
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.text_fields), // Icon for Text Coding
                    label: Text('Text Coding'), // Label for Text Coding
                  ),
                ],
                selectedIndex: selectedIndex, // Current selected index
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value; // Update selected index on navigation
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                child: page, // Display the selected page
              ),
            ),
          ],
        ),
      );
    });
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback onNavigate; // Callback for Picture Block navigation
  final VoidCallback onTextBlockNavigate; // Callback for Text Block navigation
  final VoidCallback onWordBlockNavigate; // Callback for Word Block navigation

  const HomePage({
    Key? key,
    required this.onNavigate,
    required this.onTextBlockNavigate,
    required this.onWordBlockNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.jpg', // Application logo
            height: 200,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 30),
          MouseRegion(
            cursor: SystemMouseCursors.click, // Change cursor on hover
            child: GestureDetector(
              onTap: onNavigate, // Navigate to Picture Block on tap
              child: Image.asset(
                'assets/images/homePicBlock.jpg', // Image for Picture Block navigation
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5),
          MouseRegion(
            cursor: SystemMouseCursors.click, // Change cursor on hover
            child: GestureDetector(
              onTap: onWordBlockNavigate, // Navigate to Word Block on tap
              child: Image.asset(
                'assets/images/homewordblock.jpg', // Image for Word Block navigation
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5),
          MouseRegion(
            cursor: SystemMouseCursors.click, // Change cursor on hover
            child: GestureDetector(
              onTap: onTextBlockNavigate, // Navigate to Text Block on tap
              child: Image.asset(
                'assets/images/hometextcoding.jpg', // Image for Text Coding navigation
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
