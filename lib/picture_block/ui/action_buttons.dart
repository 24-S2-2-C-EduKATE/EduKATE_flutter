// action_buttons.dart
import 'package:flutter/material.dart'; 

class ActionButtons extends StatelessWidget {
  final Function() onUpload;
  final Function() onRun;
  final Function() onStop;

  const ActionButtons({
    Key? key,
    required this.onUpload,
    required this.onRun,
    required this.onStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        // Upload Button
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 198, 236, 247), // Background color
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black), // Black border
          ),
          child: FloatingActionButton(
            onPressed: onUpload,
            mini: true, // Smaller size
            elevation: 0, // Remove shadow
            hoverElevation: 0,
            highlightElevation: 0, // Remove highlight shadow
            backgroundColor: Colors.transparent, // Make background transparent to show the container color
            child: const Icon(Icons.pets),
          ),
        ),
        const SizedBox(width: 20), // Spacing between buttons

        // Run Button
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 198, 236, 247), // Background color
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black), // Black border
          ),
          child: FloatingActionButton(
            onPressed: () {
              onRun(); // Call the run function passed from the parent
            },
            mini: true,
            elevation: 0, // Remove shadow
            hoverElevation: 0,
            highlightElevation: 0, // Remove highlight shadow
            backgroundColor: Colors.transparent, // Make background transparent to show the container color
            child: const Icon(Icons.play_arrow),
          ),
        ),
        const SizedBox(width: 20),

        // Stop Button
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 198, 236, 247), // Background color
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black), // Black border
          ),
          child: FloatingActionButton(
            onPressed: onStop,
            mini: true,
            elevation: 0, // Remove shadow
            hoverElevation: 0,
            highlightElevation: 0, // Remove highlight shadow
            backgroundColor: Colors.transparent, // Make background transparent to show the container color
            child: const Icon(Icons.hexagon),
          ),
        ),
      ],
    );
  }
}