import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:salescheck/Model/diskonModel.dart';
import 'package:salescheck/Model/outlets.dart';
import 'package:salescheck/Model/promosi.dart';
import 'package:salescheck/Service/ApiOutlet.dart';
import 'package:salescheck/Service/ApiPromosi.dart';
import 'package:salescheck/component/filterChip.dart';
import 'package:salescheck/page/Pengaturan/Promosi/addPromosi.dart';
import 'package:salescheck/page/Pengaturan/Promosi/editPromosi.dart';
import 'package:toastification/toastification.dart';

import '../../../component/customButtonPrimary.dart';
import '../../../component/customButtonColor.dart';

class Promosipage extends StatefulWidget {
  const Promosipage({super.key});

  @override
  State<Promosipage> createState() => _PromosipageState();
}

class _PromosipageState extends State<Promosipage> {
  final Apioutlet _apioutlet = new Apioutlet();
  final Apipromosi _apipromosi = new Apipromosi();
  List<Outlets> outletList = [];
  TextEditingController search = new TextEditingController();
  final numberFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  String searchQuery = '';
  List<Diskon> diskonList = [];
  List<Diskon> diskonListsearch = [];
  List<Promosi> promosiList = [];
  List<Promosi> promosiListsearch = [];
  List<String> outletOptions = [];
  List<String> statusOptions = ['Aktif', 'Expired', 'Promo terhapus', 'Semua'];
  int indexstatus = 3;
  String? selectedOutlet = 'Outle ABC';
  Future<void> _readAndPrintProductPromosi() async {
    // Ambil produk berdasarkan outlet dan kategori
    promosiList = await _apipromosi.getPromosi();
    if (_apipromosi.statusCode == 200) {
      setState(() {
        // Perbarui daftar promosi yang sudah difilter
        promosiListsearch = promosiList.where((promosi) {
          // Jika selectedOutlet adalah 'Semua', tampilkan semua promosi tanpa filter outlet
          if (selectedOutlet == 'Semua') {
            return true;
          }

          // Jika selectedOutlet bukan 'Semua', hanya tampilkan promosi yang memiliki outlet yang sesuai
          return promosi.detailOutlet!.any((outlet) => outlet.nama!
              .toLowerCase()
              .contains(selectedOutlet!.toLowerCase()));
        }).toList();
      });
      print('Panjang Product iniliasiasi = ${promosiList.length}');
    } else {
      print('Error _readAndPrintProductData: ${_apipromosi.message}');
    }
  }

  Future<void> _refreshData() async {
    // Simulasi delay untuk menunggu data baru
    await Future.delayed(const Duration(seconds: 2));
    diskonList.clear();

    setState(() {
      promosiList.clear();
      outletList.clear();
      outletOptions.clear();
      outletOptions = ['Semua'];
      selectedOutlet = outletOptions.first;
      // Perbarui data dan setState untuk memperbarui tampilan
      _readAndPrintOutlet();
      _readAndPrintProductPromosi();
      diskonListsearch = diskonList;
      searchfunction();
    });
  }

  void notif(String title) {
    toastification.show(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(right: 16, left: 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        autoCloseDuration: const Duration(seconds: 8),
        progressBarTheme: const ProgressIndicatorThemeData(
            color: Color(0xFFFFFFFF), linearTrackColor: Color(0xFFCDCDCD)),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        primaryColor: const Color(0xFF28A745),
        backgroundColor: Colors.black,
        context: context,
        showProgressBar: false,
        closeOnClick: true,
        closeButtonShowType: CloseButtonShowType.always,
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFFFFFFFF),
        ),
        title: const Text(
          'Berhasil',
          style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w700,
              fontSize: 12),
        ),
        description: Text(
          title,
          style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w500,
              fontSize: 12),
        ));
  }

  void searchfunction() {
    setState(() {
      // Perbarui daftar promosi yang sudah difilter
      promosiListsearch = promosiList.where((promosi) {
        // Jika selectedOutlet adalah 'Semua', tampilkan semua promosi tanpa filter outlet
        if (selectedOutlet == 'Semua') {
          return true;
        }

        // Jika selectedOutlet bukan 'Semua', hanya tampilkan promosi yang memiliki outlet yang sesuai
        return promosi.detailOutlet!.any((outlet) =>
            outlet.nama!.toLowerCase().contains(selectedOutlet!.toLowerCase()));
      }).toList();
    });

    if (indexstatus != 3) {
      String status = statusOptions[indexstatus];
      if (status.isNotEmpty) {
        setState(() {
          promosiListsearch = promosiListsearch.where((promosi) {
            // Jika status adalah 'Aktif'
            if (status == 'Aktif') {
              // Promosi dianggap aktif jika 'status' adalah 'Promosi Aktif' dan 'deletedAt' adalah null
              return promosi.status == 'Promosi Aktif' &&
                  promosi.deletedAt == null;
            }
            // Jika status adalah 'Expired'
            else if (status == 'Expired') {
              // Cek apakah promosi sudah expired, misalnya jika durasi promosi sudah lewat
              return promosi.status == 'Promosi Tidak Aktif' &&
                  promosi.deletedAt == null;
            }
            // Jika status adalah 'Promo terhapus'
            else if (status == 'Promo terhapus') {
              // Promo dianggap terhapus jika 'deletedAt' tidak null
              return promosi.deletedAt != null;
            }
            return false; // Jika status tidak cocok
          }).toList();
        });
      }
    }
  }

  String formatTanggal(DateTime tanggalMulai, DateTime tanggalBerakhir) {
    final DateFormat formatter = DateFormat('d MMM yy');
    String mulai = formatter.format(tanggalMulai);
    String berakhir = formatter.format(tanggalBerakhir);
    return '$mulai - $berakhir';
  }

  String diskontypeFormat(Promosi promosi) {
    if (promosi.kategoriPromosi!.toLowerCase() == '%') {
      return '${promosi.nilaiKategori} %';
    } else {}
    return '${promosi.nilaiKategori! / 1000}rb';
  }

  bool tipeOtomatis(Promosi promosi) {
    if (promosi.tipeAktivasi == 'Otomatis') {
      return true;
    } else {
      return false;
    }
  }

  bool tipeDiskon(Promosi promosi) {
    if (promosi.kategoriPromosi == 'Rp') {
      return true;
    } else {
      return false;
    }
  }

  String outlet(Promosi promosi) {
    if (promosi.detailOutlet != null && promosi.detailOutlet!.isNotEmpty) {
      return promosi.detailOutlet!
          .map((outlet) => outlet.nama ?? '')
          .where((nama) => nama.isNotEmpty)
          .join(', ');
    } else {
      return promosi.detailOutlet!.join(
          ', '); // Jika tidak ada detail outlet, return outlet dari diskon
    }
  }

  String jadwal(Promosi promosi) {
    return promosi.pilihanHari!.join(', ');
  }

  String tanggal(Diskon diskon) {
    final formatTanggal = DateFormat('dd MMMM yyyy', 'id');

    return '${formatTanggal.format(diskon.tanggalMulai)} - ${formatTanggal.format(diskon.tanggalBerakhir)}';
  }

  bool statusDiskon(Promosi promosi) {
    if (promosi.status == 'Promosi Aktif') {
      return false;
    } else {
      return true;
    }
  }

  void _quickAccesForm(BuildContext context, Promosi promosi) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        String otomatis =
            'Promo ini akan terpasang otomatis saat checkout pesanan';
        String manual = 'Promo ini akan dipasang manual saat checkout pesanan';
        return StatefulBuilder(
          builder: (context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.only(
                  top: 16, right: 16, bottom: 24, left: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      width: 50,
                      height: 4,
                      color: const Color(0xFFE9E9E9),
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                        SvgPicture.asset(
                          'asset/image/info-circle.svg',
                          color: const Color(0xFFE5851F),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: Text(
                            tipeOtomatis(promosi) ? otomatis : manual,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFFE5851F)),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    promosi.namaPromosi ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF303030)),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    promosi.deskripsiPromosi ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF9399A7)),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  labelForm('Outlet'),
                  textForm(outlet(promosi)),
                  labelForm('Kategori'),
                  textForm(
                      'Potongan ${tipeDiskon(promosi) ? diskontypeFormat(promosi) : diskontypeFormat(promosi)}'),
                  labelForm('Tipe Aktivasi'),
                  textForm(promosi.tipeAktivasi ?? ''),
                  labelForm('Minimal Pembelian'),
                  textForm(numberFormat.format(promosi.minimalBeli)),
                  Divider(
                    color: const Color(0xFF000000).withOpacity(0.1),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  labelForm('Tanggal'),
                  textForm(promosi.durasi ?? ''),
                  labelForm('Jam'),
                  textForm('${promosi.jamMulai} - ${promosi.jamBerakhir}'),
                  labelForm('Hari Promo'),
                  textForm(jadwal(promosi)),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: CustombuttonColor(
                              color: const Color(0xFFF6F6F6),
                              alignment: Alignment.center,
                              height: 48,
                              onPressed: () {
                                Navigator.pop(context);
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
                          width: 15,
                        ),
                        Flexible(
                          child: customButtonPrimary(
                              alignment: Alignment.center,
                              height: 48,
                              onPressed: () async {
                                Navigator.pop(context);
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Editpromosi(
                                            promosi: promosi,
                                            outletOptions: outletList)));

                                if (result != null) {
                                  final message = result['message'];
                                  final isDeleted = result['isDeleted'];
                                  // ignore: use_build_context_synchronously

                                  print(message);
                                  print(isDeleted);
                                  if (isDeleted == true) {
                                    notif(message);
                                  } else {
                                    notif(message);
                                  }

                                  _refreshData();
                                }
                              },
                              child: const Text(
                                'Edit Promosi',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFFFFF)),
                              )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _readAndPrintOutlet() async {
    outletList = await _apioutlet.getAllOutletApi();

    setState(() {
      for (var element in outletList) {
        outletOptions.add(element.namaOutlet ?? '');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    outletOptions = ['Semua'];
    selectedOutlet = outletOptions.first;
    searchfunction;
    _readAndPrintOutlet();
    _readAndPrintProductPromosi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Promosi',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'asset/promosi/shop.svg',
                    color: const Color(0xFFAAAAAA),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          iconStyleData: IconStyleData(
                            icon: Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'asset/image/arrow-down.svg',
                                height: 12,
                                width: 12,
                                color: const Color(0xFFA8A8A8),
                              ),
                            ),
                          ),
                          isExpanded: true,
                          isDense: false,
                          selectedItemBuilder: (context) {
                            return outletOptions.map((String item) {
                              return Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF000000),
                                ),
                              );
                            }).toList();
                          },
                          items: outletOptions.map((String item) {
                            return DropdownMenuItem<String>(
                                value: item,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 12, top: 12),
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 1,
                                              color: Color(0xFFE1E1E1)))),
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
                          onChanged: (String? value) {
                            setState(() {
                              selectedOutlet = value;
                              searchfunction();
                            });
                            print(diskonListsearch.length);
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            height: 40,
                            width: double.infinity,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            height: 40,
                          ),
                          dropdownStyleData: const DropdownStyleData(
                              elevation: 4,
                              maxHeight: 160,
                              useSafeArea: true,
                              width: 350,
                              offset: Offset(-25, -15),
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
          Container(
            height: 55,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: statusOptions.length - 1,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: Filterchip(
                    selected: index == indexstatus ? true : false,
                    onSelected: (p0) {
                      setState(() {
                        // Jika filter yang sama ditekan, reset ke "Semua"
                        if (indexstatus == index) {
                          indexstatus = 3; // Set ke "Semua"
                        } else {
                          indexstatus = index; // Update ke filter baru
                        }
                      });

                      // Logika Filter
                      switch (indexstatus) {
                        case 0: // Aktif
                          setState(() {
                            index = indexstatus;
                          });
                          break;
                        case 1: // Expired
                          index = indexstatus;
                          break;
                        case 2: // Promo terhapus
                          index = indexstatus;
                          break;
                        case 3: // Semua
                          index = indexstatus; // Tidak ada filter
                          break;
                      }
                      setState(() {
                        searchfunction();
                      });
                      print(indexstatus);
                    },
                    child: Text(
                      statusOptions[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: indexstatus == index
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF09090B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: promosiListsearch.isEmpty
                          ? Container(
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
                                    'Belum ada promosi tersedia',
                                    style: TextStyle(
                                        color: Color(0xFFB1B5C0),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ))
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16, top: 0),
                              shrinkWrap: true,
                              itemCount: promosiListsearch.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _quickAccesForm(
                                        context, promosiListsearch[index]);
                                  },
                                  child: Container(
                                    height: 66,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                        color: statusDiskon(
                                                promosiListsearch[index])
                                            ? const Color(0xFFEAEAED)
                                            : const Color(0xFFFFFFFF),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              promosiListsearch[index]
                                                      .namaPromosi ??
                                                  '',
                                              style: const TextStyle(
                                                  color: Color(0xFF303030),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  promosiListsearch[index]
                                                          .tipeAktivasi ??
                                                      '',
                                                  style: const TextStyle(
                                                      color: Color(0xFF979899),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                      color: const Color(
                                                              0xFF979899)
                                                          .withOpacity(0.5),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  promosiListsearch[index]
                                                          .durasi ??
                                                      '',
                                                  style: const TextStyle(
                                                      color: Color(0xFF979899),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'asset/promosi/receipt-disscount.svg',
                                                color: statusDiskon(
                                                        promosiListsearch[
                                                            index])
                                                    ? const Color(0xFF717179)
                                                    : const Color(0xFF2E6CE9),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                diskontypeFormat(
                                                    promosiListsearch[index]),
                                                style: TextStyle(
                                                    color: statusDiskon(
                                                            promosiListsearch[
                                                                index])
                                                        ? const Color(
                                                            0xFF717179)
                                                        : const Color(
                                                            0xFF2E6CE9),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Addpromosi(
                                            outletOptions: outletList,
                                          )));
                              if (result != null) {
                                notif(result);
                                _refreshData();
                              }
                            },
                            child: Container(
                              height: 48.0,
                              // width: 170,
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
                                    'Tambah Promosi',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ))
              ],
            ),
          )
        ],
      )),
    );
  }

  Widget labelForm(String judul) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        judul,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFAAAAAA)),
      ),
    );
  }

  Widget textForm(String judul) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        judul,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF09090B)),
      ),
    );
  }
}
