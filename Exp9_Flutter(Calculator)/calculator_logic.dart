import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  static String evaluate(String expression) {
    try {
      // ✅ Replace display symbols with math_expressions equivalents
      expression = expression
          .replaceAll("×", "*")
          .replaceAll("÷", "/")
          .replaceAll("x²", "^2")
          .replaceAll("√x", "sqrt");

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval.toString();
    } catch (e) {
      return "Error";
    }
  }
}



