import 'dart:io';

void main() {
  Map<String, String> addressBook = {};

  while (true) {
    print("\n1. Add Entry\n2. Update Entry\n3. Remove Entry\n4. View All\n5. Exit");
    stdout.write("Choose an option: ");
    int choice = int.parse(stdin.readLineSync()!);

    if (choice == 1) {
      stdout.write("Enter name: ");
      String name = stdin.readLineSync()!;
      stdout.write("Enter phone number: ");
      String phone = stdin.readLineSync()!;
      addressBook[name] = phone;
    } else if (choice == 2) {
      stdout.write("Enter name to update: ");
      String name = stdin.readLineSync()!;
      if (addressBook.containsKey(name)) {
        stdout.write("Enter new phone number: ");
        String phone = stdin.readLineSync()!;
        addressBook[name] = phone;
      } else {
        print("Name not found.");
      }
    } else if (choice == 3) {
      stdout.write("Enter name to remove: ");
      String name = stdin.readLineSync()!;
      addressBook.remove(name);
    } else if (choice == 4) {
      print("Address Book: $addressBook");
    } else if (choice == 5) {
      break;
    } else {
      print("Invalid choice.");
    }
  }
}
