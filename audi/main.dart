import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isMusicPlaying = true; // Music is ON by default
  String musicStatus = 'Music is ON';

  @override
  void initState() {
    super.initState();
    // Start music automatically since it's ON by default
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _audioPlayer.play(AssetSource('background_music.mp3'));
        Fluttertoast.showToast(msg: 'Music started', backgroundColor: Colors.blue);
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error starting music', backgroundColor: Colors.red);
      }
    });
  }

  void toggleMusic(bool value) async {
    setState(() {
      isMusicPlaying = value;
      musicStatus = value ? 'Music is ON' : 'Music is OFF';
    });
    try {
      if (value) {
        await _audioPlayer.play(AssetSource('background_music.mp3'));
        Fluttertoast.showToast(msg: 'Music started', backgroundColor: Colors.blue);
      } else {
        await _audioPlayer.stop();
        Fluttertoast.showToast(msg: 'Music stopped', backgroundColor: Colors.blue);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error toggling music', backgroundColor: Colors.red);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audi Cars App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(
        toggleMusic: toggleMusic,
        isMusicPlaying: isMusicPlaying,
        musicStatus: musicStatus,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final Function(bool) toggleMusic;
  final bool isMusicPlaying;
  final String musicStatus;

  SplashScreen({
    required this.toggleMusic,
    required this.isMusicPlaying,
    required this.musicStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/splash_screen.png'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Click to proceed forward'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminScreen(
                      toggleMusic: toggleMusic,
                      isMusicPlaying: isMusicPlaying,
                      musicStatus: musicStatus,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CarProduct {
  final String imagePath;
  final String name;
  final String subtitle;
  final double price;

  CarProduct({
    required this.imagePath,
    required this.name,
    required this.subtitle,
    required this.price,
  });
}

class AdminScreen extends StatefulWidget {
  final Function(bool) toggleMusic;
  final bool isMusicPlaying;
  final String musicStatus;

  AdminScreen({
    required this.toggleMusic,
    required this.isMusicPlaying,
    required this.musicStatus,
  });

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<CarProduct> cars = [
    CarProduct(
        imagePath: 'assets/car1.jpg',
        name: 'Audi RS7 Sportback',
        subtitle: 'High-performance luxury coupe',
        price: 120000.00),
    CarProduct(
        imagePath: 'assets/car2.jpg',
        name: 'Audi RS e-tron GT',
        subtitle: 'Electric grand tourer',
        price: 140000.00),
    CarProduct(
        imagePath: 'assets/car3.webp',
        name: 'Audi A4',
        subtitle: 'Compact executive sedan',
        price: 45000.00),
    CarProduct(
        imagePath: 'assets/car4.webp',
        name: 'Audi PB18 e-tron',
        subtitle: 'Electric supercar concept',
        price: 200000.00),
    CarProduct(
        imagePath: 'assets/car5.jpg',
        name: 'Audi RS Q8',
        subtitle: 'Performance SUV coupe',
        price: 130000.00),
    CarProduct(
        imagePath: 'assets/car8.jpg',
        name: 'Audi skysphere',
        subtitle: 'Convertible concept car',
        price: 180000.00),
  ];

  late List<int> quantities;
  List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    quantities = List.filled(cars.length, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Welcome to Admin Screen'),
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    });
  }

  void addToCart(int index, int quantity) {
    if (quantity > 0) {
      setState(() {
        cart.add({
          'name': cars[index].name,
          'quantity': quantity,
          'subtitle': cars[index].subtitle,
          'price': cars[index].price,
        });
        quantities[index] = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${cars[index].name} x $quantity to cart')),
      );
    }
  }

  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cart: cart),
      ),
    );
  }

  void navigateToDetailScreen(CarProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          toggleMusic: widget.toggleMusic,
          initialIsMusicPlaying: widget.isMusicPlaying,
          initialMusicStatus: widget.musicStatus,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: cart.isEmpty ? null : navigateToCart,
          ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              navigateToCart();
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              navigateToSettings();
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => navigateToDetailScreen(cars[index]),
                    child: Image.asset(
                      cars[index].imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    cars[index].name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    cars[index].subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (quantities[index] > 0) {
                                setState(() {
                                  quantities[index]--;
                                });
                              }
                            },
                          ),
                          Text(quantities[index].toString()),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantities[index]++;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                '\$${cars[index].price.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text('Add to Cart'),
                          onPressed: () => addToCart(index, quantities[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final Function(bool) toggleMusic;
  final bool initialIsMusicPlaying;
  final String initialMusicStatus;

  SettingsScreen({
    required this.toggleMusic,
    required this.initialIsMusicPlaying,
    required this.initialMusicStatus,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isMusicPlaying;
  late String musicStatus;

  @override
  void initState() {
    super.initState();
    isMusicPlaying = widget.initialIsMusicPlaying;
    musicStatus = widget.initialMusicStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Music Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  musicStatus,
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: isMusicPlaying,
                  onChanged: (value) {
                    widget.toggleMusic(value);
                    setState(() {
                      isMusicPlaying = value;
                      musicStatus = value ? 'Music is ON' : 'Music is OFF';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final CarProduct product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                product.imagePath,
                fit: BoxFit.cover,
                height: 300,
              ),
              SizedBox(height: 20),
              Text(
                product.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                product.subtitle,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                'Price: \$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 20),
              Text(
                'Specifications:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildSpecItem('Engine', 'V8 Twin-Turbo'),
              _buildSpecItem('Horsepower', '621 hp'),
              _buildSpecItem('Transmission', '8-speed Automatic'),
              _buildSpecItem('0-60 mph', '3.5 seconds'),
              _buildSpecItem('Top Speed', '190 mph'),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Back to Products'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;

  CartScreen({required this.cart});

  double _calculateTotalPrice() {
    return cart.fold(0.0, (total, item) =>
    total + (item['price'] as double) * (item['quantity'] as int));
  }

  void _showOrderDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...cart.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${item['name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Quantity: ${item['quantity']}'),
                      Text('Unit Price: \$${item['price'].toStringAsFixed(2)}'),
                      Text(
                        'Subtotal: \$${((item['price'] as double) * (item['quantity'] as int)).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 10),
              Text(
                'Total: \$${_calculateTotalPrice().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? Center(child: Text('Cart is empty'))
                : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text(cart[index]['name']),
                    subtitle: Text(cart[index]['subtitle']),
                    trailing: Text(
                        'Qty: ${cart[index]['quantity']} - \$${cart[index]['price']}'),
                  ),
                );
              },
            ),
          ),
          if (cart.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                child: Text('Buy'),
                onPressed: () => _showOrderDetails(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
