import 'dart:io';

 class BankAccount {
  final String accountHolder;
  double balance = 0;
  static double totalBankBalance = 0;

  BankAccount(this.accountHolder);

  void deposit(double amount) {
    if (amount > 0) {
      balance += amount;
      totalBankBalance += amount;
      print('₹$amount deposited.');
    } else {
      print('Invalid amount!');
    }
  }

  void withdraw(double amount) {
    if (amount > 0 && amount <= balance) {
      balance -= amount;
      totalBankBalance -= amount;
      print('₹$amount withdrawn.');
    } else {
      print('Insufficient balance or invalid amount.');
    }
  }

  void checkBalance() {
    print('Balance: ₹$balance');
  }
}

 class SavingsAccount extends BankAccount {
  SavingsAccount(String accountHolder) : super(accountHolder);
}

 class CheckingAccount extends BankAccount {
  CheckingAccount(String accountHolder) : super(accountHolder);
}

 void main() {
  print(' Welcome to Chinmay Bank ');

  stdout.write('Enter your name: ');
  String name = stdin.readLineSync()!;

  stdout.write('Choose account type (1. Savings, 2. Checking): ');
  int type = int.parse(stdin.readLineSync()!);

  BankAccount account;

  if (type == 1) {
    account = SavingsAccount(name);
  } else {
    account = CheckingAccount(name);
  }

  int choice = 0;

  while (choice != 5) {
    print('\n--- Menu ---');
    print('1. Deposit');
    print('2. Withdraw');
    print('3. Check Balance');
    print('4. Total Bank Balance');
    print('5. Exit');

    stdout.write('Enter your choice: ');
    choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        stdout.write('Enter amount to deposit: ');
        double amt = double.parse(stdin.readLineSync()!);
        account.deposit(amt);
        break;
      case 2:
        stdout.write('Enter amount to withdraw: ');
        double amt = double.parse(stdin.readLineSync()!);
        account.withdraw(amt);
        break;
      case 3:
        account.checkBalance();
        break;
      case 4:
        print('Total bank balance: ₹${BankAccount.totalBankBalance}');
        break;
      case 5:
        print('Thank you for banking with us!');
        break;
      default:
        print('Invalid choice. Try again.');
    }
  }
}
