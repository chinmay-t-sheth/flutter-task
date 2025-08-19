import 'dart:io';

bool isPalindrome(String s) {
  String reversed = s.split('').reversed.join();
  return s == reversed;
}

void main() {
  stdout.write("Enter a string: ");
  String input = stdin.readLineSync()!;
  if (isPalindrome(input)) {
    print("$input is a palindrome.");
  } else {
    print("$input is not a palindrome.");
  }
}
