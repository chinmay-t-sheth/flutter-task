import 'dart:io';

List<int> sortAscending(List<int> list) {
  for (int i = 0; i < list.length; i++) {
    for (int j = i + 1; j < list.length; j++) {
      if (list[j] < list[i]) {
        int temp = list[i];
        list[i] = list[j];
        list[j] = temp;
      }
    }
  }
  return list;
}

List<int> sortDescending(List<int> list) {
  for (int i = 0; i < list.length; i++) {
    for (int j = i + 1; j < list.length; j++) {
      if (list[j] > list[i]) {
        int temp = list[i];
        list[i] = list[j];
        list[j] = temp;
      }
    }
  }
  return list;
}

void main() {
  stdout.write("Enter integers separated by spaces: ");
  List<int> numbers = stdin.readLineSync()!
      .split(" ")
      .map((e) => int.parse(e))
      .toList();

  print("Ascending: ${sortAscending([...numbers])}");
  print("Descending: ${sortDescending([...numbers])}");
}
