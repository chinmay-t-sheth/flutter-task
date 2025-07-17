import 'dart:io';

void main() {
 
  stdout.write('Enter username: ');
  String username = stdin.readLineSync()!;
  stdout.write('Enter password: ');
  String password = stdin.readLineSync()!;

  if (username != 'tops' || password != '1234') {
    print('Invalid login.');
    return;
  }

 
  print('\n--- MENU ---');
  print('1. Pizza - ₹100');
  print('2. Burger - ₹120');
  print('3. Fries - ₹80');
  print('4. Sandwich - ₹90');
  print('5. Coffee - ₹70');
  print('6. Cold Drink - ₹60');
  print('Type 0 to finish your order.\n');

 
  List<String> orderList = [];
  int total = 0;
  String billText = '';

  while (true) {
    stdout.write('Enter item number (0 to finish): ');
    String input = stdin.readLineSync()!;

    if (input == '0') break;

    switch (input.trim()) {
      case '1':
        orderList.add('Pizza - ₹100');
        total += 100;
        break;
      case '2':
        orderList.add('Burger - ₹120');
        total += 120;
        break;
      case '3':
        orderList.add('Fries - ₹80');
        total += 80;
        break;
      case '4':
        orderList.add('Sandwich - ₹90');
        total += 90;
        break;
      case '5':
        orderList.add('Coffee - ₹70');
        total += 70;
        break;
      case '6':
        orderList.add('Cold Drink - ₹60');
        total += 60;
        break;
      default:
        print('Invalid item number.');
    }
  }

 
  print('\n--- FINAL BILL ---');
  print('Table No: 12');
  for (var item in orderList) {
    print(item);
    billText += '$item\n';
  }
  print('Total: ₹$total');

 
  File file = File('bill.txt');
  file.writeAsStringSync('Table No: 12\n$billText\nTotal: ₹$total');

  print('\n✅ Bill saved to bill.txt');
}
