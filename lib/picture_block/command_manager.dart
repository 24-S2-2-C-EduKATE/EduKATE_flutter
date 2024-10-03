// command_manager.dart

import 'package:flutter/material.dart';

class CommandManager extends StatefulWidget {
  final Function(String) onUpdateCommands; // Callback for updating commands
  final List<String> commandImages; // List to hold command images

  const CommandManager({
    Key? key,
    required this.onUpdateCommands,
    required this.commandImages,
  }) : super(key: key);

  @override
  _CommandManagerState createState() => _CommandManagerState();
}

class _CommandManagerState extends State<CommandManager> {
  // Method to update command images based on selected category
  void updateCommands(String category) {
    widget.onUpdateCommands(category);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        // Row for top category buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 5),
            // Button to load Events commands
            ElevatedButton(
              onPressed: () => updateCommands('Events'),
              child: const Text('Events'),
            ),
            const SizedBox(width: 5),
            // Button to load Virtual commands
            ElevatedButton(
              onPressed: () => updateCommands('Virtual'),
              child: const Text('Virtual'),
            ),
            const SizedBox(width: 5),
            // Button to load Actions commands
            ElevatedButton(
              onPressed: () => updateCommands('Actions'),
              child: const Text('Actions'),
            ),
            const SizedBox(width: 5),
            // Button to load Variables commands
            ElevatedButton(
              onPressed: () => updateCommands('Variables'),
              child: const Text('Variables'),
            ),
            const SizedBox(width: 5),
            // Button to load Control commands
            ElevatedButton(
              onPressed: () => updateCommands('Control'),
              child: const Text('Control'),
            ),
            const SizedBox(width: 5),
            // Button to load Sound commands
            ElevatedButton(
              onPressed: () => updateCommands('Sound'),
              child: const Text('Sound'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Area to display command images
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.commandImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Draggable<String>(
                  data: widget.commandImages[index],
                  feedback: Material(
                    child: SizedBox(
                      height: 85,
                      child: Image.asset(
                        widget.commandImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: 85,
                    child: Image.asset(
                      widget.commandImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}