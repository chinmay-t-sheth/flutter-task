import 'dart:async';

Future<void> fetchWeather() async {
  print("Fetching weather data...");
  await Future.delayed(Duration(seconds: 2));
  print("Still waiting...");
  await Future.delayed(Duration(seconds: 2));
  print("Weather data loaded successfully!");
}

void main() async {
  await fetchWeather();
}
