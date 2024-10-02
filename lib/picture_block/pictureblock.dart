import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/block_sequence.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'package:provider/provider.dart';
import 'sidebar.dart'; // Import the Sidebar
import 'block_data.dart';
import 'dragable_block.dart';

class PictureBlockPage extends StatefulWidget {
  const PictureBlockPage({Key? key}) : super(key: key);

  @override
  _PictureBlockPageState createState() => _PictureBlockPageState();
}

class _PictureBlockPageState extends State<PictureBlockPage> {
  List<String> commandImages = []; // List to hold the command image paths
  List<BlockData> arrangedCommands = []; // List to hold the arranged blocks
  String selectedCategory = 'Events'; // Default category for command images
  bool isSidebarOpen = false; // State to control sidebar visibility
  BlockSequence blockSequence = BlockSequence(); // Instance of BlockSequence to manage block order

  GlobalKey _stackKey = GlobalKey(); // Key for the stack to get its size and position
  final GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    updateCommands(selectedCategory); // Load command images initially
  }

  void updateCommands(String category) {
    setState(() {
      selectedCategory = category; // Update the selected category
      // Load command images based on the selected category
      if (category == 'Events') {
        commandImages = [
          'assets/images/follow.jpg',
          'assets/images/lift_leg.jpg',
          'assets/images/noseButton.jpg',
          'assets/images/sound.png',
          'assets/images/start.jpg',
          'assets/images/wait.jpg',
          'assets/images/cry.jpg',
          'assets/images/right.jpg',
        ];
      } else if (category == 'Virtual') {
        commandImages = [
          'assets/images/move_up.png',
          'assets/images/move_down.png',
          'assets/images/move_left.png',
          'assets/images/move_right.png',
        ];
      } else if (category == 'Actions') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
          'assets/images/sound.png',
        ];
      }else if (category == 'Variables') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
          'assets/images/sound.png',
        ];
      }else if (category == 'Control') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
          'assets/images/sound.png',
        ];
      }else if (category == 'Sound') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
          'assets/images/sound.png',
        ];
      }
      // More categories can be added here
    });
  }

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen; // Toggle the sidebar visibility
    });
  }

  // Get local position within the workspace
  Offset _getLocalPosition(Offset globalPosition) {
    final RenderBox stackRenderBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
    return stackRenderBox.globalToLocal(globalPosition); // Convert global position to local
  }

  // Handle the update of block connections
  void _handleBlockUpdate(BlockData movedBlock) {
    setState(() {
      // Check if the block is dragged outside the workspace
      if (movedBlock.position.dx < 0 || movedBlock.position.dx > _stackKey.currentContext!.size!.width ||
          movedBlock.position.dy < 0 || movedBlock.position.dy > _stackKey.currentContext!.size!.height) {
        // Remove block if dragged outside
        arrangedCommands.removeWhere((block) => block.id == movedBlock.id);
        blockSequence.updateOrder(arrangedCommands); // Update block order
        return;
      }
      bool connected = false; // Flag to check if the block is connected

      // Check connections with other blocks
      for (var block in arrangedCommands) {
        if (block != movedBlock) {
          // Check top connection
          if (_canConnect(block, movedBlock, ConnectionType.bottom)) {
            _establishConnection(block, movedBlock, ConnectionType.bottom);
            connected = true; // Mark as connected
            break;
          }
          // Check bottom connection
          else if (_canConnect(movedBlock, block, ConnectionType.bottom)) {
            _establishConnection(movedBlock, block, ConnectionType.bottom);
            connected = true;
            break;
          }
          // Check left connection
          else if (_canConnect(block, movedBlock, ConnectionType.right)) {
            _establishConnection(block, movedBlock, ConnectionType.right);
            connected = true;
            break;
          }
          // Check right connection
          else if (_canConnect(movedBlock, block, ConnectionType.right)) {
            _establishConnection(movedBlock, block, ConnectionType.right);
            connected = true;
            break;
          }
          // Additional connection types can be added here
        }
      }

      // If no connection is made, disconnect all
      if (!connected) {
        _disconnectAll(movedBlock);
      }
      blockSequence.updateOrder(arrangedCommands); // Update block order
      blockSequence.printBlockOrder(); // Print the order of blocks
    });
  }

  // Establish a connection between two blocks
  void _establishConnection(BlockData block1, BlockData block2, ConnectionType connectionType) {
    // Update connection relations
    block1.connections[connectionType] = Connection(type: connectionType, connectedBlock: block2);
    block2.connections[_getOppositeConnectionType(connectionType)] = Connection(
      type: _getOppositeConnectionType(connectionType),
      connectedBlock: block1,
    );

    // Align positions based on connection type
    switch (connectionType) {
      case ConnectionType.top:
        block2.position = block1.position - Offset(0, blockHeight);
        break; // Add break statement to exit the switch
      case ConnectionType.bottom:
        block2.position = block1.position + Offset(0, blockHeight);
        break; // Add break statement to exit the switch
      case ConnectionType.left:
        block2.position = block1.position - Offset(blockWidth, 0);
        break; // Add break statement to exit the switch
      case ConnectionType.right:
        block2.position = block1.position + Offset(blockWidth, 0);
        break; // Add break statement to exit the switch
    }
  }

  // Disconnect all connections of a block
  void _disconnectAll(BlockData block) {
    for (var connectionType in block.connections.keys.toList()) {
      var connectedBlock = block.connections[connectionType]?.connectedBlock;
      if (connectedBlock != null) {
        connectedBlock.connections.remove(_getOppositeConnectionType(connectionType)); // Remove opposite connection
      }
      block.connections.remove(connectionType); // Remove connection
    }
  }

  // Get the opposite connection type
  ConnectionType _getOppositeConnectionType(ConnectionType type) {
    switch (type) {
      case ConnectionType.top:
        return ConnectionType.bottom;
      case ConnectionType.bottom:
        return ConnectionType.top;
      case ConnectionType.left:
        return ConnectionType.right;
      case ConnectionType.right:
        return ConnectionType.left;
    }
  }

  // Define block dimensions
  double blockWidth = 85.0; // Adjust according to actual size
  double blockHeight = 85.0; // Adjust according to actual size

  // Check if two blocks can connect
  bool _canConnect(BlockData block1, BlockData block2, ConnectionType connectionType) {
    double threshold = 20.0; // Distance threshold for connection

    Offset position1, position2;

    switch (connectionType) {
      case ConnectionType.top:
        position1 = block1.position;
        position2 = block2.position + Offset(0, blockHeight);
        break; // Add break statement to exit the switch
      case ConnectionType.bottom:
        position1 = block1.position + Offset(0, blockHeight);
        position2 = block2.position;
        break; // Add break statement to exit the switch
      case ConnectionType.left:
        position1 = block1.position;
        position2 = block2.position + Offset(blockWidth, 0);
        break; // Add break statement to exit the switch
      case ConnectionType.right:
        position1 = block1.position + Offset(blockWidth, 0);
        position2 = block2.position;
        break; // Add break statement to exit the switch
    }

    // Check distance for potential connection
    if ((position1 - position2).distance <= threshold) {
      // Optionally check alignment
      if (connectionType == ConnectionType.left || connectionType == ConnectionType.right) {
        if ((block1.position.dy - block2.position.dy).abs() <= threshold) {
          return true; // Aligned vertically
        }
      } else {
        if ((block1.position.dx - block2.position.dx).abs() <= threshold) {
          return true; // Aligned horizontally
        }
      }
    }

    return false; // No connection can be established
  }

@override
Widget build(BuildContext context) {
  // Retrieve the VirtualController instance from the Provider
  final virtualController = Provider.of<VirtualController>(context);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Picture Block Page'), // Title of the AppBar
      actions: [
        // Button to toggle the sidebar
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_right_outlined),
          onPressed: toggleSidebar,
        ),
        // Spacer to push the buttons to the end
        const SizedBox(width: 8),
        // Row to hold the circular buttons
        Row(
          children: [
            // Upload Button
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 198, 236, 247), // Background color
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black), // Black border
              ),
              child: FloatingActionButton(
                onPressed: () {
                
                  // Handle upload action
                },
                mini: true, // Smaller size
                elevation: 0, // Remove shadow
                hoverElevation: 0,
                highlightElevation: 0, // Remove highlight shadow
                backgroundColor: Colors.transparent, // Make background transparent to show the container color
                child: const Icon(Icons.pets),
              ),
            ),
            const SizedBox(width: 8), // Spacing between buttons
            // Run Button
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 198, 236, 247), // Background color
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black), // Black border
              ),
              child: FloatingActionButton(
                onPressed: () {
                  // Use the VirtualController instance to execute moves
                  virtualController.executeMoves(blockSequence.getBlockOrder());
                },
                mini: true,
                elevation: 0, // Remove shadow
                hoverElevation: 0,
                highlightElevation: 0, // Remove highlight shadow
                backgroundColor: Colors.transparent, // Make background transparent to show the container color
                child: const Icon(Icons.play_arrow),
              ),
            ),
            const SizedBox(width: 8),
            // Stop Button
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 198, 236, 247), // Background color
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black), // Black border
              ),
              child: FloatingActionButton(
                onPressed: () {
                  // Handle stop action
                },
                mini: true,
                elevation: 0, // Remove shadow
                hoverElevation: 0,
                highlightElevation: 0, // Remove highlight shadow
                backgroundColor: Colors.transparent, // Make background transparent to show the container color
                child: const Icon(Icons.stop),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: Row(
      // Main layout using a Row to organize the screen
      children: [
        Expanded(
          child: Column(
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
                height: 85, // Fixed height for the command image area
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8, // Number of columns in the grid
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 85, // Height of each grid cell
                  ),
                  itemCount: commandImages.length,
                  itemBuilder: (context, index) {
                    return Draggable<String>(
                      data: commandImages[index], // Data to be passed on drag
                      feedback: Material(
                        child: SizedBox(
                          height: 85,
                          child: Image.asset(
                            commandImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        child: Image.asset(
                          commandImages[index], // Display the command image
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // User's area for arranging blocks
              Expanded(
                child: Container(
                  key: _containerKey, // Key to manage the container's state
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/picGround.jpg'), // Background image
                      fit: BoxFit.cover, // Fill mode for the background image
                    ),
                  ),
                  child: Stack(
                    key: _stackKey,
                    children: [
                      // DragTarget for accepting new blocks
                      DragTarget<String>( 
                        onAcceptWithDetails: (details) {
                          final localPosition = _getLocalPosition(details.offset); // Get local position of the dropped block
                          setState(() {
                            arrangedCommands.add(BlockData(
                              imagePath: details.data, // Path of the dropped image
                              position: localPosition, // Position to place the block
                            ));
                            // Update the sequence of blocks
                            blockSequence.updateOrder(arrangedCommands);
                            blockSequence.printBlockOrder(); // Print the current order of blocks
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.transparent, // Transparent area for drag target
                          );
                        },
                      ),
                      // Render the blocks that have been placed
                      ...arrangedCommands.map((block) {
                        return DraggableBlock(
                          blockData: block, // Pass the block data
                          onUpdate: _handleBlockUpdate, // Callback to handle block updates
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Sidebar widget, open/closed based on state
        Sidebar(isOpen: isSidebarOpen), // Uses the Sidebar class
        // Spacer for layout
        const SizedBox(height: 5),
      ]
    ),
  );
}
}