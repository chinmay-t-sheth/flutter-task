import 'dart:io';

void main() {
 
  stdout.write('Enter username: ');
  String username = stdin.readLineSync()!;
  stdout.write('Enter password: ');
  String password = stdin.readLineSync()!;

  if (username == 'tops' && password == '1234') {
    print('\nLogin successful!\n');
  } else {
    print('Invalid credentials.');
    return;
  }

   print('--- Menu ---');
  print('1. Pizza - ₹100');
  print('2. Burger - ₹120');
  print('3. Fries - ₹80');
  print('4. Sandwich - ₹90');
  print('5. Coffee - ₹70');
  print('6. Cold Drink - ₹60');

 
  stdout.write('\nEnter your order (e.g., 1,3,5): ');
  String orderInput = stdin.readLineSync()!;
  List<String> orders = orderInput.split(',');

  int total = 0;

   for (var item in orders) {
    switch (item.trim()) {
      case '1':
        total += 100;
        break;
      case '2':
        total += 120;
        break;
      case '3':
        total += 80;
        break;
      case '4':
        total += 90;
        break;
      case '5':
        total += 70;
        break;
      case '6':
        total += 60;
        break;
      default:
        print('Invalid item: $item');
    }
  }

  print('\nTotal Bill: ₹$total');
  print('Table No: 12');

   File file = File('bill.txt');
  file.writeAsStringSync('Table No: 12\nTotal Bill: ₹$total');
  print('\nSaved to bill.txt');
}
