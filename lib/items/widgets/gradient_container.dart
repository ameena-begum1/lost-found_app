import 'package:flutter/material.dart';

const startAlignment = Alignment.topLeft;
const endAlignment = Alignment.bottomRight;

class GradientContainer extends StatelessWidget {
  final List<Color> colors;
  final Widget child; // Add child

  const GradientContainer({
    super.key,
    required this.colors,
    required this.child, // Accept child
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity, 
        height: double.infinity, 
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: startAlignment,
            end: endAlignment,
          ),
        ),
        child: child, 
      ),
    );
  }
}
