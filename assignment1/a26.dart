import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    var url = Uri.parse("https://jsonplaceholder.typicode.com/posts/1");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Data fetched: $data");
    } else {
      print("Failed to fetch data. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching data: $e");
  }
}
