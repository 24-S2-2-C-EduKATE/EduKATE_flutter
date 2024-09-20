import 'package:flutter/material.dart';
import 'sidebar.dart'; // Import the Sidebar

class TextBlockPage extends StatefulWidget {
  @override
  _TextBlockPageState createState() => _TextBlockPageState();
}

class _TextBlockPageState extends State<TextBlockPage> {
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
        title: const Text('Text Coding Page'),
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