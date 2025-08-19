import 'dart:io';

void main() {
  stdout.write("Enter student score (0–100): ");
  int score = int.parse(stdin.readLineSync()!);

  if (score >= 90 && score <= 100) {
    print("Grade: A");
  } else if (score >= 80) {
    print("Grade: B");
  } else if (score >= 70) {
    print("Grade: C");
  } else if (score >= 60) {
    print("Grade: D");
  } else {
    print("Grade: F");
  }
}
