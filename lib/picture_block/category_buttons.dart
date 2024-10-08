// category_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/block_data.dart';

class CategoryButtons extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onUpdateCommands;

  const CategoryButtons({
    Key? key,
    required this.selectedCategory,
    required this.onUpdateCommands,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => onUpdateCommands('Events'),
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedCategory == 'Events'
                ? Color.fromARGB(255, 198, 236, 247) // Selected color
                : Color.fromARGB(255, 255, 242, 190), // Default color
            elevation: 0,
            minimumSize: Size(80, 30),
          ),
          child: const Text('Events'),
        ),
        const SizedBox(width: 3),
        ElevatedButton(
          onPressed: () => onUpdateCommands('Virtual'),
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedCategory == 'Virtual'
                ? Color.fromARGB(255, 198, 236, 247)
                : Color.fromARGB(255, 255, 242, 190),
            elevation: 0,
            minimumSize: Size(80, 30),
          ),
          child: const Text('Virtual'),
        ),
        const SizedBox(width: 3),
        ElevatedButton(
          onPressed: () => onUpdateCommands('Actions'),
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedCategory == 'Actions'
                ? Color.fromARGB(255, 198, 236, 247)
                : Color.fromARGB(255, 255, 242, 190),
            elevation: 0,
            minimumSize: Size(80, 30),
          ),
          child: const Text('Actions'),
        ),
        const SizedBox(width: 3),
        ElevatedButton(
          onPressed: () => onUpdateCommands('Variables'),
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedCategory == 'Variables'
                ? Color.fromARGB(255, 198, 236, 247)
                : Color.fromARGB(255, 255, 242, 190),
            elevation: 0,
            minimumSize: Size(80, 30),
          ),
          child: const Text('Variables'),
        ),
        const SizedBox(width: 3),
        ElevatedButton(
          onPressed: () => onUpdateCommands('Control'),
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedCategory == 'Control'
                ? Color.fromARGB(255, 198, 236, 247)
                : Color.fromARGB(255, 255, 242, 190),
            elevation: 0,
            minimumSize: Size(80, 30),
          ),
          child: const Text('Control'),
        ),
        const SizedBox(width: 3),
        ElevatedButton(
          onPressed: () => onUpdateCommands('Sound'),
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedCategory == 'Sound'
                ? Color.fromARGB(255, 198, 236, 247)
                : Color.fromARGB(255, 255, 242, 190),
            elevation: 0,
            minimumSize: Size(80, 30),
          ),
          child: const Text('Sound'),
        ),
      ],
    );
  }
}