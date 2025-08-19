import 'dart:io';

void main() {
  String fileName = "example.txt";

  try {
    // Write to file
    File file = File(fileName);
    file.writeAsStringSync("Hello, Dart File Handling!");

    // Read back
    String contents = file.readAsStringSync();
    print("File Contents: $contents");
  } on FileSystemException catch (e) {
    print("File error: $e");
  } catch (e) {
    print("Error: $e");
  }
}
