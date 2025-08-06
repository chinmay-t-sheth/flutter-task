import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<String> menuItems = ['Burger', 'Pizza', 'Coffee', 'Tea'];
  Map<String, bool> selectedItems = {};
  TextEditingController tableController = TextEditingController();
  String paymentMethod = 'Cash';
  String billSummary = '';

  @override
  void initState() {
    super.initState();
    for (var item in menuItems) {
      selectedItems[item] = false;
    }
  }

  void generateBill() {
    List<String> ordered = selectedItems.entries.where((e) => e.value).map((e) => e.key).toList();
    if (ordered.isEmpty || tableController.text.isEmpty) {
      setState(() => billSummary = 'Please select menu items and enter table number');
    } else {
      setState(() {
        billSummary = "Table: ${tableController.text}\nItems: ${ordered.join(', ')}\nPayment: $paymentMethod";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome Admin")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Menu Items:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...menuItems.map((item) {
                return CheckboxListTile(
                  title: Text(item),
                  value: selectedItems[item],
                  onChanged: (val) {
                    setState(() {
                      selectedItems[item] = val ?? false;
                    });
                  },
                );
              }).toList(),
              TextField(controller: tableController, decoration: InputDecoration(labelText: "Enter Table Number")),
              SizedBox(height: 10),
              Text("Payment Method:"),
              RadioListTile(value: 'Cash', groupValue: paymentMethod, title: Text("Cash"), onChanged: (val) => setState(() => paymentMethod = val!)),
              RadioListTile(value: 'Online', groupValue: paymentMethod, title: Text("Online"), onChanged: (val) => setState(() => paymentMethod = val!)),
              ElevatedButton(onPressed: generateBill, child: Text("Order")),
              SizedBox(height: 10),
              Text(billSummary, style: TextStyle(fontSize: 16, color: Colors.green)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                child: Text("Go to Dashboard"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
