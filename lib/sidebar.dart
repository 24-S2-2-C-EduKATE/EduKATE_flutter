import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final bool isOpen;

  const Sidebar({Key? key, required this.isOpen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isOpen ? 150 : 0, // 控制侧边栏宽度
      child: Container(
        color: const Color.fromARGB(255, 255, 243, 192), // 侧边栏背景色
        // 侧边栏内容可以放在这里
      ),
    );
  }
}