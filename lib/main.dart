import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'package:provider/provider.dart';
import 'picture_block/pictureblock.dart'; //  PictureBlockPage
import 'wordblock.dart'; 
import 'textblock.dart';    //  TextBlockPage


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

  final GlobalKey<VirtualControllerState> virtualControllerKey = GlobalKey<VirtualControllerState>();

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage(
          onNavigate: () {
            setState(() {
              selectedIndex = 1; // 跳转到 PictureBlockPage
            });
          },
          onWordBlockNavigate: () {
            setState(() {
              selectedIndex = 2; // 跳转到 WordBlockPage
            });
          },
          onTextBlockNavigate: () {
            setState(() {
              selectedIndex = 3; // 跳转到 TextBlockPage
            });
          },
          
        );
        break;
      case 1:
        page = PictureBlockPage(virtualControllerKey: virtualControllerKey);
        break;
      case 2:
        page = WordBlockPage();
        break;
      case 3:
        page = TextBlockPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 1000,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.image),
                    label: Text('Picture Block'),
                  ),
                   NavigationRailDestination(
                    icon: Icon(Icons.book),
                    label: Text('Word Block'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.text_fields),
                    label: Text('Text Coding'),
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
    });
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback onNavigate;
  final VoidCallback onTextBlockNavigate;
  final VoidCallback onWordBlockNavigate;

  const HomePage({
    Key? key,
    required this.onNavigate,
    required this.onTextBlockNavigate,
    required this.onWordBlockNavigate,
  }) : super(key: key);

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
            height: 200,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 30),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onNavigate,
              child: Image.asset(
                'assets/images/homePicBlock.jpg',
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onWordBlockNavigate,
              child: Image.asset(
                'assets/images/homewordblock.jpg',
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTextBlockNavigate,
              child: Image.asset(
                'assets/images/hometextcoding.jpg',
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