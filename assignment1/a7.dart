import 'dart:io';

void main() {
  stdout.write("Enter a number: ");
  int num = int.parse(stdin.readLineSync()!);

  if (num < 2) {
    print("$num is not prime.");
    return;
  }

  bool isPrime = true;
  for (int i = 2; i <= num ~/ 2; i++) {
    if (num % i == 0) {
      isPrime = false;
      break;
    }
  }

  if (isPrime) {
    print("$num is prime.");
  } else {
    print("$num is not prime.");
  }
}
