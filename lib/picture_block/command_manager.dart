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
  String selectedCategory = 'Events'; // Default selected category

  // Method to update command images based on selected category
  void updateCommands(String category) {
    setState(() {
      selectedCategory = category; // Update the selected category
    });
    widget.onUpdateCommands(category);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row for top category buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 35),
            // Button to load Events commands
            ElevatedButton(
              onPressed: () => updateCommands('Events'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory == 'Events'
                    ? Color.fromARGB(255, 198, 236, 247) // Selected color
                    : Color.fromARGB(255, 255, 242, 190), // Default color
                elevation: 0, // Remove shadow
                minimumSize: Size(80, 30), // Set minimum width and height (width, height)
              ),
              child: const Text('Events'),
            ),
            const SizedBox(width: 3),
            // Button to load Virtual commands
            ElevatedButton(
              onPressed: () => updateCommands('Virtual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory == 'Virtual'
                    ? Color.fromARGB(255, 198, 236, 247)
                    : Color.fromARGB(255, 255, 242, 190),
                elevation: 0, // Remove shadow
                minimumSize: Size(80, 30), // Set minimum width and height (width, height)
              ),
              child: const Text('Virtual'),
            ),
            const SizedBox(width: 3),
            // Button to load Actions commands
            ElevatedButton(
              onPressed: () => updateCommands('Actions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory == 'Actions'
                    ? Color.fromARGB(255, 198, 236, 247)
                    : Color.fromARGB(255, 255, 242, 190),
                elevation: 0, // Remove shadow
                minimumSize: Size(80, 30), // Set minimum width and height (width, height)
              ),
              child: const Text('Actions'),
            ),
            const SizedBox(width: 3),
            // Button to load Variables commands
            ElevatedButton(
              onPressed: () => updateCommands('Variables'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory == 'Variables'
                    ? Color.fromARGB(255, 198, 236, 247)
                    : Color.fromARGB(255, 255, 242, 190),
                elevation: 0, // Remove shadow
                minimumSize: Size(80, 30), // Set minimum width and height (width, height)
              ),
              child: const Text('Variables'),
            ),
            const SizedBox(width: 3),
            // Button to load Control commands
            ElevatedButton(
              onPressed: () => updateCommands('Control'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory == 'Control'
                    ? Color.fromARGB(255, 198, 236, 247)
                    : Color.fromARGB(255, 255, 242, 190),
                elevation: 0, // Remove shadow
                minimumSize: Size(80, 30), // Set minimum width and height (width, height)
              ),
              child: const Text('Control'),
            ),
            const SizedBox(width: 3),
            // Button to load Sound commands
            ElevatedButton(
              onPressed: () => updateCommands('Sound'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory == 'Sound'
                    ? Color.fromARGB(255, 198, 236, 247)
                    : Color.fromARGB(255, 255, 242, 190),
                elevation: 0, // Remove shadow
                minimumSize: Size(80, 30), // Set minimum width and height (width, height)
              ),
              child: const Text('Sound'),
            ),
          ],
        ),
        // Area to display command images
        Container(
          height: 100,
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 198, 236, 247), // Inner container background color
              borderRadius: BorderRadius.circular(50), // Rounded corners for the inner container
            ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0), // Top and bottom padding of 8, left and right padding of 20
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
                          fit: BoxFit.contain, // Maintain aspect ratio
                          height: 85, // Fixed height
                        ),
                      ),
                    ),
                    child: SizedBox(
                      height: 85,
                      child: Image.asset(
                        widget.commandImages[index],
                        fit: BoxFit.contain, // Maintain aspect ratio
                        height: 85, // Fixed height
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