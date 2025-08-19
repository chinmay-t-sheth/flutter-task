import 'dart:io';

Map<String, int> findLargestSmallest(List<int> numbers) {
  int largest = numbers[0];
  int smallest = numbers[0];

  for (var num in numbers) {
    if (num > largest) largest = num;
    if (num < smallest) smallest = num;
  }

  return {"largest": largest, "smallest": smallest};
}

void main() {
  stdout.write("Enter numbers separated by spaces: ");
  List<int> nums = stdin.readLineSync()!
      .split(' ')
      .map((e) => int.parse(e))
      .toList();

  var result = findLargestSmallest(nums);
  print("Largest: ${result['largest']}, Smallest: ${result['smallest']}");
}
