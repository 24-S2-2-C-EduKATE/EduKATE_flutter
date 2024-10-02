import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatelessWidget {
  final bool isOpen; // Boolean to check if the sidebar is open

  Sidebar({required this.isOpen}); // Constructor to initialize the sidebar's open state

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300), // Duration for the sidebar's opening/closing animation
      width: isOpen ? 300 : 0, // Width of the sidebar based on its open state
      child: Drawer(
        child: isOpen
            ? Consumer<VirtualController>(builder: (context, virtualController, child) {
                return Column(
                  children: [
                    // Display the current level information
                    Text('Current Level: ${virtualController.currentLevel?.id ?? 'N/A'}'),
                    Expanded(
                      child: virtualController.isLoading // Show loading indicator if data is loading
                          ? Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                // Display the level ID
                                Text('Level ${virtualController.currentLevel!.id}'),
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1, // Maintain a square aspect ratio for the grid
                                    child: GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: virtualController.currentLevel!.gridN, // Number of columns in the grid
                                      ),
                                      itemCount: virtualController.activeGrid.length, // Number of tiles in the grid
                                      itemBuilder: (context, index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(), // Border for each tile
                                          ),
                                          child: Image.asset(
                                            'assets/blocks/${virtualController.activeGrid[index].tileType}.png', // Load image based on tile type
                                            fit: BoxFit.fill, // Fit image within the container
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    // Row for level navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Button to go to the previous level
                        ElevatedButton(
                          onPressed: virtualController.previousLevel,
                          child: const Text('Previous Level'),
                        ),
                        // Button to go to the next level
                        ElevatedButton(
                          onPressed: virtualController.nextLevel,
                          child: const Text('Next Level'),
                        ),
                      ],
                    ),
                  ],
                );
              })
            : null, // If sidebar is closed, return null
      ),
    );
  }
}
