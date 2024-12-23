import 'package:flutter/material.dart';

class Testtransaksi extends StatefulWidget {
  const Testtransaksi({super.key});

  @override
  State<Testtransaksi> createState() => _TesttransaksiState();
}

class _TesttransaksiState extends State<Testtransaksi> {
  final Map<String, List<Map<String, dynamic>>> categories = {
    'Baju': [
      {'name': 'Baju Polos', 'price': 100000},
      {'name': 'Baju Batik', 'price': 150000},
      {'name': 'Baju Kemeja', 'price': 200000},
    ],
    'Kaos': [
      {'name': 'Kaos Polos', 'price': 80000},
      {'name': 'Kaos Lengan Panjang', 'price': 90000},
      {'name': 'Kaos Band', 'price': 95000},
    ],
    'Celana': [
      {'name': 'Celana Jeans', 'price': 120000},
      {'name': 'Celana Pendek', 'price': 70000},
      {'name': 'Celana Chino', 'price': 130000},
    ],
    'Sepatu': [
      {'name': 'Sepatu Sneakers', 'price': 250000},
      {'name': 'Sepatu Boots', 'price': 300000},
      {'name': 'Sepatu Lari', 'price': 220000},
    ],
    'Sandal': [
      {'name': 'Sandal Jepit', 'price': 50000},
      {'name': 'Sandal Gunung', 'price': 85000},
      {'name': 'Sandal Kulit', 'price': 150000},
    ],
  };

  // Kategori yang dipilih
  Map<String, bool> selectedCategories = {};
  Map<Map<String, dynamic>, bool> selectedProducts = {};
  int totalAmount = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Inisialisasi semua kategori dengan status tidak dipilih (false)
    categories.forEach((category, products) {
      selectedCategories[category] = false;
      products.forEach((product) {
        selectedProducts[product] = false;
      });
    });
  }

  // Fungsi untuk memperbarui total harga saat produk dipilih atau tidak dipilih
  void _updateTotalAmount() {
    setState(() {
      totalAmount = selectedProducts.entries
          .where((entry) => entry.value == true)
          .fold(0,
              (sum, entry) => sum + int.parse(entry.key['price'].toString()));
    });
  }

  // Fungsi untuk mendapatkan produk berdasarkan kategori yang dipilih
  List<Map<String, dynamic>> _getFilteredProducts() {
    List<Map<String, dynamic>> filteredProducts = [];

    // Jika tidak ada kategori yang dipilih, tampilkan semua produk
    if (selectedCategories.values.every((isSelected) => !isSelected)) {
      categories.forEach((category, products) {
        filteredProducts.addAll(products);
      });
    } else {
      // Jika ada kategori yang dipilih, tampilkan produk dalam kategori tersebut
      selectedCategories.forEach((category, isSelected) {
        if (isSelected) {
          filteredProducts.addAll(categories[category]!);
        }
      });
    }
    if (searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) =>
              product['name'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProducts = _getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori Filter
            Wrap(
              spacing: 10.0,
              children: categories.keys.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: selectedCategories[category]!,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedCategories[category] = selected;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Cari Barang',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
            SizedBox(height: 20),

            // Produk Berdasarkan Filter dan Pencarian
            Expanded(
              child: ListView(
                children: filteredProducts.map((product) {
                  return FilterChip(
                    label: Text('${product['name']} - Rp ${product['price']}'),
                    selected: selectedProducts[product]!,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedProducts[product] = selected;
                        _updateTotalAmount();
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // Total Harga
            Text('Total Harga: Rp $totalAmount'),
            SizedBox(height: 20),

            // Tombol Checkout
            ElevatedButton(
              onPressed: () {
                List<Map<String, dynamic>> selectedItems = selectedProducts
                    .entries
                    .where((entry) => entry.value == true)
                    .map((entry) => entry.key)
                    .toList();

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         CheckoutPage(selectedProducts: selectedItems),
                //   ),
                // );
              },
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
