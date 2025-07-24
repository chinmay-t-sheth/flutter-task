import 'dart:io';

void main() {
  // Ask for user's name
  print('Enter your name:');
  String? name = stdin.readLineSync();

  // Ask for user's age and parse it on the same line
  print('Enter your age:');
  int age = int.parse(stdin.readLineSync()!);

  // Calculate years left until 100
  int yearsLeft = 100 - age;

  // Print welcome message
  print('Hello, $name! You have $yearsLeft years left until you turn 100.');
}
