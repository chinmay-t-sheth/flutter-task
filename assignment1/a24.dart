import 'dart:io';

void main() {
  stdout.write("Enter integers separated by spaces: ");
  String input = stdin.readLineSync()!;
  List<int> numbers = [];

  try {
    numbers = input.split(' ').map((e) => int.parse(e)).toList();
    print("You entered: $numbers");
  } on FormatException {
    print("Error: Please enter only integers.");
  } catch (e) {
    print("Error: $e");
  }
}
