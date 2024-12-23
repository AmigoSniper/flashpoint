import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:salescheck/Model/Transaksi.dart';
import 'package:salescheck/Model/selectedProduct.dart';
import 'package:salescheck/Service/ApiProduct.dart';
import 'package:salescheck/Service/ApiTransaksi.dart';
import 'package:salescheck/page/Detailorder/viewStruck.dart';

import '../../Model/struckModel.dart';
import '../../component/customButtonColor.dart';

class Detailorder extends StatefulWidget {
  final Transaksi transaksi;
  final String outlateName;
  final String iconjenisPembayaran;
  const Detailorder(
      {super.key,
      required this.transaksi,
      required this.outlateName,
      required this.iconjenisPembayaran});

  @override
  State<Detailorder> createState() => _DetailorderState();
}

class _DetailorderState extends State<Detailorder> {
  final Apiproduct _apiProduct = Apiproduct();
  final Apitransaksi _apitransaksi = Apitransaksi();
  final numberFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  final List<SelectedProduct> selectedProducts = [];
  String? buktiTransaksi;
  String formatDate(String inputDate) {
    try {
      // Parse input date dengan format yang sesuai
      DateTime dateTime = DateFormat(
        'MMM dd, yyyy HH.mm',
      ).parse(inputDate);

      // Format output menjadi bentuk yang diinginkan

      String formattedDate =
          DateFormat('EEE dd MMMM yyyy, HH:mm', 'id').format(dateTime);
      return formattedDate;
    } catch (e) {
      return 'Format Error: $e';
    }
  }

  int subTotal(Transaksi transaksi) {
    double price = 0;
    for (var i = 0; i < transaksi.detailtransaksi!.length; i++) {
      num productPrice = transaksi.detailtransaksi![i].productPrice ?? 0;
      int stok = transaksi.detailtransaksi![i].stok ?? 0;
      price += productPrice * stok;
    }
    return price.toInt();
  }

  int diskon(Transaksi transaksi) {
    int price = 0;
    for (var i = 0; i < transaksi.detaildiskons!.length; i++) {
      price += transaksi.detaildiskons![i].harga!;
    }
    return price.toInt();
  }

  int biayaTambahan(Transaksi transaksi) {
    int price = 0;
    for (var i = 0; i < transaksi.detailpajaks!.length; i++) {
      price += transaksi.detailpajaks![i].harga!;
    }
    return price.toInt();
  }

  int total(Transaksi transaksi) {
    return subTotal(transaksi) + biayaTambahan(transaksi) - diskon(transaksi);
  }

  String tanggalTransaksi(Transaksi transaksi) {
    String formattedDate = DateFormat('EEE dd MMMM yyyy, hh:mm a')
        .format(DateTime.parse(transaksi.createdAt ?? ''));
    return formattedDate;
  }

  void _buktiform(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                color: const Color(0xFFE9E9E9),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bukti Transaksi',
                  style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              FutureBuilder<String>(
                future: _apitransaksi
                    .getbuktiTransaksi(widget.transaksi.penjualanId ?? 0),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Gambar tidak tersedia');
                  } else {
                    return CachedNetworkImage(
                      fit: BoxFit.fitWidth,
                      imageUrl: snapshot.data!,
                      progressIndicatorBuilder: (context, url, progress) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress.totalSize != null
                                  ? progress.downloaded /
                                      (progress.totalSize ?? 1)
                                  : null,
                            ),
                            if (progress.totalSize != null)
                              Text(
                                '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ));
                      },
                      errorWidget: (context, url, error) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'asset/image/gallery-add.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            const Text(
                              'Tambah Foto',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFA8A8A8)),
                            )
                          ],
                        );
                      },
                    );
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Detail Order',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2EC0E9), Color(0xFF2E6CE9)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 291,
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ${widget.transaksi.penjualanId} Selesai',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xFFFFFFFF)),
                          ),
                          const Text(
                            'Terima kasih telah menggunakan Sirque',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFFE0E0E0)),
                          ),
                        ],
                      ),
                    ),
                    SvgPicture.asset('asset/detailorder/bag-tick-2.svg')
                  ],
                ),
              ),
              Container(
                color: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Struk ${widget.transaksi.penjualanId}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: const Color(0xFF2C3E50)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Viewstruck(
                                      idTransaksi:
                                          widget.transaksi.penjualanId ?? 0),
                                ));
                          },
                          child: const SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Lihat',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF16A34A)),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 12, color: Color(0xFF16A34A))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Divider(
                      color: Color(0xFFF5F5F5),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          'Tanggal pesan',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Color(0xFF979899)),
                        ),
                        Text(
                          tanggalTransaksi(widget.transaksi),
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Color(0xFF979899)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFFFFFFF),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2EC0E9),
                                    Color(0xFF2E6CE9)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight)),
                          child: SvgPicture.asset('asset/detailorder/shop.svg'),
                        ),
                        Text(
                          widget.outlateName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF2C3E50)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.transaksi.detailtransaksi!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(10))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  width: 60,
                                  height: 60,
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
                                      imageUrl: _apiProduct.getImage(widget
                                          .transaksi
                                          .detailtransaksi![index]
                                          .foto),
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
                              Flexible(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget
                                                        .transaksi
                                                        .detailtransaksi![index]
                                                        .productName ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF303030)),
                                              ),
                                              // const Text(
                                              //   'Choice 1, Choice 2',
                                              //   style: TextStyle(
                                              //       fontSize: 12,
                                              //       fontWeight: FontWeight.w500,
                                              //       color: Color(0xFF979899)),
                                              // )
                                            ],
                                          ),
                                        ),
                                        Text(
                                          numberFormat.format(widget
                                              .transaksi
                                              .detailtransaksi![index]
                                              .productPrice),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2C3E50)),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'x${widget.transaksi.detailtransaksi![index].stok}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E6CE9)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    const DottedLine(
                      lineThickness: 2,
                      dashColor: Color(0xFFE0E0E0),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Jumlah total',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000)),
                        ),
                        Text(
                          numberFormat.format(subTotal(widget.transaksi)),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    const Text(
                      'Ringkasan Pembayaran',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000)),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Total barang',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF787878)),
                        ),
                        Text(
                          numberFormat.format(subTotal(widget.transaksi)),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Biaya Tambahan',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF787878)),
                        ),
                        Text(
                          numberFormat.format(biayaTambahan(widget.transaksi)),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Potongan',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF787878)),
                        ),
                        Text(
                          numberFormat.format(diskon(widget.transaksi)),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const DottedLine(
                      lineThickness: 2,
                      dashColor: Color(0xFFE0E0E0),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000)),
                        ),
                        Text(
                          numberFormat.format(total(widget.transaksi)),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    const Text(
                      'Detail Pembayaran',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000)),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(widget.iconjenisPembayaran),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  widget.transaksi.tipeBayar ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2C3E50)),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                          ),
                          widget.transaksi.tipeBayar == 'Cash'
                              ? const SizedBox.shrink()
                              : GestureDetector(
                                  onTap: () {
                                    _buktiform(context);
                                  },
                                  child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Lihat Bukti Transaksi',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF2E6CE9)),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                          )
                                        ],
                                      )),
                                )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
