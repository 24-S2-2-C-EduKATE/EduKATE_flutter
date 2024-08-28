import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'EduKate',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Color(0xFFFFD2E2),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage(onNavigate: () {
          setState(() {
            selectedIndex = 1; // 跳转到 PictureBlockPage
          });
        });
      case 1:
        page = PictureBlockPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
}

    return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.image),
                      label: Text('Picture Block'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class HomePage extends StatelessWidget {

  final VoidCallback onNavigate; // 添加导航回调

  const HomePage({Key? key, required this.onNavigate}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
            'assets/images/logo.jpg',
            height: 200, // Set the desired height
            fit: BoxFit.cover, // Fit mode for the image
            ),
            SizedBox(height: 30), // Add spacing between the images
            MouseRegion(
              cursor: SystemMouseCursors.click, 
              // Change cursor to pointer when hovering
              child: GestureDetector(
                onTap: onNavigate, // Event triggered on tap
                child: Image.asset(
                  'assets/images/homePicBlock.jpg',
                  height: 60, // Set the desired height
                  fit: BoxFit.cover, // Fit mode for the image
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class PictureBlockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(8, (index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/images/lift_leg.jpg', // Adjust the file name as needed
                  width: 50, // Adjust the size as needed
                  height: 50,
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.purpleAccent, // Adjust the color as needed
            child: Center(
              child: Text(
                'Content Below',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
