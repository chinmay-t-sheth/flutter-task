import 'dart:io';

void main() {
  // Define constant value for pi
  const double pi = 3.14159;

  // Ask user to enter the radius
  print('Enter the radius of the circle:');
  double radius = double.parse(stdin.readLineSync()!);

  // Calculate area and circumference
  double area = pi * radius * radius;
  double circumference = 2 * pi * radius;

  // Display results
  print('Area of the circle: ${area.toStringAsFixed(2)}');
  print('Circumference of the circle: ${circumference.toStringAsFixed(2)}');
}
