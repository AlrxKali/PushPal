import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double dotSize;
  final double spacing;
  final Color activeColor;
  final Color inactiveColor;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.dotSize = 10.0,
    this.spacing = 8.0,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  }) : assert(currentStep >= 1 && currentStep <= totalSteps);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        bool isActive = index + 1 == currentStep;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
