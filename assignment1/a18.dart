class BankAccount {
  String accountNumber;
  String holder;
  double balance;

  BankAccount(this.accountNumber, this.holder, this.balance);

  void deposit(double amount) {
    balance += amount;
    print("Deposited ₹$amount. New Balance: ₹$balance");
  }

  void withdraw(double amount) {
    if (amount > balance) {
      print("Insufficient funds. Withdrawal denied.");
    } else {
      balance -= amount;
      print("Withdrew ₹$amount. New Balance: ₹$balance");
    }
  }

  void checkBalance() {
    print("Balance: ₹$balance");
  }
}

void main() {
  BankAccount acc = BankAccount("12345", "Chinmay Sheth", 5000);
  acc.checkBalance();
  acc.deposit(2000);
  acc.withdraw(1000);
  acc.withdraw(7000);
}
