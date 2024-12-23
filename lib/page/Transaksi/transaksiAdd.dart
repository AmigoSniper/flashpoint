import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:salescheck/component/filterChip.dart';
import 'package:salescheck/component/searchBar.dart';

import 'package:salescheck/page/Transaksi/detailTransaksi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/category.dart';
import '../../Model/product.dart';
import '../../Model/selectedProduct.dart';
import '../../Service/ApiCategory.dart';
import '../../Service/ApiProduct.dart';
import '../../component/customButtonColor.dart';
import '../../component/customButtonPrimary.dart';

class Transaksiadd extends StatefulWidget {
  final String outlateName;
  const Transaksiadd({super.key, required this.outlateName});

  @override
  State<Transaksiadd> createState() => _TransaksiaddState();
}

class _TransaksiaddState extends State<Transaksiadd> {
  final Apicategory _api = new Apicategory();
  final Apiproduct _apiProduct = new Apiproduct();
  int id_Outlet = 0;
  List<Category> categoryOption = [];
  List<Product> productList = [];
  List<Product> productListFilter = [];
  late Future<void> _loadDataFuture;
  final ScrollController _scrollControllerCategory = new ScrollController();
  final ScrollController _scrollController = new ScrollController();
  final ScrollController _scrollControllerbarang = new ScrollController();
  final TextEditingController _searchControler = new TextEditingController();
  final numberFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  bool isGalerry = false;
  File? _image;

  // Kategori yang dipilih
  Map<String, bool> selectedCategories = {};
  Map<int, bool> selectedProducts = {};
  Map<int, int> quantityProduct = {};
  List<Map<String, dynamic>> displayedProducts = [];
  int totalAmount = 0;
  int totalBarang = 0;
  String searchQuery = '';
  Future<void> _readAndPrintCategoryData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int idOutlet = prefs.getInt('id_outlet') ?? 0;
    print('Get api category');

    // Ambil kategori dari API
    categoryOption = await _api.getCategory();
    print('Panjang sebelum filter = ${categoryOption.length}');

    if (_api.statusCode == 200) {
      // Pastikan data kategori tidak kosong
      print('ID Outlet = ${idOutlet}');

      if (categoryOption.isNotEmpty) {
        setState(() {
          // Filter kategori yang memiliki produk pada outlet yang sesuai
          categoryOption = categoryOption.where((category) {
            // Cek apakah outlet memiliki produk terkait
            return category.productOutlet
                    ?.any((product) => product.outletId == idOutlet) ??
                false;
          }).toList();

          print('Jumlah kategori setelah filter = ${categoryOption.length}');
        });

        print('Ke produk');

        // Untuk setiap kategori yang tersisa, ambil produk terkait
        for (var category in categoryOption) {
          await _readAndPrintProductData(category.idKategori ?? 0);
        }
      } else {
        print('Tidak ada kategori yang diterima dari API');
      }
    } else {
      print('Error: ${_api.message}');
    }
  }

  Future<void> _readAndPrintProductData(int categoryId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int idOutlet = prefs.getInt('id_outlet') ?? 0;

    // Ambil produk berdasarkan outlet dan kategori
    productList = await _apiProduct.getProductsByOutletAndCategory(
      outletId: idOutlet,
      categoryId: categoryId,
    );
    print('_readAndPrintProductData productList = ${productList.length}');
    if (_apiProduct.statusCode == 200) {
      setState(() {
        // Perbarui daftar produk
        productList.sort((a, b) {
          String statusA = a.status ?? "Produk Tidak Aktif";
          String statusB = b.status ?? "Produk Tidak Aktif";

          if (statusA != statusB) {
            return statusA == "Produk Aktif" ? -1 : 1;
          }
          String nameA = a.productName?.toLowerCase() ?? "";
          String nameB = b.productName?.toLowerCase() ?? "";

          return nameA.compareTo(nameB);
        });
        productListFilter = productList
            .where((product) =>
                product.detailCategories!.first.categoriesId != null &&
                product.detailCategories!.first.categoriesId == categoryId &&
                product.detailOutlets!.first.outletsId == id_Outlet)
            .toList();

        id_Outlet = idOutlet;
      });
      print('Panjang Product iniliasiasi = ${productListFilter.length}');
    } else {
      print('Error _readAndPrintProductData: ${_apiProduct.message}');
    }
  }

//Method Mengurutkan Nama
  void sortProductsByActive() {
    productListFilter.sort((a, b) {
      if (a.status == b.status) return 0;
      return a.status == 'active' ? -1 : 1;
    });
  }

// Mendapatkan detail produk berdasarkan nama
  Product? _getProductDetailById(int productid) {
    for (var product in productList) {
      if (product.productId == productid) {
        return product; // Mengembalikan objek Product
      }
    }
    return null; // Jika produk tidak ditemukan, kembalikan null
  }

  // Fungsi untuk memperbarui total harga saat produk dipilih atau tidak dipilih
  void _updateTotalAmount() {
    setState(() {
      totalAmount = quantityProduct.entries.fold(0, (sum, entry) {
        // Ambil detail produk berdasarkan nama produk (key)
        var productDetail = _getProductDetailById(entry.key);

        // Kalikan harga produk dengan jumlah yang dipilih
        int productPrice = productDetail?.price ?? 0;
        int quantity = entry.value; // Jumlah produk yang dipilih

        // Tambahkan ke total
        return sum + (productPrice * quantity);
      });
    });
    print(totalAmount);
  }

  // Function untuk menghitung total barang dari semua kategori
  int _getTotalItems() {
    List<Product> filteredProducts = [];
    filteredProducts.addAll(productList.where(
        (product) => product.detailOutlets!.first.outletsId == id_Outlet));

    return filteredProducts.length;
  }

// Function untuk menghitung total barang dalam satu kategori dan outlet
  int _getTotalItemsInCategory(Category category) {
    // Menyaring produk berdasarkan kategori yang sesuai dan outlet yang sesuai
    var filtered = productList.where((prod) {
      // Memeriksa apakah produk termasuk dalam kategori yang benar
      // dan produk tersebut ada di outlet yang sesuai
      return prod.categoryNames == category.namaKategori &&
          category.productOutlet!.any((outlet) =>
              outlet.outletId == id_Outlet &&
              outlet.productId == prod.productId);
    }).toList();

    // Mengembalikan jumlah item yang difilter berdasarkan kategori dan outlet
    return filtered.length;
  }

  // Function untuk menampilkan produk berdasarkan kategori dan query pencarian
  List<Product> _getFilteredProducts() {
    List<Product> filteredProducts = [];

    // Cek apakah kategori "Semua" dipilih
    if (selectedCategories['Semua'] == true) {
      // Jika "Semua" dipilih, tampilkan semua produk
      filteredProducts.addAll(productList.where((product) =>
          product.detailOutlets!.first.outletsId == id_Outlet &&
          product.status == 'Produk Aktif'));
    } else if (selectedCategories.values.every((isSelected) => !isSelected)) {
      // Jika tidak ada kategori yang dipilih, tampilkan semua produk
      filteredProducts.addAll(productList);
    } else {
      // Jika ada kategori yang dipilih selain "Semua"
      selectedCategories.forEach((category, isSelected) {
        if (isSelected && category != 'Semua') {
          // Menambahkan produk sesuai kategori yang dipilih
          filteredProducts.addAll(productList.where((product) =>
              product.categoryNames == category &&
              product.status == 'Produk Aktif' &&
              product.detailOutlets!.first.outletsId == id_Outlet));
        }
      });
    }

    // Filter berdasarkan kata kunci pencarian jika ada
    if (searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) => product.productName!
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filteredProducts;
  }

  // Mengambil jumlah barang terpilih untuk produk
  int getQuantity(int productID) {
    return quantityProduct[productID] ?? 0;
  }

// Menambah jumlah barang (dengan batas maksimal stok)
  void incrementQuantity(Product product) {
    setState(() {
      int productId = product.productId ?? 0;
      int stock = product.stock ?? 0; // Ambil stok produk (jika ada)

      // Pastikan jumlah produk yang dipilih tidak melebihi stok
      if (getQuantity(productId) < stock || product.unlimitedStock == 1) {
        quantityProduct[productId] = (getQuantity(productId)) + 1;
        selectedProducts[productId] = true; // Tandai produk sebagai dipilih
      }
    });
  }

// Mengurangi jumlah barang (jika 0, hapus dari daftar terpilih)
  void decrementQuantity(Product product) {
    setState(() {
      int productID = product.productId ?? 0;

      // Jika jumlah produk lebih dari 1, kurangi jumlahnya
      if (getQuantity(productID) > 1) {
        quantityProduct[productID] = quantityProduct[productID]! - 1;
      } else {
        // Jika jumlahnya 1, hapus dari daftar terpilih
        quantityProduct.remove(productID);
        selectedProducts[productID] = false; // Hapus status selected
      }
    });
  }

  // Fungsi untuk melihat jumlah barang yang dipilih sesuai kategori
  int getSelectedItemsInCategory(String category) {
    int totalSelected = 0;

    // Pastikan ada produk yang sesuai dengan kategori dalam productList
    for (var productItem in productList) {
      // Cek jika produk masuk dalam kategori yang diminta
      if (productItem.categoryNames == category) {
        // Cek apakah produk dipilih dan ada kuantitas produk
        if (selectedProducts[productItem.productId] == true &&
            quantityProduct.containsKey(productItem.productId) &&
            quantityProduct[productItem.productId]! > 0) {
          // Tambahkan 1 ke totalSelected jika produk dipilih
          totalSelected++;
        }
      }
    }

    return totalSelected;
  }

//function untuk melihat jumlah barang yang dipilih semua
  int getTotalSelectedItems() {
    int totalSelected = 0;

    // Loop melalui seluruh quantityProduct dan hitung jumlah totalnya
    quantityProduct.forEach((productName, quantity) {
      if (selectedProducts[productName] == true &&
          quantityProduct.containsKey(productName) &&
          quantityProduct[productName]! > 0) {
        // Tambahkan 1 ke totalSelected jika produk dipilih (hanya hitung satu kali per produk)
        totalSelected++;
      }
    });

    return totalSelected;
  }

//function mendapatkan setiap brang yang dilist
  List<SelectedProduct> getSelectedProducts() {
    List<SelectedProduct> selectedProductsList = [];

    // Loop untuk memeriksa setiap produk yang terpilih
    for (var prod in productList) {
      // Ambil nama produk, stok, dan harga dari objek Product
      String productName =
          prod.productName!; // Mengakses nama produk dari objek Product
      int productStock = prod.stock ?? 0; // Mengakses stok produk
      int productPrice = prod.price ?? 0; // Mengakses harga produk
      int productId = prod.productId!;
      int unlimitedStock = prod.unlimitedStock!;
      String imageproduct = prod.detailImages!.first.image ?? '';

      // Cek apakah produk dipilih dan memiliki kuantitas lebih dari 0
      if (selectedProducts[productId] == true &&
          quantityProduct[productId]! > 0) {
        // Menambahkan produk yang dipilih ke dalam daftar
        selectedProductsList.add(
          SelectedProduct(
            name: productName,
            stock: productStock,
            quantity: quantityProduct[productId]!,
            price: productPrice,
            id: productId,
            imageUrl: imageproduct,
            unlimitedStock: unlimitedStock,
          ),
        );
      }
    }

    return selectedProductsList;
  }

  int getTotalSelectItemQuantity() {
    int quantity = 0;
    // Cek tambahan produk dalam productListFilter
    for (var prod in productList) {
      int productID =
          prod.productId!; // Menggunakan namaProduct dari objek Product

      // Cek apakah produk dipilih dan memiliki kuantitas lebih dari 0
      if (selectedProducts[productID] == true &&
          quantityProduct[productID]! > 0) {
        quantity += quantityProduct[productID]!;
      }
    }

    return quantity;
  }

  Future<bool> _onWillPop() async {
    int item = getTotalSelectItemQuantity();
    if (item > 0) {
      bool? shouldPop = await showModalBottomSheet(
        backgroundColor: const Color(0xFFFBFBFB),
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 4,
                  color: const Color(0xFFE9E9E9),
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                const Text(
                  'Terdapat item dalam keranjang! , kembali ke beranda akan me-reset ulang keranjang aktif?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000)),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: CustombuttonColor(
                          margin: const EdgeInsets.only(top: 10),
                          height: 48,
                          alignment: Alignment.center,
                          color: const Color(0xFFFFFFFF),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF09090B)),
                          )),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child: CustombuttonColor(
                          margin: const EdgeInsets.only(top: 10),
                          height: 48,
                          alignment: Alignment.center,
                          color: const Color(0xFFFF3E1D),
                          onPressed: () async {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text(
                            'Kembali',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFFFF)),
                          )),
                    )
                  ],
                )
              ],
            ),
          );
        },
      );

      return shouldPop ?? false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi semua kategori dengan status tidak dipilih (false)
    _loadDataFuture = _readAndPrintCategoryData();
    selectedCategories['Semua'] = true;
    sortProductsByActive();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xffF6F8FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF6F8FA),
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: const Text(
              'Transaksi Baru',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF121212)),
            ),
          ),
          body: SafeArea(
              bottom: true,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Searchbar(
                          hintText: 'Cari sesuai nama',
                          onChanged: (p0) {
                            setState(() {
                              searchQuery = _searchControler.text;
                            });
                          },
                          controller: _searchControler,
                        ),
                        FutureBuilder(
                          future: _loadDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              if (categoryOption.isEmpty) {
                                return Container(
                                    alignment: Alignment.center,
                                    height: 375,
                                    width: 375,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        SvgPicture.asset(
                                          'asset/pegawai/Group 33979.svg',
                                          width: 105,
                                          height: 105,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        const Text(
                                          'Belum ada data barang tersedia',
                                          style: TextStyle(
                                              color: Color(0xFFB1B5C0),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ));
                              } else {
                                return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 55,
                                        padding: const EdgeInsets.all(0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isGalerry = !isGalerry;
                                                });
                                              },
                                              iconSize: 24,
                                              icon: isGalerry
                                                  ? SvgPicture.asset(
                                                      'asset/image/galeryView.svg')
                                                  : SvgPicture.asset(
                                                      'asset/image/tabler-icon-list-check.svg'),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                controller:
                                                    _scrollControllerCategory,
                                                child: Row(
                                                  children: [
                                                    FilterChip(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFFFFFFF),
                                                      selectedColor:
                                                          const Color(
                                                              0xFF2E6CE9),
                                                      side: BorderSide.none,
                                                      showCheckmark: false,
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          100))),
                                                      label: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 18,
                                                        decoration: const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        100))),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Semua',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 12,
                                                                color: selectedCategories[
                                                                            'Semua'] ==
                                                                        true
                                                                    ? const Color(
                                                                        0xFFFFFFFF)
                                                                    : const Color(
                                                                        0xFF00409A),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 20,
                                                              width: 20,
                                                              decoration: BoxDecoration(
                                                                  color: selectedCategories[
                                                                              'Semua'] ==
                                                                          true
                                                                      ? const Color(
                                                                          0xFFFFFFFF)
                                                                      : const Color(
                                                                          0xFFF1F1F1),
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              100))),
                                                              child: Text(
                                                                '${_getTotalItems()}',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 11,
                                                                  color: selectedCategories[
                                                                              'Semua'] ==
                                                                          true
                                                                      ? const Color(
                                                                          0xFF2E6CE9)
                                                                      : const Color(
                                                                          0xFF979899),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      selected:
                                                          selectedCategories[
                                                                  'Semua'] ??
                                                              false,
                                                      onSelected:
                                                          (bool selected) {
                                                        setState(() {
                                                          if (selected) {
                                                            selectedCategories
                                                                .forEach((key,
                                                                    value) {
                                                              selectedCategories[
                                                                      key] =
                                                                  key ==
                                                                      'Semua'; // Select only "Semua"
                                                            });
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Row(
                                                      children: categoryOption
                                                          .map((category) {
                                                        int jumlahbarang =
                                                            _getTotalItemsInCategory(
                                                                    category) ??
                                                                0;
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          child: Filterchip(
                                                            selected:
                                                                selectedCategories[
                                                                        category
                                                                            .namaKategori!] ??
                                                                    false,
                                                            onSelected:
                                                                (isSelected) {
                                                              setState(() {
                                                                // Reset all categories to false before selecting a new one
                                                                selectedCategories
                                                                    .updateAll((key,
                                                                            value) =>
                                                                        false);

                                                                // Set the selected category to true
                                                                selectedCategories[
                                                                        category
                                                                            .namaKategori!] =
                                                                    isSelected;

                                                                // After selecting a category, check if any category other than 'Semua' is selected
                                                                bool anyCategorySelected = selectedCategories
                                                                    .entries
                                                                    .any((entry) =>
                                                                        entry.key !=
                                                                            'Semua' &&
                                                                        entry.value ==
                                                                            true);

                                                                // If no category is selected, set 'Semua' to true
                                                                if (!anyCategorySelected) {
                                                                  selectedCategories[
                                                                          'Semua'] =
                                                                      true;
                                                                } else {
                                                                  selectedCategories[
                                                                          'Semua'] =
                                                                      false;
                                                                  _getFilteredProducts();
                                                                }
                                                              });
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  category
                                                                      .namaKategori!,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12,
                                                                    color: selectedCategories[category.namaKategori!] ==
                                                                            true
                                                                        ? const Color(
                                                                            0xFFFFFFFF)
                                                                        : const Color(
                                                                            0xFF00409A),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  height: 20,
                                                                  width: 20,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: selectedCategories['Semua'] ==
                                                                            true
                                                                        ? const Color(
                                                                            0xFFFFFFFF)
                                                                        : const Color(
                                                                            0xFFF1F1F1),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(100)),
                                                                  ),
                                                                  child: Text(
                                                                    jumlahbarang
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          12,
                                                                      color: selectedCategories[category.namaKategori!] ==
                                                                              true
                                                                          ? const Color(
                                                                              0xFF2E6CE9)
                                                                          : const Color(
                                                                              0xFF979899),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          child: ListView.builder(
                                        padding:
                                            const EdgeInsets.only(bottom: 55),
                                        controller: _scrollControllerbarang,
                                        shrinkWrap: true,
                                        itemCount: categoryOption.length,
                                        itemBuilder: (context, index) {
                                          String category =
                                              categoryOption[index]
                                                      .namaKategori ??
                                                  '';
                                          List<Product> productsInCategory =
                                              _getFilteredProducts()
                                                  .where((prod) {
                                            // Filter produk berdasarkan kategori atau kriteria lain
                                            return prod.categoryNames ==
                                                category; // Sesuaikan dengan kategori yang diinginkan
                                          }).toList();

                                          if (productsInCategory.isEmpty) {
                                            // Jika tidak ada produk dalam kategori ini setelah filter, lewati
                                            return const SizedBox.shrink();
                                          }
                                          List<Product> products =
                                              productsInCategory;
                                          int totalbarang =
                                              categoryOption[index]
                                                      .jumlahProduct ??
                                                  0;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      category,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Color(
                                                              0xFF303030)),
                                                    ),
                                                    Text(
                                                      '$totalbarang Item',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xFF979899)),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 12,
                                                ),
                                                isGalerry
                                                    ? ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                            productsInCategory
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          String harga = numberFormat
                                                              .format(int.parse(
                                                                  products[
                                                                          index]
                                                                      .price
                                                                      .toString()));
                                                          bool status = products[
                                                                          index]
                                                                      .status ==
                                                                  "Produk Aktif"
                                                              ? true
                                                              : false;
                                                          bool isSelected =
                                                              selectedProducts[products[
                                                                          index]
                                                                      .productId] ??
                                                                  false;
                                                          return Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              GestureDetector(
                                                                onLongPress:
                                                                    () {
                                                                  // Membatalkan pemilihan produk ketika long press
                                                                  setState(() {
                                                                    if (status ==
                                                                            true &&
                                                                        selectedProducts[products[index].productId] ==
                                                                            true) {
                                                                      selectedProducts[products[index].productId ??
                                                                              0] =
                                                                          false;
                                                                      quantityProduct
                                                                          .remove(
                                                                              products[index].productName); // Menghapus quantity produk saat dibatalkan
                                                                      _updateTotalAmount();
                                                                    }
                                                                  });
                                                                },
                                                                onTap: () {
                                                                  // Ketika produk diklik, hanya pilih produk (tidak membatalkan)
                                                                  setState(() {
                                                                    if (status == true &&
                                                                        selectedProducts[products[index].productId ??
                                                                                0] !=
                                                                            true &&
                                                                        (products[index].unlimitedStock ==
                                                                                1
                                                                            ? true
                                                                            : products[index].stock! >
                                                                                1)) {
                                                                      selectedProducts[products[index].productId ??
                                                                              0] =
                                                                          true; // Tetapkan produk sebagai dipilih
                                                                      quantityProduct[products[index].productId ??
                                                                              0] =
                                                                          1; // Set default quantity ke 1 jika dipilih
                                                                      _updateTotalAmount();
                                                                    } else if (status !=
                                                                        true) {
                                                                      print(
                                                                          'Barang mati'); // Jika status false, produk tidak bisa dipilih
                                                                    }
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                        width: double
                                                                            .infinity,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: Border.all(
                                                                              color: isSelected ? const Color(0xFF2E6CE9) : Colors.transparent,
                                                                              width: 1),
                                                                          color: status
                                                                              ? (isSelected ? const Color(0xFFE2ECFE) : const Color(0xFFFFFFFF))
                                                                              : const Color(0xFFEEEEEE),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                8,
                                                                            horizontal:
                                                                                16),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Container(
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Container(
                                                                                          width: 50,
                                                                                          height: 52,
                                                                                          padding: EdgeInsets.zero,
                                                                                          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
                                                                                          child: ClipRRect(
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                            child: products[index].detailImages!.isEmpty
                                                                                                ? const Placeholder()
                                                                                                : CachedNetworkImage(
                                                                                                    fit: BoxFit.cover,
                                                                                                    width: 50,
                                                                                                    height: 52,
                                                                                                    imageUrl: _apiProduct.getImage(products[index].detailImages!.first.image ?? ''),
                                                                                                    progressIndicatorBuilder: (context, url, progress) {
                                                                                                      if (progress.totalSize == null || progress.totalSize == 0) {
                                                                                                        return const Center(child: CircularProgressIndicator());
                                                                                                      }
                                                                                                      return Center(
                                                                                                        child: Column(
                                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                          children: [
                                                                                                            CircularProgressIndicator(
                                                                                                              value: progress.downloaded / (progress.totalSize ?? 1),
                                                                                                            ),
                                                                                                            Text(
                                                                                                              '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                                                                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                      );
                                                                                                    },
                                                                                                    errorWidget: (context, url, error) {
                                                                                                      return const Placeholder();
                                                                                                    },
                                                                                                  ),
                                                                                          )),
                                                                                      const SizedBox(
                                                                                        width: 16,
                                                                                      ),
                                                                                      Container(
                                                                                        color: Colors.transparent,
                                                                                        width: 85,
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(
                                                                                              products[index].productName ?? '',
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              style: TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600, fontSize: 14, color: status ? const Color(0xFF303030) : const Color(0xFF979899)),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              height: 4,
                                                                                            ),
                                                                                            Text(
                                                                                              harga,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: status ? const Color(0xFF979899) : const Color(0xFF979899)),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Positioned(
                                                                                right: 0,
                                                                                top: 0,
                                                                                left: 0,
                                                                                bottom: 0,
                                                                                child: Align(
                                                                                  alignment: Alignment.centerRight,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      isSelected
                                                                                          ? Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              children: [
                                                                                                Text(
                                                                                                  products[index].unlimitedStock == 1 ? '' : 'Tersisa ${products[index].stock! - getQuantity(products[index].productId ?? 0)}',
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: status ? const Color(0xFF979899) : const Color(0xFF979899)),
                                                                                                ),
                                                                                                const SizedBox(
                                                                                                  width: 12,
                                                                                                ),
                                                                                                Flexible(
                                                                                                  child: Container(
                                                                                                    padding: const EdgeInsets.all(4),
                                                                                                    width: 85,
                                                                                                    height: 30,
                                                                                                    decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Color(0xFFFFFFFF)),
                                                                                                    child: Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                                      children: [
                                                                                                        Container(
                                                                                                          width: 22,
                                                                                                          height: 22,
                                                                                                          decoration: const BoxDecoration(color: Color(0xFF2E6CE9), borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                                                          child: IconButton(
                                                                                                            visualDensity: VisualDensity.compact,
                                                                                                            padding: EdgeInsets.zero,
                                                                                                            onPressed: () {
                                                                                                              decrementQuantity(products[index]);
                                                                                                              _updateTotalAmount();
                                                                                                            },
                                                                                                            icon: const Icon(size: 16, Icons.remove_rounded, color: Colors.white),
                                                                                                          ),
                                                                                                        ),
                                                                                                        Text(
                                                                                                          getQuantity(products[index].productId ?? 0).toString(),
                                                                                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF09090B)),
                                                                                                        ),
                                                                                                        Container(
                                                                                                          width: 22,
                                                                                                          height: 22,
                                                                                                          decoration: const BoxDecoration(color: Color(0xFF2E6CE9), borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                                                          child: IconButton(
                                                                                                            visualDensity: VisualDensity.compact,
                                                                                                            padding: EdgeInsets.zero,
                                                                                                            onPressed: () {
                                                                                                              incrementQuantity(products[index]);
                                                                                                              _updateTotalAmount();
                                                                                                            },
                                                                                                            icon: const Icon(size: 16, Icons.add_rounded, color: Colors.white),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            )
                                                                                          : products[index].unlimitedStock == 1
                                                                                              ? const SizedBox.shrink()
                                                                                              : Text(
                                                                                                  'Stok ${products[index].stock}',
                                                                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: status ? (isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF979899)) : const Color(0xFF979899)),
                                                                                                ),
                                                                                    ],
                                                                                  ),
                                                                                ))
                                                                          ],
                                                                        )),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    : MasonryGridView.count(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        crossAxisSpacing: 10,
                                                        mainAxisSpacing: 10,
                                                        crossAxisCount: 2,
                                                        itemCount:
                                                            productsInCategory
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          // Ambil produk dari productsInCategory berdasarkan index
                                                          Product prod =
                                                              productsInCategory[
                                                                  index];

                                                          final numberFormat =
                                                              NumberFormat.currency(
                                                                  locale: 'id',
                                                                  symbol: 'Rp ',
                                                                  decimalDigits:
                                                                      0);
                                                          String harga =
                                                              numberFormat
                                                                  .format(prod
                                                                      .price);

                                                          bool status =
                                                              prod.unlimitedStock ==
                                                                      1
                                                                  ? true
                                                                  : prod.stock! >=
                                                                          1
                                                                      ? true
                                                                      : false;

                                                          bool isSelected =
                                                              selectedProducts[prod
                                                                      .productId] ??
                                                                  false; //

                                                          return GestureDetector(
                                                            onLongPress: () {
                                                              setState(() {
                                                                if (status ==
                                                                        true &&
                                                                    selectedProducts[
                                                                            prod.productId] ==
                                                                        true) {
                                                                  selectedProducts[
                                                                      prod.productId ??
                                                                          0] = false;
                                                                  quantityProduct
                                                                      .remove(prod
                                                                          .productId); // Menghapus quantity produk saat dibatalkan
                                                                  _updateTotalAmount();
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: isSelected
                                                                          ? const Color(
                                                                              0xFF2E6CE9)
                                                                          : Colors
                                                                              .transparent,
                                                                      width: 1),
                                                                  color: status
                                                                      ? (isSelected
                                                                          ? const Color(
                                                                              0xFFE2ECFE)
                                                                          : const Color(
                                                                              0xFFFFFFFF))
                                                                      : const Color(
                                                                          0xFFEEEEEE),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        8),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Container(
                                                                        height:
                                                                            150,
                                                                        padding:
                                                                            EdgeInsets
                                                                                .zero,
                                                                        decoration: BoxDecoration(
                                                                            color: Colors
                                                                                .transparent,
                                                                            borderRadius: BorderRadius.circular(
                                                                                10)),
                                                                        // alignment: Alignment.centerLeft,
                                                                        child:
                                                                            Stack(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                if (isSelected) {
                                                                                  incrementQuantity(prod);
                                                                                  _updateTotalAmount();
                                                                                }
                                                                              },
                                                                              child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                  child: products[index].detailImages!.isEmpty
                                                                                      ? const Placeholder()
                                                                                      : CachedNetworkImage(
                                                                                          fit: BoxFit.cover,
                                                                                          height: 150,
                                                                                          width: double.infinity,
                                                                                          imageUrl: _apiProduct.getImage(products[index].detailImages!.first.image ?? ''),
                                                                                          progressIndicatorBuilder: (context, url, progress) {
                                                                                            if (progress.totalSize == null || progress.totalSize == 0) {
                                                                                              return const Center(child: CircularProgressIndicator());
                                                                                            }
                                                                                            return Center(
                                                                                              child: Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                children: [
                                                                                                  CircularProgressIndicator(
                                                                                                    value: progress.downloaded / (progress.totalSize ?? 1),
                                                                                                  ),
                                                                                                  Text(
                                                                                                    '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                                                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                        )),
                                                                            ),
                                                                            Positioned(
                                                                              left: 8,
                                                                              top: 8,
                                                                              child: products[index].unlimitedStock == 1
                                                                                  ? const SizedBox.shrink()
                                                                                  : Container(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                                                      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Color(0xFFF6F8FA)),
                                                                                      child: Text(
                                                                                        'Stok ${prod.stock}',
                                                                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF303030).withOpacity(0.7)),
                                                                                      ),
                                                                                    ),
                                                                            ),
                                                                            isSelected
                                                                                ? Positioned(
                                                                                    bottom: 8,
                                                                                    right: 8,
                                                                                    child: Container(
                                                                                      padding: const EdgeInsets.all(4),
                                                                                      width: 85,
                                                                                      height: 30,
                                                                                      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Color(0xFFFFFFFF)),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 22,
                                                                                            height: 22,
                                                                                            decoration: const BoxDecoration(color: Color(0xFF2E6CE9), borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                                            child: IconButton(
                                                                                              visualDensity: VisualDensity.compact,
                                                                                              padding: EdgeInsets.zero,
                                                                                              onPressed: () {
                                                                                                decrementQuantity(prod);
                                                                                                _updateTotalAmount();
                                                                                              },
                                                                                              icon: const Icon(size: 16, Icons.remove_rounded, color: Colors.white),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            getQuantity(prod.productId ?? 0).toString(),
                                                                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF09090B)),
                                                                                          ),
                                                                                          Container(
                                                                                            width: 22,
                                                                                            height: 22,
                                                                                            decoration: const BoxDecoration(color: Color(0xFF2E6CE9), borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                                            child: IconButton(
                                                                                              visualDensity: VisualDensity.compact,
                                                                                              padding: EdgeInsets.zero,
                                                                                              onPressed: () {
                                                                                                incrementQuantity(prod);
                                                                                                _updateTotalAmount();
                                                                                              },
                                                                                              icon: const Icon(size: 16, Icons.add_rounded, color: Colors.white),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ))
                                                                                : Positioned(
                                                                                    right: 8,
                                                                                    bottom: 8,
                                                                                    child: Container(
                                                                                      width: 24,
                                                                                      height: 24,
                                                                                      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(100)), color: status ? const Color(0xFF2E6CE9) : const Color(0xFFB1B5C0)),
                                                                                      child: IconButton(
                                                                                        visualDensity: VisualDensity.compact,
                                                                                        padding: EdgeInsets.zero,
                                                                                        onPressed: () {
                                                                                          setState(() {
                                                                                            if (status == true && selectedProducts[prod.productName] != true && (prod.unlimitedStock == 1 ? true : prod.stock! > 1)) {
                                                                                              selectedProducts[prod.productId ?? 0] = true; // Tetapkan produk sebagai dipilih
                                                                                              quantityProduct[prod.productId ?? 0] = 1; // Set default quantity ke 1 jika dipilih
                                                                                              _updateTotalAmount();
                                                                                            } else if (status != true) {
                                                                                              print('Barang mati'); // Jika status false, produk tidak bisa dipilih
                                                                                            }
                                                                                          });
                                                                                        },
                                                                                        icon: const Icon(size: 16, Icons.add_rounded, color: Color(0xFFF6F8FA)),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                          ],
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4,
                                                                          horizontal:
                                                                              8),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            prod.productName ??
                                                                                '',
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                                color: status ? (isSelected ? const Color(0xFF303030) : const Color(0xFF303030)) : const Color(0xFF979899)),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            harga,
                                                                            style: TextStyle(
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: status ? (isSelected ? const Color(0xFF979899) : const Color(0xFF979899)) : const Color(0xFF979899)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                )),
                                                          );
                                                        },
                                                      )
                                              ],
                                            ),
                                          );
                                        },
                                      ))
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  if (totalAmount > 0)
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 20, top: 12),
                          child: customButtonPrimary(
                            height: 56,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Detailtransaksi(
                                            selectedProducts:
                                                getSelectedProducts(),
                                            idOutlet: id_Outlet,
                                          )));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'asset/image/shopping-bag.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${getTotalSelectItemQuantity()} Barang',
                                        style: const TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        numberFormat.format(totalAmount),
                                        style: const TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      // const SizedBox(width: 8),
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //       borderRadius:
                                      //           const BorderRadius.all(
                                      //               Radius.circular(8)),
                                      //       color: Colors.white
                                      //           .withOpacity(0.4)),
                                      //   child: const Icon(Icons.arrow_forward,
                                      //       color: Colors.white),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                  else
                    const SizedBox.shrink(),
                ],
              ))),
    );
  }
}
