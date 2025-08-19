import 'dart:io';
import 'dart:math';

void main() {
  int target = Random().nextInt(100) + 1;
  Function(int) hint = (guess) {
    if (guess > target) return "Too high!";
    if (guess < target) return "Too low!";
    return "Correct!";
  };

  print("Guess a number between 1 and 100");

  while (true) {
    stdout.write("Enter your guess: ");
    int guess = int.parse(stdin.readLineSync()!);

    String result = hint(guess);
    print(result);

    if (result == "Correct!") break;
  }
}
