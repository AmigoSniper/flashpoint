import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svgProvide;
import 'package:intl/intl.dart';
import 'package:salescheck/Model/outlets.dart';
import 'package:salescheck/Service/ApiOutlet.dart';
import 'package:salescheck/Service/ApiProduct.dart';
import 'package:salescheck/Service/ApiPromosi.dart';
import 'package:salescheck/Service/ApiTransaksi.dart';
import 'package:salescheck/component/notifError.dart';
import 'package:salescheck/page/Detailorder/detailorder.dart';
import 'package:salescheck/page/Stockhabis/stockHabis.dart';
import 'package:salescheck/page/Transaksi/buktiPembayaran.dart';
import 'package:salescheck/page/Transaksi/testTransaksi.dart';
import 'package:salescheck/page/Transaksi/transaksiAdd.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/Transaksi.dart';
import '../../Model/kasirModel.dart';
import '../../Service/Api.dart';
import '../../Service/ApiKasir.dart';
import 'landingPage.dart';

class Homepage extends StatefulWidget {
  final Function navigateToStockTab;
  final int? idOutlab;
  final int? indexOutlab;
  const Homepage(
      {super.key,
      required this.navigateToStockTab,
      this.idOutlab,
      this.indexOutlab});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // final Api _api = Api();
  final Apioutlet _api = Apioutlet();
  final Apiproduct _apiproduct = Apiproduct();
  final Apitransaksi _apitransaksi = Apitransaksi();
  final Apikasir _apikasir = Apikasir();
  late Future<void> _loadDataFuture;
  bool isSelectTab1 = true;
  bool isSelectTab2 = false;
  bool isSelectTab3 = false;
  List<Outlets> outletOption = [];
  List<Transaksi> transaksiList = [];
  String tunai = 'asset/image/pembayaranTunai.svg';
  String eWallet = 'asset/image/pembayaranEwallet.svg';
  String transfer = 'asset/image/pembayaranTransfer.svg';
  final numberFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  String? selectedOutlet;
  String? selectedTime;
  List<String> outletOptions = [];

  int totalPendapatan = 10000000;
  int transaksi = 200;
  int pelanggan = 200;
  int stockhabis = 0;
  int IdOulet = 0;
  List<String> timeOptions = ['Harian', 'Mingguan', 'Bulanan', 'Tahunan'];
  final ScrollController _scrollController = ScrollController();

  String pembayaran(String jenis) {
    if (jenis.toLowerCase() == "cash") {
      return tunai;
    } else if (jenis.toLowerCase() == "transfer") {
      return transfer;
    } else if (jenis.toLowerCase() == "e-wallet") {
      return eWallet;
    } else {
      return '';
    }
  }

  Future<void> selectRefreshOutlet() async {
    final prefs = await SharedPreferences.getInstance();
    final outlet = outletOption.firstWhere(
      (outlet) => outlet.namaOutlet == selectedOutlet,
      orElse: () => Outlets(),
    );

    // Ambil id_outlet
    int id_outlet = outlet.idOutlet ?? 0;

    if (id_outlet != null) {
      print('Selected Outlet ID: $id_outlet');
      await prefs.setInt('id_outlet', id_outlet);
      await _readAndPrintPegawaiKasir();

      setState(() {
        IdOulet = id_outlet;
      });
    } else {
      print('Outlet not found for selected name: $selectedOutlet');
    }
  }

  Future<void> _readAndPrintPegawaiKasir() async {
    final prefs = await SharedPreferences.getInstance();
    final int idOutlet = prefs.getInt('id_outlet') ?? 0;
    final String? data = prefs.getString('kasir');
    await _apikasir.addKasir();
    // Mendapatkan jam saat ini
    final currentHour = DateTime.now().hour;

    // Memeriksa apakah berada dalam rentang waktu 9 pagi hingga 9 malam
    final isInAllowedTimeRange = currentHour >= 1 && currentHour < 21;

    if (data != null) {
      // Data kasir ada, decode JSON-nya
      final jsonData = jsonDecode(data) as Map<String, dynamic>;
      kasirModel kasir = kasirModel.fromJson(jsonData);

      // Periksa apakah berada dalam rentang waktu yang diizinkan dan ID outlet berbeda
      if (isInAllowedTimeRange) {}
    } else {
      // Data kasir kosong, buat kasir baru jika dalam rentang waktu yang diizinkan
      if (isInAllowedTimeRange) {
        await _apikasir.addKasir();
        print('Data Kasir kosong, membuat kasir baru.');
      } else {
        print('Diluar jam 9 pagi - 9 malam, tidak ada tindakan.');
      }
    }
  }

  Future<void> getalloutletreturnoutlet() async {
    final prefs = await SharedPreferences.getInstance();
    outletOption = await _api.getAllOutletApi();

    if (_api.statusCode == 200 || _api.statusCode == 201) {
      setState(() {
        for (var element in outletOption) {
          outletOptions.add(element.namaOutlet!);
        }
        int outletIndex = outletOption
            .indexWhere((outlet) => outlet.idOutlet == widget.idOutlab);

        selectedOutlet = widget.idOutlab == null
            ? outletOptions.first
            : outletOptions[outletIndex];
      });
      int? id_outlet = widget.indexOutlab == null
          ? outletOption.first.idOutlet
          : widget.idOutlab;
      await prefs.setInt('id_outlet', id_outlet ?? 0);
      await _readAndPrintPegawaiKasir();
      int stocksisa = await _apiproduct.productHabis(id_outlet!);
      setState(() {
        stockhabis = stocksisa;
      });
    } else {
      Notiferror.showNotif(context: context, description: _api.message);
    }
  }

  Future<void> getTransaksi() async {
    final prefs = await SharedPreferences.getInstance();
    final int idOutlet = prefs.getInt('id_outlet') ?? 0;
    transaksiList = await _apitransaksi.getTransaksi(idOutlet);
    if (_apitransaksi.statusCode == 200 || _apitransaksi.statusCode == 201) {
      setState(() {
        transaksiList =
            transaksiList.reversed.take(3).toList().reversed.toList();
        print(transaksiList.length);
      });
    } else {
      Notiferror.showNotif(
          context: context, description: _apitransaksi.message);
    }
  }

  Future<void> _refreshData() async {
    outletOption.clear();
    outletOptions.clear();
    await getalloutletreturnoutlet();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // _readAndPrintOutletData();
    getalloutletreturnoutlet();
    selectedTime = timeOptions.first;
    _loadDataFuture = getTransaksi();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          height: 75,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.zero,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outlet utama',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFF818796),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  iconStyleData: IconStyleData(
                                    icon: Container(
                                      padding: const EdgeInsets.all(5.0),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  isExpanded: true,
                                  isDense: false,
                                  selectedItemBuilder: (context) {
                                    return outletOptions.map((String item) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF000000),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.all(5.0),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFFFFF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: SvgPicture.asset(
                                              'asset/image/arrow-down.svg',
                                              color: const Color(0xFF0EA5E9),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                  items: outletOptions.map((String item) {
                                    return DropdownMenuItem<String>(
                                        value: item,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              bottom: 12,
                                              top: 12),
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width: 1,
                                                      color:
                                                          Color(0xFFE1E1E1)))),
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF717179),
                                            ),
                                          ),
                                        ));
                                  }).toList(),
                                  value: selectedOutlet,
                                  onChanged: (String? value) async {
                                    await _refreshData();
                                    setState(() {
                                      selectedOutlet = value;
                                    });
                                    int select =
                                        outletOptions.indexOf(value ?? '');
                                    await selectRefreshOutlet();
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (_) => Landingpage(
                                                indexOutlab: select,
                                                idOutlab: IdOulet,
                                              )),
                                    );
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    height: 40,
                                    width: 213,
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    height: 42,
                                  ),
                                  dropdownStyleData: const DropdownStyleData(
                                      elevation: 4,
                                      maxHeight: 160,
                                      width: 183,
                                      useSafeArea: true,
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: () async {},
                icon: SvgPicture.asset(
                  'asset/image/notification.svg',
                  width: 20,
                  height: 20,
                ),
                padding: EdgeInsets.zero,
                color: const Color(0xFF000000),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFFFF),
                  side: const BorderSide(color: Color(0xFFEBEEF2), width: 1.0),
                  shape: const CircleBorder(),
                ),
              )
            ],
          ),
        ),
        Expanded(
            child: Stack(
          children: [
            SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        height: 145,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2EC0E9),
                                Color(0xFF2E6CE9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Analisa',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFFFFFF)),
                                ),
                                Container(
                                  width: 90,
                                  height: 24,
                                  padding: const EdgeInsets.only(
                                      top: 4, bottom: 4, right: 8, left: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      color: const Color(0xFFFFFFFF)
                                          .withOpacity(0.3)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      iconStyleData: IconStyleData(
                                        icon: SvgPicture.asset(
                                          'asset/image/arrow-down.svg',
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                      ),
                                      isExpanded: true,
                                      isDense: false,
                                      selectedItemBuilder: (context) {
                                        return timeOptions
                                            .map((String item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xffFFFFFF)),
                                                  ),
                                                ))
                                            .toList();
                                      },
                                      items: timeOptions
                                          .map((String item) =>
                                              DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12,
                                                            right: 12,
                                                            bottom: 12,
                                                            top: 12),
                                                    width: double.infinity,
                                                    decoration: const BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                width: 1,
                                                                color: Color(
                                                                    0xFFE1E1E1)))),
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                              0xff717179)),
                                                    ),
                                                  )))
                                          .toList(),
                                      value: selectedTime,
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedTime = value;
                                        });
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        height: 40,
                                      ),
                                      menuItemStyleData:
                                          const MenuItemStyleData(
                                        padding: EdgeInsets.only(),
                                        height: 42,
                                      ),
                                      dropdownStyleData:
                                          const DropdownStyleData(
                                              offset: Offset(-10, -10),
                                              maxHeight: 200,
                                              width: 93,
                                              useSafeArea: true,
                                              padding: EdgeInsets.zero,
                                              elevation: 4,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                  color: Color(0xFFF6F8FA))),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Text(
                              'Total Pendapatan',
                              style: TextStyle(
                                  color: Color(0xFFEFEFEF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              height: 42,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    numberFormat.format(totalPendapatan),
                                    style: const TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'asset/image/arrow-down-increase.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                        const Text(
                                          '+2%',
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
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
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 115,
                                height: 90,
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pelanggan',
                                      style: const TextStyle(
                                          color: Color(0xFF717179),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '$pelanggan',
                                      style: const TextStyle(
                                          color: Color(0xFF303030),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )),
                            Container(
                                width: 115,
                                height: 90,
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Transaksi',
                                      style: const TextStyle(
                                          color: Color(0xFF717179),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '$transaksi',
                                      style: const TextStyle(
                                          color: Color(0xFF303030),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )),
                            Container(
                                width: 115,
                                height: 90,
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Text(
                                      'Stock Habis',
                                      style: TextStyle(
                                          color: Color(0xFF717179),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: 30,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$stockhabis',
                                            style: const TextStyle(
                                                color: Color(0xFFF43F5E),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          IconButton(
                                              iconSize: 30,
                                              style: IconButton.styleFrom(
                                                fixedSize: const Size(30, 30),
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.zero,
                                                backgroundColor:
                                                    const Color(0xFFF6F8FA),
                                              ),
                                              constraints:
                                                  const BoxConstraints(),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                // setState(() {
                                                //   widget.navigateToStockTab(2);
                                                // });
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Stockhabis(),
                                                    ));
                                              },
                                              icon: SvgPicture.asset(
                                                'asset/image/arrow-right.svg',
                                                width: 16,
                                                height: 16,
                                              )),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transaksi Terbaru',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000000)),
                                ),
                                SizedBox(
                                  height: 24,
                                  width: 45,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: IconButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        backgroundColor:
                                            const Color(0xFFFFFFFF),
                                        surfaceTintColor:
                                            const Color(0xFFFFFFFF)),
                                    child: const Text(
                                      'Lihat',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0EA5E9)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                                height: 400,
                                child: FutureBuilder(
                                    future: _loadDataFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (snapshot.hasError) {
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
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              ],
                                            ));
                                      } else {
                                        if (transaksiList.isEmpty) {
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
                                                        color:
                                                            Color(0xFFB1B5C0),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )
                                                ],
                                              ));
                                        } else {
                                          return ListView.builder(
                                            controller: _scrollController,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: transaksiList.length,
                                            padding: const EdgeInsets.only(
                                                bottom: 50),
                                            itemBuilder: (context, index) {
                                              String logoPembayaran =
                                                  pembayaran(
                                                      transaksiList[index]
                                                              .tipeBayar ??
                                                          '');
                                              String tanggalTransaksi =
                                                  DateFormat(
                                                          'MMM dd, yyyy hh:mm')
                                                      .format(DateTime.parse(
                                                          transaksiList[index]
                                                                  .createdAt ??
                                                              ''));
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Detailorder(
                                                                transaksi:
                                                                    transaksiList[
                                                                        index],
                                                                outlateName:
                                                                    selectedOutlet ??
                                                                        '',
                                                                iconjenisPembayaran:
                                                                    logoPembayaran,
                                                              )));
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 8),
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  width: double.infinity,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFFFFFFFF),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width: 41,
                                                              height: 41,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          11,
                                                                      horizontal:
                                                                          10),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  color: const Color(
                                                                          0xFF2E6CE9)
                                                                      .withOpacity(
                                                                          0.12)),
                                                              child: SvgPicture
                                                                  .asset(
                                                                logoPembayaran,
                                                                height: 20,
                                                                width: 20,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  '${transaksiList[index].penjualanId}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Color(
                                                                          0xFF303030)),
                                                                ),
                                                                const SizedBox(
                                                                    height: 4),
                                                                Text(
                                                                  tanggalTransaksi,
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: const Color(
                                                                          0xFF717179)),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            numberFormat.format(
                                                                transaksiList[
                                                                        index]
                                                                    .total),
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                    0xFF2E6CE9)),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            '${transaksiList[index].detailtransaksi!.length} item',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                    0xFF717179)),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }
                                    })),
                            const SizedBox(
                              height: 100,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Transaksiadd(
                                      outlateName: selectedOutlet ?? '',
                                    )));
                      },
                      child: Container(
                        height: 48.0,
                        // width: 160,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              offset: const Offset(2, 4),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                          color: const Color(0xFF2E6CE9),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Color(0xFFFFFFFF),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Tambah Transaksi',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ))
          ],
        ))
      ],
    );
  }

  Widget TabButton(BuildContext context, String textTitle, int tabIndex) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: (tabIndex == 1 && isSelectTab1) ||
                        (tabIndex == 2 && isSelectTab2) ||
                        (tabIndex == 3 && isSelectTab3)
                    ? Colors.black.withOpacity(0.2)
                    : Colors.transparent,
                spreadRadius: -1,
                blurRadius: 2.7,
                offset: const Offset(2, 2),
              ),
            ],
            color: (tabIndex == 1 && isSelectTab1) ||
                    (tabIndex == 2 && isSelectTab2) ||
                    (tabIndex == 3 && isSelectTab3)
                ? const Color(0xFFFFFFFF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (tabIndex == 1 && !isSelectTab1) {
                  isSelectTab1 = true;
                  isSelectTab2 = false;
                  isSelectTab3 = false;
                } else if (tabIndex == 2 && !isSelectTab2) {
                  isSelectTab1 = false;
                  isSelectTab2 = true;
                  isSelectTab3 = false;
                } else if (tabIndex == 3 && !isSelectTab3) {
                  isSelectTab1 = false;
                  isSelectTab2 = false;
                  isSelectTab3 = true;
                }
              });
            },
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  (tabIndex == 1 && isSelectTab1) ||
                          (tabIndex == 2 && isSelectTab2) ||
                          (tabIndex == 3 && isSelectTab3)
                      ? const Color(0xFFFFFFFF)
                      : Colors.transparent,
                ),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                overlayColor: WidgetStateProperty.all(Colors.transparent)),
            child: Center(
              child: Text(textTitle,
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: (tabIndex == 1 && isSelectTab1) ||
                            (tabIndex == 2 && isSelectTab2) ||
                            (tabIndex == 3 && isSelectTab3)
                        ? const Color(0xFF141419)
                        : const Color(0xFFB1B5C0),
                  )),
            )),
      ),
    );
  }
}
