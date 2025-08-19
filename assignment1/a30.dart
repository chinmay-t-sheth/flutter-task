List<int> processList(List<int> numbers, int Function(int) operation) {
  return numbers.map(operation).toList();
}

void main() {
  List<int> nums = [1, 2, 3, 4, 5];

  List<int> squares = processList(nums, (n) => n * n);
  List<int> cubes = processList(nums, (n) => n * n * n);
  List<int> halves = processList(nums, (n) => (n / 2).round());

  print("Squares: $squares");
  print("Cubes: $cubes");
  print("Halves: $halves");
}
