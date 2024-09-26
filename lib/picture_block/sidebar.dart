import 'package:flutter/material.dart';
import 'virtual_controller.dart';


class Sidebar extends StatelessWidget {

  final GlobalKey<VirtualControllerState> virtualControllerKey;
  final bool isOpen;

  // 单一的构造函数传递 isOpen 和 GlobalKey
  Sidebar({
    required this.isOpen,
    required this.virtualControllerKey,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // Using AnimatedContainer for animation effect
      duration: Duration(milliseconds: 300), // Animation duration
      width: isOpen ? 300 : 0, // Width is 300 if open, 0 if closed
      child: Drawer(
        child: isOpen
            ? Column(
                // If sidebar is open, show a Column
                children: [
                  Expanded(
                    child: VirtualController(
                      key: virtualControllerKey, // 使用传入的 GlobalKey
                    ), // VirtualController fills the available space
                  ),
                ],
              )
            : null, // If sidebar is closed, show nothing
      ),
    );
  }
}
