import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/block_sequence.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'sidebar.dart'; // Import the Sidebar for navigation
import 'block_data.dart'; // Import the BlockData model
import 'dragable_block.dart'; // Import the DraggableBlock widget

class PictureBlockPage extends StatefulWidget {
  final GlobalKey<VirtualControllerState> virtualControllerKey; // Key to access VirtualController

  const PictureBlockPage({Key? key, required this.virtualControllerKey}) : super(key: key);

  @override
  _PictureBlockPageState createState() => _PictureBlockPageState();
}

class _PictureBlockPageState extends State<PictureBlockPage> {
  List<String> commandImages = []; // List to hold command image paths
  List<BlockData> arrangedCommands = []; // List of blocks that have been arranged
  String selectedCategory = 'General'; // Default category for commands
  bool isSidebarOpen = false; // Control the state of the sidebar
  BlockSequence blockSequence = BlockSequence(); // Manage the order of blocks

  GlobalKey _stackKey = GlobalKey(); // Key for accessing the stack's size and position

  @override
  void initState() {
    super.initState();
    updateCommands(selectedCategory); // Load initial command images based on the selected category
  }

  // Update the command images based on the selected category
  void updateCommands(String category) {
    setState(() {
      selectedCategory = category; // Update the selected category
      if (category == 'General') {
        commandImages = [
          'assets/images/follow.jpg',
          'assets/images/lift_leg.jpg',
          'assets/images/noseButton.jpg',
          'assets/images/sound.jpg',
          'assets/images/start.jpg',
          'assets/images/wait.jpg',
          'assets/images/cry.jpg',
          'assets/images/right.jpg',
        ];
      } else if (category == 'Category 1') {
        commandImages = [
          'assets/images/follow.jpg', // Example image
          'assets/images/move_up.png',
          'assets/images/move_down.png',
          'assets/images/move_left.png',
          'assets/images/move_right.png',
        ];
      } else if (category == 'Category 2') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
        ];
      }
      // More categories can be added as needed
    });
  }

  // Toggle the sidebar open/close state
  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen; // Switch sidebar visibility
    });
  }

  // Get local position within the workspace from global position
  Offset _getLocalPosition(Offset globalPosition) {
    final RenderBox stackRenderBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
    return stackRenderBox.globalToLocal(globalPosition);
  }

  // Handle the update of the moved block
  void _handleBlockUpdate(BlockData movedBlock) {
    setState(() {
      // Check if the block has been dragged out of the workspace
      if (movedBlock.position.dx < 0 || movedBlock.position.dx > _stackKey.currentContext!.size!.width ||
          movedBlock.position.dy < 0 || movedBlock.position.dy > _stackKey.currentContext!.size!.height) {
        // Remove the block if it has been dragged out of the workspace
        arrangedCommands.removeWhere((block) => block.id == movedBlock.id);
        blockSequence.updateOrder(arrangedCommands); // Update block order
        return; // Exit the function early
      }
      bool connected = false; // Track if any connections were made

      for (var block in arrangedCommands) {
        if (block != movedBlock) {
          // Check for connections between blocks
          if (_canConnect(block, movedBlock, ConnectionType.bottom)) {
            _establishConnection(block, movedBlock, ConnectionType.bottom); // Establish bottom connection
            connected = true;
            break; // Exit loop if connected
          }
          // Check for bottom connection
          else if (_canConnect(movedBlock, block, ConnectionType.bottom)) {
            _establishConnection(movedBlock, block, ConnectionType.bottom); // Establish bottom connection
            connected = true;
            break; // Exit loop if connected
          }
          // Check for left connection
          else if (_canConnect(block, movedBlock, ConnectionType.right)) {
            _establishConnection(block, movedBlock, ConnectionType.right); // Establish right connection
            connected = true;
            break; // Exit loop if connected
          }
          // Check for right connection
          else if (_canConnect(movedBlock, block, ConnectionType.right)) {
            _establishConnection(movedBlock, block, ConnectionType.right); // Establish right connection
            connected = true;
            break; // Exit loop if connected
          }
          // More connection types can be added
        }
      }

      // If no connections were made, disconnect the block
      if (!connected) {
        _disconnectAll(movedBlock); // Disconnect the block from all others
      }
      blockSequence.updateOrder(arrangedCommands); // Update the order after all connections
      blockSequence.printBlockOrder(); // Print the current order of blocks
    });
  }

  // Establish a connection between two blocks
  void _establishConnection(BlockData block1, BlockData block2, ConnectionType connectionType) {
    // Update the connection relationships between blocks
    block1.connections[connectionType] = Connection(type: connectionType, connectedBlock: block2);
    block2.connections[_getOppositeConnectionType(connectionType)] = Connection(
      type: _getOppositeConnectionType(connectionType),
      connectedBlock: block1,
    );

    // Align the positions based on the connection type
    switch (connectionType) {
      case ConnectionType.top:
        block2.position = block1.position - Offset(0, blockHeight); // Align block2 above block1
        break;
      case ConnectionType.bottom:
        block2.position = block1.position + Offset(0, blockHeight); // Align block2 below block1
        break;
      case ConnectionType.left:
        block2.position = block1.position - Offset(blockWidth, 0); // Align block2 to the left of block1
        break;
      case ConnectionType.right:
        block2.position = block1.position + Offset(blockWidth, 0); // Align block2 to the right of block1
        break;
    }
  }

  // Disconnect all connections for a specific block
  void _disconnectAll(BlockData block) {
    for (var connectionType in block.connections.keys.toList()) {
      var connectedBlock = block.connections[connectionType]?.connectedBlock; // Get the connected block
      if (connectedBlock != null) {
        connectedBlock.connections.remove(_getOppositeConnectionType(connectionType)); // Remove connection from the other block
      }
      block.connections.remove(connectionType); // Remove the connection from this block
    }
  }

  // Get the opposite connection type for a given type
  ConnectionType _getOppositeConnectionType(ConnectionType type) {
    switch (type) {
      case ConnectionType.top:
        return ConnectionType.bottom; // Opposite of top is bottom
      case ConnectionType.bottom:
        return ConnectionType.top; // Opposite of bottom is top
      case ConnectionType.left:
        return ConnectionType.right; // Opposite of left is right
      case ConnectionType.right:
        return ConnectionType.left; // Opposite of right is left
    }
  }

  // Define the dimensions of the blocks
  double blockWidth = 100.0; // Adjust based on actual size
  double blockHeight = 85.0; // Adjust based on actual size

  // Check if two blocks can connect based on their positions and connection type
  bool _canConnect(BlockData block1, BlockData block2, ConnectionType connectionType) {
    double threshold = 20.0; // Distance threshold for connecting

    Offset position1, position2; // Positions for checking connection

    switch (connectionType) {
      case ConnectionType.top:
        position1 = block1.position; // Position of block1
        position2 = block2.position + Offset(0, blockHeight); // Position of block2 adjusted for top connection
        break;
      case ConnectionType.bottom:
        position1 = block1.position + Offset(0, blockHeight); // Position of block1 adjusted for bottom connection
        position2 = block2.position; // Position of block2
        break;
      case ConnectionType.left:
        position1 = block1.position; // Position of block1
        position2 = block2.position + Offset(blockWidth, 0); // Position of block2 adjusted for left connection
        break;
      case ConnectionType.right:
        position1 = block1.position + Offset(blockWidth, 0); // Position of block1 adjusted for right connection
        position2 = block2.position; // Position of block2
        break;
    }

    // Check if the distance between the positions is within the threshold
    if ((position1 - position2).distance <= threshold) {
      // Optional: Check for alignment (can be adjusted)
      if (connectionType == ConnectionType.left || connectionType == ConnectionType.right) {
        // For left/right connections, check vertical alignment
        if ((block1.position.dy - block2.position.dy).abs() <= threshold) {
          return true; // Aligned
        }
      } else {
        // For top/bottom connections, check horizontal alignment
        if ((block1.position.dx - block2.position.dx).abs() <= threshold) {
          return true; // Aligned
        }
      }
    }
    return false; // Not connected
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Picture Block Page'), // App bar title
      actions: [
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_right_outlined), // Icon for sidebar toggle
          onPressed: toggleSidebar, // Function to toggle sidebar visibility
        ),
      ],
    ),
    body: Row(
      // Main layout using a Row widget
      children: [
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 10), // Spacer
              // Top category buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10), // Spacer
                  ElevatedButton(
                    onPressed: () => updateCommands('General'), // Update commands for 'General' category
                    child: const Text('General'),
                  ),
                  const SizedBox(width: 10), // Spacer
                  ElevatedButton(
                    onPressed: () => updateCommands('Category 1'), // Update commands for 'Category 1'
                    child: const Text('Category 1'),
                  ),
                  const SizedBox(width: 10), // Spacer
                  ElevatedButton(
                    onPressed: () => updateCommands('Category 2'), // Update commands for 'Category 2'
                    child: const Text('Category 2'),
                  ),
                  // Additional category buttons can be added here
                ],
              ),
              const SizedBox(height: 10), // Spacer
              // Run button
              ElevatedButton(
                onPressed: () {
                  // Call VirtualController's executeMoves using GlobalKey
                  if (widget.virtualControllerKey.currentState != null) {
                    setState(() {
                      widget.virtualControllerKey.currentState!.executeMoves(blockSequence.getBlockOrder());
                    });
                  } else {
                    print('VirtualController not loaded'); // Debug message
                  }
                },
                child: const Text('Run'),
              ),
              const SizedBox(height: 10), // Spacer
              // Area for command images
              SizedBox(
                height: 85, // Set fixed height
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8, // Number of columns in grid
                    crossAxisSpacing: 10, // Space between columns
                    mainAxisSpacing: 10, // Space between rows
                    mainAxisExtent: 85, // Height of each grid cell
                  ),
                  itemCount: commandImages.length, // Total number of command images
                  itemBuilder: (context, index) {
                    return Draggable<String>(
                      data: commandImages[index], // Data to be dragged
                      feedback: Material(
                        child: SizedBox(
                          height: 85,
                          child: Image.asset(
                            commandImages[index], // Image being dragged
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        child: Image.asset(
                          commandImages[index], // Image displayed in the grid
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10), // Spacer
              // User arrangement area
              Expanded(
                child: Container(
                  key: _stackKey,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/picGround.jpg'), // Background image
                      fit: BoxFit.cover, // Fill mode
                    ),
                  ),
                  child: Stack(
                    key: _stackKey,
                    children: [
                      // DragTarget for accepting new blocks
                      DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          setState(() {
                            final localPosition = _getLocalPosition(details.offset); // Get local position for the new block
                            arrangedCommands.add(BlockData(
                              imagePath: details.data, // Image path of the dragged block
                              position: localPosition, // Position of the block
                            ));
                            // Update block order
                            blockSequence.updateOrder(arrangedCommands);
                            blockSequence.printBlockOrder(); // Debug print of block order
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.transparent, // Transparent target area
                          );
                        },
                      ),
                      // Render placed blocks
                      ...arrangedCommands.map((block) {
                        return DraggableBlock(
                          blockData: block, // Pass the block data
                          onUpdate: _handleBlockUpdate, // Callback for block updates
                        );
                      }).toList(),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: VirtualController(
                          key: widget.virtualControllerKey, // Use passed GlobalKey
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Sidebar widget
        Sidebar(isOpen: isSidebarOpen, virtualControllerKey: widget.virtualControllerKey), // Pass key to Sidebar
        const SizedBox(height: 5), // Spacer
      ],
    ),
  );
}
}
