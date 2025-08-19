void main() {
  List<int> list1 = [1, 2, 3, 4];
  List<int> list2 = [3, 4, 5, 6];
  List<int> list3 = [7, 8, 1];

  List<int> combined = [...list1, ...list2, ...list3];
  Set<int> unique = combined.toSet();
  List<int> sortedList = unique.toList()..sort();

  print("Combined unique sorted list: $sortedList");
}
