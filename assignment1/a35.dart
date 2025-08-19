import 'package:path/path.dart' as p;

void main() {
  String filePath = "/home/user/documents/report.pdf";

  print("Directory: ${p.dirname(filePath)}");
  print("File name: ${p.basename(filePath)}");
  print("Extension: ${p.extension(filePath)}");
}
