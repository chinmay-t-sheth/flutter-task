import 'dart:io';

void main() {
  stdout.write("Enter first number: ");
  double num1 = double.parse(stdin.readLineSync()!);

  stdout.write("Enter operator (+, -, *, /): ");
  String op = stdin.readLineSync()!;

  stdout.write("Enter second number: ");
  double num2 = double.parse(stdin.readLineSync()!);

  double result;

  switch (op) {
    case '+':
      result = num1 + num2;
      break;
    case '-':
      result = num1 - num2;
      break;
    case '*':
      result = num1 * num2;
      break;
    case '/':
      if (num2 == 0) {
        print("Error: Division by zero");
        return;
      }
      result = num1 / num2;
      break;
    default:
      print("Invalid operator");
      return;
  }

  print("Result: $result");
}
