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
        // Removed buttons from here
        // Area to display command images
        Container(
          height: 90,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 198, 236, 247),
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.commandImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Draggable<String>(
                  data: widget.commandImages[index],
                  feedback: Material(
                    child: SizedBox(
                      height: 85,
                      child: Image.asset(
                        widget.commandImages[index],
                        fit: BoxFit.contain,
                        height: 85,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: 85,
                    child: Image.asset(
                      widget.commandImages[index],
                      fit: BoxFit.contain,
                      height: 85,
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