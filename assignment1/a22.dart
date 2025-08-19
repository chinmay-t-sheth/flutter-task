import 'dart:io';

void main() {
  stdout.write("Enter file path: ");
  String path = stdin.readLineSync()!;

  try {
    File file = File(path);
    String contents = file.readAsStringSync();
    print("File Contents:\n$contents");
  } on FileSystemException {
    print("Error: File not found.");
  } catch (e) {
    print("Error: $e");
  }
}
