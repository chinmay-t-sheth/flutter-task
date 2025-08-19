import 'dart:io';

void main() {
  stdout.write("Enter a string: ");
  String input = stdin.readLineSync()!;

  Map<String, int> freq = {};

  for (var char in input.split('')) {
    freq[char] = (freq[char] ?? 0) + 1;
  }

  print("Character frequencies: $freq");
}
