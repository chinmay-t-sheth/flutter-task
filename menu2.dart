import 'dart:io';

 class MenuItem {
  final String name;
  final int price;
  static int totalSales = 0;

  MenuItem(this.name, this.price);

  void orderItem() {
    print('Ordered: $name - ₹$price');
    totalSales += price;
  }
}

 class Food extends MenuItem {
  Food(String name, int price) : super(name, price);
}

 class Drink extends MenuItem {
  Drink(String name, int price) : super(name, price);
}

 void main() {
  List<MenuItem> menu = [
    Food('Sandwich', 100),
    Food('Burger', 150),
    Drink('Coffee', 80),
    Drink('Juice', 60),
  ];

  List<MenuItem> cart = [];
  bool ordering = true;

  while (ordering) {
    print('\n Cafe Menu');
    for (int i = 0; i < menu.length; i++) {
      print('${i + 1}. ${menu[i].name} - ₹${menu[i].price}');
    }
    print('0. Finish Order');

    stdout.write('Enter item number: ');
    String? input = stdin.readLineSync();

    switch (input) {
      case '1':
      case '2':
      case '3':
      case '4':
        int index = int.parse(input!) - 1;
        MenuItem selected = menu[index];

         if (selected is Drink) {
          int discountedPrice = (selected.price * 0.9).toInt();
          print('10% discount on drinks applied!');
          Drink discountedDrink = Drink(selected.name, discountedPrice);
          discountedDrink.orderItem();
          cart.add(discountedDrink);
        } else {
          selected.orderItem();
          cart.add(selected);
        }
        break;

      case '0':
        ordering = false;
        break;

      default:
        print('Invalid input. Try again.');
    }
  }

   print('\n Final Bill');
  int total = 0;
  for (var item in cart) {
    print('${item.name} - ₹${item.price}');
    total += item.price;
  }
  print('Total Bill: ₹$total');
  print('Total Cafe Sales (All Orders): ₹${MenuItem.totalSales}');
}
