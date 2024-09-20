import 'package:flutter/material.dart';
import 'sidebar.dart'; // Import the Sidebar

class WordBlockPage extends StatefulWidget {
  @override
  _WordBlockPageState createState() => _WordBlockPageState();
}

class _WordBlockPageState extends State<WordBlockPage> {
  bool isSidebarOpen = false;

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Block Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_right_outlined),
            onPressed: toggleSidebar,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              // Your main content here
            ),
          ),
          Sidebar(isOpen: isSidebarOpen), // Use the Sidebar
        ],
      ),
    );
  }
}