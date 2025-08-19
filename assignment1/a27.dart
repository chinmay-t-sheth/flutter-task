import 'dart:async';

Future<String> fetchData(int id) async {
  await Future.delayed(Duration(seconds: 1));
  return "Data point $id loaded";
}

void main() async {
  print("Fetching data...");

  List<String> results = [];
  for (int i = 1; i <= 5; i++) {
    String data = await fetchData(i);
    results.add(data);
  }

  print("All data loaded: $results");
}
