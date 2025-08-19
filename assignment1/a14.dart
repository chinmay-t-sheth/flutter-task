import 'dart:io';

void main() {
  stdout.write("Enter words separated by spaces: ");
  List<String> words = stdin.readLineSync()!.split(" ");

  Set<String> uniqueWords = words.toSet();
  List<String> sortedWords = uniqueWords.toList()..sort();

  print("Unique words in alphabetical order: $sortedWords");
}
