import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:salescheck/Service/ApiTransaksi.dart';
import 'package:salescheck/component/notifError.dart';
import 'package:salescheck/page/Transaksi/buktiPembayaran.dart';
import 'package:salescheck/page/landingPage/homepage.dart';
import 'package:salescheck/page/landingPage/landingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/RekeningModel.dart';
import '../../Model/biayaTambahanModel.dart';
import '../../Model/eWalletModel.dart';
import '../../Model/promosi.dart';
import '../../Model/selectedProduct.dart';
import '../../Service/ApiEwallet.dart';
import '../../Service/ApiRekening.dart';
import '../../component/customButtonPrimary.dart';

class Pembayarantransaksi extends StatefulWidget {
  final int idOutlet;
  final String name;
  final double totalAmount;
  final double totalPajak;
  final double totalOperasional;
  final double finalAmount;
  final List<Promosi> listpromosiselected;
  final List<SelectedProduct> selectedProducts;
  final List<biayaTambahanModel> biaya;
  const Pembayarantransaksi(
      {super.key,
      required this.finalAmount,
      required this.name,
      required this.idOutlet,
      required this.totalAmount,
      required this.listpromosiselected,
      required this.totalPajak,
      required this.totalOperasional,
      required this.selectedProducts,
      required this.biaya});

  @override
  State<Pembayarantransaksi> createState() => _PembayarantransaksiState();
}

class _PembayarantransaksiState extends State<Pembayarantransaksi>
    with TickerProviderStateMixin {
  final Apitransaksi _apitransaksi = Apitransaksi();
  final Apirekening _apirekening = Apirekening();
  final Apiewallet _apiewallet = Apiewallet();
  late Future<void> _loadDataFuture;
  final numberFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  final kembalianFormat = NumberFormat('#,##0', 'id');
  final nominalFormat = NumberFormat.decimalPatternDigits(decimalDigits: 0);
  late TabController _tabController;
  late ScrollController _scrollControllerEwallet;
  final TextEditingController kembalianControler = new TextEditingController();
  FocusNode _focusNodekembalian = FocusNode();
  int? tabindex;
  bool focusKembalian = false;
  List<int> nominal = [50000, 100000, 150000, 200000, 500000, 1000000];
  int bankIndex = 0;

  List<Ewalletmodel> eWalletlist = [];

  List<Rekeningmodel> listRekening = [];

  Ewalletmodel? selectedValueEWallet;
  Rekeningmodel? selectedValueBank;
  Future<void> getPembayaran() async {
    eWalletlist = await _apiewallet.getEwallet();
    if (_apiewallet.statusCode == 200 || _apiewallet.statusCode == 201) {
      setState(() {
        eWalletlist = eWalletlist;
      });
    }
    listRekening = await _apirekening.getRekening();
    if (_apirekening.statusCode == 200 || _apirekening.statusCode == 201) {
      setState(() {
        listRekening = listRekening;
      });
    }
    setState(() {
      if (eWalletlist.isNotEmpty) {
        selectedValueEWallet = eWalletlist.first;
      }
      if (listRekening.isNotEmpty) {
        selectedValueBank = listRekening.first;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = getPembayaran();
    _tabController = TabController(length: 3, vsync: this);
    tabindex = _tabController.index;
    print(_tabController.index);
    print(_tabController.length);

    _tabController.addListener(() {
      setState(() {
        // Perbarui index saat tab berubah
        tabindex = _tabController.index;
        print('Tab index sekarang: $tabindex');
      });
    });

    kembalianControler.addListener(() {
      String text = kembalianControler.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isNotEmpty) {
        final formattedValue = kembalianFormat.format(int.parse(text));
        kembalianControler.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    });
    _focusNodekembalian.addListener(() {
      setState(() {
        focusKembalian = _focusNodekembalian.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    _focusNodekembalian.dispose();
  }

  double _getContainerHeight() {
    if (tabindex == 0) {
      return 335;
    } else if (tabindex == 1) {
      return 500;
    } else if (tabindex == 2) {
      return 370;
    } else {
      return 300;
    }
  }

  void pushHomepage(
      int idTransaksi, int idOutlet, String metodePembayaran, int kembalian) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => Buktipembayaran(
              idTransaksi: idTransaksi,
              metodePembayaran: metodePembayaran,
              totalKembalian: kembalian,
              idOutlet: idOutlet)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Pembayaran',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  width: double.infinity,
                  height: 128,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Pelanggan',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF717179)),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'asset/image/profile.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Container(
                                      alignment: Alignment.centerRight,
                                      height: 39,
                                      child: Text(
                                        '${widget.name}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF000000)),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const DottedLine(
                        lineThickness: 1,
                        dashColor: Color(0xFFE0E0E0),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF717179)),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              numberFormat.format(widget.finalAmount),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E6CE9)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: FutureBuilder(
                      future: _loadDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          print(snapshot.error);
                          print(snapshot.stackTrace);
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
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TabBar(
                                isScrollable: false,
                                controller: _tabController,
                                dividerColor: const Color(0xFFEBEBED),
                                dividerHeight: 1,
                                labelColor: const Color(0xFF303030),
                                unselectedLabelColor: const Color(0xFFB1B5C0),
                                indicatorColor: const Color(0xFF303030),
                                indicatorWeight: 1,
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                tabs: const <Widget>[
                                  Tab(text: 'Tunai'),
                                  Tab(text: 'e-Wallet'),
                                  Tab(text: 'Transfer'),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                  height: _getContainerHeight(),
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    controller: _tabController,
                                    children: [
                                      Container(
                                        width: 400,
                                        height: 336,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              width: double.infinity,
                                              decoration: const BoxDecoration(
                                                  color: Color(0xFFFFF9E6),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  SvgPicture.asset(
                                                      'asset/image/info-circle.svg'),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  const Text(
                                                    'Bayar dengan uang pas',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFFE5851F)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            RichText(
                                              text: const TextSpan(
                                                text: 'Uang yang diterima ',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF6C7278)),
                                                children: [
                                                  TextSpan(
                                                    text: '*',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 0),
                                                decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(8)),
                                                    color: Color(0XFFF6F6F6)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      'Rp',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFA8A8A8),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Flexible(
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller:
                                                            kembalianControler,
                                                        focusNode:
                                                            _focusNodekembalian,
                                                        maxLength: 10,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        // validator: (value) {
                                                        //   if (value == null ||
                                                        //       value.isEmpty) {
                                                        //     return 'Isi data lebih dahulu';
                                                        //   }
                                                        //   return null;
                                                        // },
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF101010),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14),
                                                        decoration: const InputDecoration(
                                                            counterText: '',
                                                            hintStyle: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFFA8A8A8)),
                                                            hintText:
                                                                'Masukkan nominal',
                                                            border: InputBorder
                                                                .none),
                                                      ),
                                                    )
                                                  ],
                                                )),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            GridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      mainAxisSpacing: 16,
                                                      crossAxisSpacing: 16,
                                                      childAspectRatio: 3.027),
                                              itemCount: nominal.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      kembalianControler.text =
                                                          nominal[index]
                                                              .toString();
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFFEEEEEE),
                                                            width: 1),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    10))),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text(
                                                          'Rp',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF979899),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          nominalFormat.format(
                                                              nominal[index]),
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF2E6CE9),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                          width: double.infinity,
                                          height: 800,
                                          child: SingleChildScrollView(
                                            physics: const ScrollPhysics(),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  width: double.infinity,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color:
                                                              Color(0xFFFFF9E6),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      SvgPicture.asset(
                                                          'asset/image/info-circle.svg'),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      const Text(
                                                        'Pastikan sudah terbayar',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFFE5851F)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  width: double.infinity,
                                                  height: 46,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF6F6F6),
                                                    border: Border.all(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton2<
                                                        Ewalletmodel>(
                                                      iconStyleData: IconStyleData(
                                                          icon: SvgPicture.asset(
                                                              'asset/image/arrow-down.svg')),
                                                      isExpanded: true,
                                                      isDense: false,
                                                      hint: const Text(
                                                        'Data eWalet kosong',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFF576067)),
                                                      ),
                                                      selectedItemBuilder:
                                                          (context) {
                                                        return eWalletlist.map(
                                                            (Ewalletmodel
                                                                item) {
                                                          return Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              item.namaEwallet ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color(
                                                                      0xFF000000)),
                                                            ),
                                                          );
                                                        }).toList();
                                                      },
                                                      items: eWalletlist
                                                          .map((Ewalletmodel
                                                                  item) =>
                                                              DropdownMenuItem<
                                                                      Ewalletmodel>(
                                                                  value: item,
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12,
                                                                        right:
                                                                            12,
                                                                        bottom:
                                                                            4,
                                                                        top: 0),
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                            border:
                                                                                Border(bottom: BorderSide(width: 1, color: Color(0xFFE1E1E1)))),
                                                                    child: Text(
                                                                      item.namaEwallet ??
                                                                          '',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: Color(
                                                                            0xFF717179),
                                                                      ),
                                                                    ),
                                                                  )))
                                                          .toList(),
                                                      value:
                                                          selectedValueEWallet,
                                                      onChanged: (Ewalletmodel?
                                                          value) {
                                                        setState(() {
                                                          selectedValueEWallet =
                                                              value;
                                                        });
                                                      },
                                                      buttonStyleData:
                                                          const ButtonStyleData(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 0),
                                                        height: 40,
                                                        width: 213,
                                                      ),
                                                      menuItemStyleData:
                                                          const MenuItemStyleData(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 0),
                                                        height: 30,
                                                      ),
                                                      dropdownStyleData:
                                                          const DropdownStyleData(
                                                              elevation: 4,
                                                              maxHeight: 160,
                                                              useSafeArea: true,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                                color: Colors
                                                                    .white,
                                                              )),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                CachedNetworkImage(
                                                  fit: BoxFit.fitWidth,
                                                  imageUrl:
                                                      _apiewallet.getImage(
                                                          selectedValueEWallet
                                                                  ?.image ??
                                                              ''),
                                                  progressIndicatorBuilder:
                                                      (context, url, progress) {
                                                    return Center(
                                                        child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
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
                                                        if (progress
                                                                .totalSize !=
                                                            null)
                                                          Text(
                                                            '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                      ],
                                                    ));
                                                  },
                                                  errorWidget:
                                                      (context, url, error) {
                                                    return const SizedBox
                                                        .shrink();
                                                  },
                                                ),
                                                const SizedBox(
                                                  height: 32,
                                                )
                                              ],
                                            ),
                                          )),
                                      Container(
                                          width: double.infinity,
                                          height: 50,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  width: double.infinity,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color:
                                                              Color(0xFFFFF9E6),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      SvgPicture.asset(
                                                          'asset/image/info-circle.svg'),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      const Expanded(
                                                        child: Text(
                                                          'Pastikan Bank Tujuan yang diinginkan memiliki data yang benar',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFFE5851F)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  width: double.infinity,
                                                  height: 46,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF6F6F6),
                                                    border: Border.all(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton2<
                                                        Rekeningmodel>(
                                                      iconStyleData: IconStyleData(
                                                          icon: SvgPicture.asset(
                                                              'asset/image/arrow-down.svg')),
                                                      isExpanded: true,
                                                      isDense: false,
                                                      hint: const Text(
                                                        'Tidak ada data rekening',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFF576067)),
                                                      ),
                                                      selectedItemBuilder:
                                                          (context) {
                                                        return listRekening.map(
                                                            (Rekeningmodel
                                                                item) {
                                                          return Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              item.namaBank ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color(
                                                                      0xFF000000)),
                                                            ),
                                                          );
                                                        }).toList();
                                                      },
                                                      items: listRekening
                                                          .map((Rekeningmodel
                                                                  item) =>
                                                              DropdownMenuItem<
                                                                      Rekeningmodel>(
                                                                  value: item,
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12,
                                                                        right:
                                                                            12,
                                                                        bottom:
                                                                            4,
                                                                        top: 0),
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                            border:
                                                                                Border(bottom: BorderSide(width: 1, color: Color(0xFFE1E1E1)))),
                                                                    child: Text(
                                                                      item.namaBank ??
                                                                          '',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: Color(
                                                                            0xFF717179),
                                                                      ),
                                                                    ),
                                                                  )))
                                                          .toList(),
                                                      value: selectedValueBank,
                                                      onChanged: (Rekeningmodel?
                                                          value) {
                                                        setState(() {
                                                          selectedValueBank =
                                                              value;
                                                        });
                                                      },
                                                      buttonStyleData:
                                                          const ButtonStyleData(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 0),
                                                        height: 40,
                                                        width: 213,
                                                      ),
                                                      menuItemStyleData:
                                                          const MenuItemStyleData(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 0),
                                                        height: 30,
                                                      ),
                                                      dropdownStyleData:
                                                          const DropdownStyleData(
                                                              elevation: 4,
                                                              maxHeight: 160,
                                                              useSafeArea: true,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                                color: Colors
                                                                    .white,
                                                              )),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 170,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xFFE5F6FF),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8)),
                                                      border: GradientBoxBorder(
                                                          gradient: LinearGradient(
                                                              colors: [
                                                            Color(0xFF2E6CE9),
                                                            Color(0x008CBB4D)
                                                          ],
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Color(0x1A2E6CE9),
                                                          offset:
                                                              Offset(0, -10),
                                                          blurRadius: 20,
                                                          spreadRadius: 0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        selectedValueBank !=
                                                                null
                                                            ? Image.asset(
                                                                'asset/Rekening/${selectedValueBank!.namaBank}.png',
                                                                width: 40,
                                                                height: 40,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Image.asset(
                                                                      width: 63,
                                                                      height:
                                                                          42,
                                                                      'asset/Rekening/Bank Lainnya.png');
                                                                },
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          selectedValueBank
                                                                  ?.namaBank ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFF515151),
                                                          ),
                                                        ),
                                                        Text(
                                                          selectedValueBank
                                                                  ?.nomerRekening ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xFF303030),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          selectedValueBank
                                                                  ?.namaPemilik ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFF303030),
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                const Text(
                                                  '* Pastikan data bank yang diinput oleh admin sudah benar, kami tidak bertanggung jawab apabila ada salah data nominal dan data bank yang diinputkan salah ',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF2C3E50),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                                    ],
                                  ))
                            ],
                          );
                        }
                      },
                    ))
              ],
            ),
          )),
          Container(
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFFFDFEFE),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF888888).withOpacity(0.08),
                    offset: const Offset(0, -4),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
                borderRadius:
                    BorderRadius.circular(12), // Sesuai dengan button radius
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              width: double.infinity,
              child: customButtonPrimary(
                alignment: Alignment.center,
                onPressed: () async {
                  String? bayar;
                  String harganya =
                      kembalianControler.text.replaceAll(RegExp(r'[^\d]'), '');

                  double? kembalian;
                  double uangDibayar = 0;

                  // Menghitung kembalian berdasarkan tipe pembayaran
                  switch (_tabController.index) {
                    case 0: // Cash// Pastikan harganya valid sebelum di-convert
                      if (harganya.isEmpty || harganya == '0') {
                        Notiferror.showNotif(
                            context: context,
                            description: 'Masukan jumlah uang yang valid');
                        return;
                      }

                      // Mengonversi harga menjadi double
                      try {
                        uangDibayar = double.parse(harganya);
                      } catch (e) {
                        Notiferror.showNotif(
                            context: context,
                            description:
                                'Masukan jumlah uang dengan format yang benar');
                        return;
                      }
                      if (uangDibayar < widget.finalAmount) {
                        Notiferror.showNotif(
                            context: context,
                            description:
                                'Uang bayar tidak cukup untuk transaksi ${harganya}');
                        return;
                      }
                      bayar = 'Cash';
                      kembalian = uangDibayar - widget.finalAmount;
                      break;
                    case 1: // e-Wallet
                      bayar = 'e-Wallet';
                      uangDibayar = widget
                          .finalAmount; // Mengasumsikan uang yang dibayar sama dengan total
                      kembalian = 0;
                      break;
                    case 2: // Transfer
                      bayar = 'Transfer';
                      uangDibayar = widget
                          .finalAmount; // Mengasumsikan uang yang dibayar sama dengan total
                      kembalian = 0;
                      break;
                  }

                  // Kirim data transaksi
                  await _apitransaksi.addTransaksi(
                    widget.idOutlet,
                    widget.name,
                    bayar!,
                    widget.totalAmount,
                    widget.finalAmount,
                    uangDibayar,
                    kembalian!,
                    widget.totalPajak,
                    widget.totalOperasional,
                    widget.selectedProducts,
                    widget.listpromosiselected,
                    widget.biaya,
                  );

                  if (_apitransaksi.statusCode == 200 ||
                      _apitransaksi.statusCode == 201) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('id_outlet', widget.idOutlet);
                    pushHomepage(_apitransaksi.idTransaksi ?? 0,
                        widget.idOutlet, bayar, kembalian.toInt());
                  } else {
                    print(_apitransaksi.message);
                    Notiferror.showNotif(
                        context: context, description: _apitransaksi.message);
                  }
                },
                child: const Text(
                  'Bayar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              )),
        ],
      )),
    );
  }
}
