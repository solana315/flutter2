import 'package:flutter/material.dart';

class SheetContainer extends StatelessWidget {
  final double height;
  final Widget child;

  const SheetContainer({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.92),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF7F4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: child,
        ),
      ),
    );
  }
}
