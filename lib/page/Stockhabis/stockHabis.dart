import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:salescheck/component/notifSucces.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/product.dart';
import '../../Service/ApiProduct.dart';
import '../Barang/editBarang.dart';

class Stockhabis extends StatefulWidget {
  const Stockhabis({super.key});

  @override
  State<Stockhabis> createState() => _StockhabisState();
}

class _StockhabisState extends State<Stockhabis> {
  final Apiproduct _apiproduct = new Apiproduct();
  final numberFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  late Future<void> _loadDataFuture;
  List<Product> productListFilter = [];
  List<Product> productList = [];
  Future<void> _readAndPrintProductData() async {
    print('mulai get');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int idOutlet = prefs.getInt('id_outlet') ?? 0;

    // Ambil produk berdasarkan outlet dan kategori
    productList = await _apiproduct.getProductsByOutletAndCategory(
      outletId: idOutlet,
      categoryId: 0,
    );
    if (_apiproduct.statusCode == 200) {
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
                product.detailOutlets!.first.outletsId == idOutlet &&
                product.unlimitedStock != 1 &&
                product.stock! <= 2)
            .toList();
      });
      print('Panjang Product iniliasiasi = ${productListFilter.length}');
    } else {
      print('Error _readAndPrintProductData: ${_apiproduct.message}');
    }
  }

  Future<void> _refreshData() async {
    // Simulasi delay untuk menunggu data baru
    await Future.delayed(const Duration(seconds: 2));
    productList.clear();

    productListFilter.clear();

    // Perbarui data dan setState untuk memperbarui tampilan
    setState(() {
      _readAndPrintProductData();
    });
  }

  void _showQuickAction(
      BuildContext context,
      int id,
      int idOutlet,
      String namaBarang,
      int harga,
      String deskripsi,
      int relasiCategory,
      String category,
      bool status,
      int Stock,
      bool stokcTakTerbatas,
      String imageUrl,
      int imageRealsi) {
    final TextEditingController stockValue = TextEditingController();
    int? stockModal = Stock;
    stockValue.text = Stock.toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDFEFE),
      builder: (BuildContext context) {
        bool statusActive = status;
        return StatefulBuilder(
          builder: (context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 25,
                  top: 16,
                  right: 16,
                  left: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 50,
                      height: 4,
                      color: const Color(0xFFE9E9E9),
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SvgPicture.asset('asset/image/info-circle.svg'),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Item ini ${statusActive ? 'tersedia' : 'tidak'} dan ${stokcTakTerbatas ? 'tidak ada batas stok' : 'punya batas stok'}',
                          style: const TextStyle(
                              color: Color(0xFFE5851F),
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 140,
                            height: 140,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                width: 140,
                                height: 140,
                                imageUrl: _apiproduct.getImage(imageUrl),
                                progressIndicatorBuilder:
                                    (context, url, progress) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.totalSize != null
                                          ? progress.downloaded /
                                              (progress.totalSize ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            )),
                        const SizedBox(
                          width: 16,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          width: 187,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaBarang,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF303030)),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                deskripsi,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9399A7)),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                numberFormat.format(harga),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF303030)),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                // width: 77,
                                height: 24,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFF8F8F8)),
                                padding: EdgeInsets.zero,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Editbarang(
                                                    name: namaBarang,
                                                    deskripis: deskripsi,
                                                    category: category,
                                                    harga: harga,
                                                    imageUrl: imageUrl,
                                                    unlimitedStock:
                                                        stokcTakTerbatas,
                                                    idOutlet: idOutlet,
                                                    idProduct: id,
                                                    stock: Stock,
                                                    categoryRelasi:
                                                        relasiCategory,
                                                    imageRelasi: imageRealsi,
                                                  )));
                                      if (result != null) {
                                        final message = result['message'];
                                        final isDeleted = result['isDeleted'];
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                        print(message);
                                        print(isDeleted);
                                        if (isDeleted == true) {
                                          setState(() {
                                            //delete item
                                            _refreshData();
                                          });
                                          Notifsucces.showNotif(
                                              context: context,
                                              description: message);
                                        } else {
                                          _refreshData();
                                          Notifsucces.showNotif(
                                              context: context,
                                              description: message);
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      shadowColor: Colors.transparent,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      backgroundColor: const Color(0xFFF8F8F8),
                                    ),
                                    child: const Text(
                                      'Edit Detail',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0EA5E9)),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF303030)),
                      ),
                      SizedBox(
                          width: 44,
                          height: 24,
                          child: CupertinoSwitch(
                            activeColor: const Color(0xFF10B981),
                            trackColor: const Color(0xFFE2E8F0),
                            thumbColor: const Color(0xFFFFFFFF),
                            value: statusActive,
                            onChanged: (value) {
                              print('tekan');
                              print(value);
                              setModalState(() {
                                statusActive = value;
                              });
                            },
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Divider(
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Stok tak terbatas',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF303030)),
                      ),
                      SizedBox(
                          width: 44,
                          height: 24,
                          child: CupertinoSwitch(
                            activeColor: const Color(0xFF10B981),
                            trackColor: const Color(0xFFE2E8F0),
                            thumbColor: const Color(0xFFFFFFFF),
                            value: stokcTakTerbatas,
                            onChanged: (value) {
                              setModalState(() {
                                stokcTakTerbatas = value;
                              });
                            },
                          )),
                    ],
                  ),
                  stokcTakTerbatas
                      ? const SizedBox.shrink()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFEEEEEE),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Jumlah Stock',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF303030)),
                                ),
                                Container(
                                  width: 115,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    color: Color(0xFFF4F4F5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          stockModal =
                                              int.parse(stockValue.text);
                                          if (stockModal! > 0) {
                                            setModalState(() {
                                              stockModal =
                                                  (stockModal ?? 0) - 1;
                                              stockValue.text =
                                                  stockModal.toString();
                                            });
                                          } else {
                                            null;
                                          }
                                        },
                                        icon: const Icon(
                                            size: 24,
                                            Icons.remove_circle,
                                            color: Color(0xFF2E6CE9)),
                                      ),
                                      Container(
                                        width: 35,
                                        height: 32,
                                        alignment: Alignment.center,
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          controller: stockValue,
                                          onChanged: (value) {
                                            setModalState(() {
                                              stockValue.text = value;
                                              stockModal = int.parse(value);
                                            });
                                          },
                                          maxLength: 3,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Isi data lebih dahulu';
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          style: const TextStyle(
                                              color: Color(0xFF101010),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                          decoration: const InputDecoration(
                                              isCollapsed: true,
                                              isDense: true,
                                              counterText: '',
                                              hintStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Color(0xFFA8A8A8)),
                                              hintText: '1',
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          stockModal =
                                              int.parse(stockValue.text);
                                          setModalState(() {
                                            stockModal = (stockModal ?? 0) + 1;
                                            stockValue.text =
                                                stockModal.toString();
                                          });
                                        },
                                        icon: const Icon(
                                            size: 24,
                                            Icons.add_circle,
                                            color: Color(0xFF2E6CE9)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: ElevatedButton(
                        onPressed: () async {
                          await _apiproduct.quickeditProductApi(
                              productId: id,
                              nama: namaBarang,
                              stock: stockModal,
                              unlimitedStock: stokcTakTerbatas,
                              status: statusActive);
                          if (_apiproduct.statusCode == 200 ||
                              _apiproduct.statusCode == 201) {
                            Navigator.pop(context);
                            Notifsucces.showNotif(
                                context: context,
                                description:
                                    'Stok $namaBarang berhasil diedit');
                            _refreshData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            backgroundColor: const Color(0xFF0D50D7),
                            minimumSize: const Size(double.infinity, 50)),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF)),
                        )),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _readAndPrintProductData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Stock Habis',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            if (productListFilter.isEmpty) {
              return Container(
                  alignment: Alignment.center,
                  height: 375,
                  width: 375,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
              return ListView.builder(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                itemCount: productListFilter.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  String harga =
                      numberFormat.format(productListFilter[index].price);
                  bool status =
                      productListFilter[index].status == 'Produk Aktif'
                          ? true
                          : false;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          String deskripsi =
                              productListFilter[index].description ?? '';

                          _showQuickAction(
                              context,
                              productListFilter[index].productId ?? 0,
                              productListFilter[index]
                                      .detailOutlets!
                                      .first
                                      .id ??
                                  0,
                              productListFilter[index].productName ?? '',
                              int.parse(harga.replaceAll(RegExp(r'[^\d]'), '')),
                              deskripsi,
                              productListFilter[
                                          index]
                                      .detailCategories!
                                      .first
                                      .id ??
                                  0,
                              productListFilter[index].categoryNames ?? '',
                              status,
                              productListFilter[index].unlimitedStock == 1
                                  ? 0
                                  : productListFilter[index].stock ?? 0,
                              productListFilter[index].unlimitedStock == 1
                                  ? true
                                  : false,
                              productListFilter[index]
                                      .detailImages!
                                      .last
                                      .image ??
                                  '',
                              productListFilter[index].detailImages!.last.id ??
                                  0);
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: status
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Row(
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
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: productListFilter[index]
                                                  .detailImages!
                                                  .isEmpty
                                              ? const Placeholder()
                                              : CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  width: 140,
                                                  height: 140,
                                                  imageUrl:
                                                      _apiproduct.getImage(
                                                          productListFilter[
                                                                  index]
                                                              .detailImages!
                                                              .last
                                                              .image),
                                                  progressIndicatorBuilder:
                                                      (context, url, progress) {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: progress
                                                                    .totalSize !=
                                                                null
                                                            ? progress
                                                                    .downloaded /
                                                                (progress
                                                                        .totalSize ??
                                                                    1)
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                        )),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Container(
                                      width: 150,
                                      height: 40,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              productListFilter[index]
                                                      .productName ??
                                                  '',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: status
                                                      ? const Color(0xFF303030F)
                                                      : const Color(
                                                          0xFF979899)),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                harga,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF979899)),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Icon(
                                                Icons.circle,
                                                color: const Color(0xFF979899)
                                                    .withOpacity(0.5),
                                                size: 4,
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  'Stock ${productListFilter[index].unlimitedStock == 1 ? 'Tak terbatas' : productListFilter[index].stock}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: status
                                                          ? const Color(
                                                              0xFF979899)
                                                          : const Color(
                                                              0xFF979899)),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                // width: 47,
                                // height: 24,
                                padding: EdgeInsets.zero,
                                child: TextButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Editbarang(
                                                  name: productListFilter[index]
                                                          .productName ??
                                                      '',
                                                  deskripis:
                                                      productListFilter[index]
                                                              .description ??
                                                          '',
                                                  category:
                                                      productListFilter[index]
                                                              .categoryNames ??
                                                          '',
                                                  harga:
                                                      productListFilter[index]
                                                              .price ??
                                                          0,
                                                  imageUrl:
                                                      productListFilter[index]
                                                          .detailImages!
                                                          .last
                                                          .image!,
                                                  unlimitedStock:
                                                      productListFilter[index]
                                                                  .unlimitedStock ==
                                                              1
                                                          ? true
                                                          : false,
                                                  idOutlet:
                                                      productListFilter[index]
                                                              .detailOutlets!
                                                              .first
                                                              .outletsId ??
                                                          0,
                                                  idProduct:
                                                      productListFilter[index]
                                                              .productId ??
                                                          0,
                                                  stock:
                                                      productListFilter[index]
                                                              .stock ??
                                                          0,
                                                  categoryRelasi:
                                                      productListFilter[index]
                                                              .detailCategories!
                                                              .first
                                                              .id ??
                                                          0,
                                                  imageRelasi:
                                                      productListFilter[index]
                                                          .detailImages!
                                                          .last
                                                          .id!,
                                                )));
                                    if (result != null) {
                                      final message = result['message'];
                                      final isDeleted = result['isDeleted'];
                                      // ignore: use_build_context_synchronously

                                      if (isDeleted == true) {
                                        setState(() {
                                          _refreshData();
                                        });

                                        Notifsucces.showNotif(
                                            context: context,
                                            description: message);
                                      } else {
                                        Notifsucces.showNotif(
                                            context: context,
                                            description: message);
                                        _refreshData();
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Edit',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF2E6CE9),
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      SvgPicture.asset(
                                        'asset/image/edit.svg',
                                        width: 16,
                                        height: 16,
                                        color: const Color(0xFF2E6CE9),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      )
                    ],
                  );
                },
              );
            }
          }
        },
      )),
    );
  }
}
