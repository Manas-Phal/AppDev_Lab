import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOperator = ["+", "-", "×", "÷", "%", "=", "√", "x²"].contains(text);
    final isClear = (text == "C" || text == "D");

    Color buttonColor;
    if (isOperator) {
      buttonColor = Theme.of(context).primaryColor;
    } else if (isClear) {
      buttonColor = Colors.blueGrey;
    } else {
      buttonColor = Colors.grey.shade900;
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(22),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

