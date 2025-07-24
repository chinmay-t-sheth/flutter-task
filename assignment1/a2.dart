import 'dart:io';

// Function to convert Celsius to Fahrenheit
double celsiusToFahrenheit(double celsius) {
  return (celsius * 9 / 5) + 32;
}

// Function to convert Fahrenheit to Celsius
double fahrenheitToCelsius(double fahrenheit) {
  return (fahrenheit - 32) * 5 / 9;
}

void main() {
  print('Choose conversion type:');
  print('1. Celsius to Fahrenheit');
  print('2. Fahrenheit to Celsius');
  String? choice = stdin.readLineSync();

  if (choice == '1') {
    print('Enter temperature in Celsius:');
    double celsius = double.parse(stdin.readLineSync()!);
    double fahrenheit = celsiusToFahrenheit(celsius);
    print('$celsius°C is equal to ${fahrenheit.toStringAsFixed(2)}°F');
  } else if (choice == '2') {
    print('Enter temperature in Fahrenheit:');
    double fahrenheit = double.parse(stdin.readLineSync()!);
    double celsius = fahrenheitToCelsius(fahrenheit);
    print('$fahrenheit°F is equal to ${celsius.toStringAsFixed(2)}°C');
  } else {
    print('Invalid choice. Please enter 1 or 2.');
  }
}
