import 'dart:io';

int fib(int n) {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
}

void main() {
  stdout.write("Enter number of terms: ");
  int n = int.parse(stdin.readLineSync()!);

  print("Fibonacci Series:");
  for (int i = 0; i < n; i++) {
    stdout.write("${fib(i)} ");
  }
}
