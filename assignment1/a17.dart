class Book {
  String title;
  String author;
  int year;

  Book(this.title, this.author, this.year);

  void displayDetails() {
    print("Title: $title, Author: $author, Year: $year");
  }

  bool isOlderThan10Years() {
    int currentYear = DateTime.now().year;
    return (currentYear - year) > 10;
  }
}

void main() {
  Book b1 = Book("1984", "George Orwell", 1949);
  b1.displayDetails();
  print("Is older than 10 years? ${b1.isOlderThan10Years()}");
}
