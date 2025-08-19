class Vehicle {
  String type;
  String fuel;
  int maxSpeed;

  Vehicle(this.type, this.fuel, this.maxSpeed);

  void displayInfo() {
    print("Type: $type, Fuel: $fuel, Max Speed: $maxSpeed km/h");
  }
}

class Car extends Vehicle {
  Car(String fuel, int maxSpeed) : super("Car", fuel, maxSpeed);
}

class Bike extends Vehicle {
  Bike(String fuel, int maxSpeed) : super("Bike", fuel, maxSpeed);
}

void main() {
  Car c = Car("Petrol", 220);
  Bike b = Bike("Electric", 120);

  c.displayInfo();
  b.displayInfo();
}
