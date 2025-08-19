class Product {
  String name;
  double price;

  Product(this.name, this.price);
}

class Cart {
  List<Product> items = [];

  void addProduct(Product p) {
    items.add(p);
    print("${p.name} added to cart.");
  }

  double totalPrice() {
    return items.fold(0, (sum, item) => sum + item.price);
  }
}

class Order {
  Cart cart;
  Order(this.cart);

  void checkout() {
    print("Order placed. Total: ₹${cart.totalPrice()}");
  }
}

void main() {
  Product p1 = Product("Laptop", 60000);
  Product p2 = Product("Mouse", 800);

  Cart myCart = Cart();
  myCart.addProduct(p1);
  myCart.addProduct(p2);

  Order order = Order(myCart);
  order.checkout();
}
