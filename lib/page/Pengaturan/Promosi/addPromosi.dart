import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:salescheck/Model/outlets.dart';
import 'package:salescheck/Service/ApiPromosi.dart';
import 'package:salescheck/component/customDropDown.dart';
import 'package:salescheck/component/inputTextField.dart';

import '../../../component/customButtonPrimary.dart';
import '../../../component/customButtonColor.dart';

class Addpromosi extends StatefulWidget {
  final List<Outlets> outletOptions;
  const Addpromosi({super.key, required this.outletOptions});

  @override
  State<Addpromosi> createState() => _AddpromosiState();
}

class _AddpromosiState extends State<Addpromosi> {
  final Apipromosi _apipromosi = new Apipromosi();
  final numberFormat = NumberFormat('#,##0', 'id');
  final TextEditingController namecontroler = TextEditingController();
  final TextEditingController deskripsicontroler = TextEditingController();
  final TextEditingController tipediskoncontroler = TextEditingController();
  final TextEditingController tanggalMulaicontroler = TextEditingController();
  final TextEditingController minimalPembeliancontroler =
      TextEditingController();
  final TextEditingController tanggalBerakhircontroler =
      TextEditingController();
  final TextEditingController jamMulaicontroler = TextEditingController();
  final TextEditingController jamBerakhircontroler = TextEditingController();
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeDeskripsi = FocusNode();
  FocusNode _focusfocusTipeDiskon = FocusNode();
  FocusNode _focusNodeminimalPembelian = FocusNode();
  bool focusname = false;
  bool focusDeskripsi = false;
  bool focusTipeDiskon = false;
  bool focusminimalPembelian = false;
  int length = 0;
  String? aktivasiSelect;
  String? tipeDiskonSelect;
  String? tipeAktivasiSelect;
  List<String> aktivasiOptions = ['Otomatis', 'Manual'];
  List<String> tipeDiskonOptions = ['Tipe Potongan (%)', 'Tipe Potongan (Rp)'];
  String? outletSelect;
  List<String> outletOptions = [
    'Semua',
  ];
  List<String> outletsort = [
    'Semua',
  ];
  List<Outlets> idOutlet = [];
  List<String> days = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu"
  ];
  List<String> listoutletSelect = [];
  List<String> daysSelect = [];
  void _quickAccesForm(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Daftar boolean untuk setiap hari yang dipilih
        List<bool> daysSelected = List.generate(7, (index) => false);
        bool alldays = false;
        List<String> daysSelectModal = [];
        return StatefulBuilder(
          builder: (context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.only(
                  top: 16, right: 16, bottom: 24, left: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    color: const Color(0xFFE9E9E9),
                    margin: const EdgeInsets.only(bottom: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        alldays = !alldays;
                        if (alldays) {
                          // Jika "Setiap Hari" dipilih, semua hari masuk ke daysSelect
                          daysSelected = List.generate(7, (index) => true);
                          daysSelectModal = List.from(days);
                        } else {
                          // Jika "Setiap Hari" dibatalkan, kosongkan daysSelect
                          daysSelectModal.clear();
                          for (int i = 0; i < daysSelected.length; i++) {
                            daysSelected[i] =
                                false; // Tandai semua hari sebagai tidak terpilih
                          }
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: alldays
                            ? const Color(0xFFE3EDFF)
                            : const Color(0xFFF6F6F6),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Setiap Hari',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF09090B),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: alldays
                                  ? const Color(0xFF2E6CE9)
                                  : const Color(0xFFD3D3D3),
                            ),
                            child: alldays
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Text(
                      'Custom',
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (alldays) {
                                daysSelectModal.remove(days[index]);
                              }
                              daysSelected[index] = !daysSelected[index];
                              if (daysSelected[index] == true) {
                                daysSelectModal.add(days[index]);
                              } else {
                                daysSelectModal.remove(days[index]);
                              }

                              // Jika semua hari dipilih, ubah `alldays` menjadi true
                              alldays = daysSelected
                                  .every((selected) => selected == true);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            width: double.infinity,
                            height: 44,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: daysSelected[index]
                                  ? const Color(0xFFE3EDFF)
                                  : const Color(0xFFF6F6F6),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  days[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xFF09090B),
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: daysSelected[index]
                                        ? const Color(0xFF2E6CE9)
                                        : const Color(0xFFD3D3D3),
                                  ),
                                  child: daysSelected[index]
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
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
                            onPressed: () {
                              Navigator.pop(context);
                              // Logika untuk menyimpan hasil pilihan
                              daysSelect.clear;
                              setState(() {
                                daysSelect = sortDays(daysSelectModal);
                              });
                              print("Days selected: $daysSelect");
                            },
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmModal(BuildContext context, String name) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 16, right: 16, bottom: 24, left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Apakah anda yakin ingin menyimpan Diskon $name',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000)),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
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
                          await _apipromosi.addPromosiApi(
                              nama: namecontroler.text,
                              description: deskripsicontroler.text,
                              tipeAktivasi: tipeAktivasiSelect ?? '',
                              minimalBeli: int.parse(minimalPembeliancontroler
                                  .text
                                  .replaceAll(RegExp(r'[^\d]'), '')),
                              kategori: tipeDiskonSelect == 'Tipe Potongan (%)'
                                  ? '%'
                                  : 'Rp',
                              nilaikategori: int.parse(tipediskoncontroler.text
                                  .replaceAll(RegExp(r'[^\d]'), '')),
                              tanggalMulai: tanggalMulaicontroler.text,
                              tanggalBerakhir: tanggalBerakhircontroler.text,
                              jamMulai: jamMulaicontroler.text,
                              jamBerakhir: jamBerakhircontroler.text,
                              hari: daysSelect,
                              idOutlet: idOutlet);
                          if (_apipromosi.statusCode == 201) {
                            Navigator.pop(context);
                            Navigator.pop(context,
                                'Promosi ${namecontroler.text} berhasil ditambahkan');
                          } else {}
                        },
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
            ],
          ),
        );
      },
    );
  }

  List<String> sortDays(List<String> selectedDays) {
    List<String> weekOrder = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
      "Senin"
    ];

    selectedDays
        .sort((a, b) => weekOrder.indexOf(a).compareTo(weekOrder.indexOf(b)));

    return selectedDays.toSet().toList();
  }

  String selectdaysFunction(List<String> daysSelect) {
    if (daysSelect.isEmpty) {
      return 'Setiap hari';
    } else {
      if (daysSelect.length == 7) {
        return 'Setiap Hari';
      } else {
        return daysSelect.map((day) => day.substring(0, 3)).join(', ');
      }
    }
  }

  bool validateForm() {
    // Cek jika semua controller TextEditingController tidak kosong
    // if (namecontroler.text.isEmpty ||
    //     deskripsicontroler.text.isEmpty ||
    //     tipediskoncontroler.text.isEmpty ||
    //     tanggalMulaicontroler.text.isEmpty ||
    //     tanggalBerakhircontroler.text.isEmpty ||
    //     jamMulaicontroler.text.isEmpty ||
    //     jamBerakhircontroler.text.isEmpty) {
    //   return false;
    // }

    // // Cek jika semua select yang diperlukan tidak null atau kosong
    // if (aktivasiSelect!.isEmpty ||
    //     tipeDiskonSelect!.isEmpty ||
    //     tipeAktivasiSelect!.isEmpty ||
    //     outletSelect!.isEmpty) {
    //   return false;
    // }

    // // Cek jika list multi-select memiliki setidaknya satu pilihan
    // if (listoutletSelect.isEmpty || daysSelect.isEmpty) {
    //   return false;
    // }

    // Jika semua pengecekan lolos, berarti form valid
    return true;
  }

  Future<void> _readAndPrintOutlet() async {
    setState(() {
      for (var element in widget.outletOptions) {
        outletOptions.add(element.namaOutlet ?? '');
        outletsort.add(element.namaOutlet ?? '');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _readAndPrintOutlet();
    tipeAktivasiSelect = aktivasiOptions.first;
    jamMulaicontroler.text = '00:00';
    jamBerakhircontroler.text = '23:59';
    minimalPembeliancontroler.addListener(() {
      String text =
          minimalPembeliancontroler.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isNotEmpty) {
        final formattedValue = numberFormat.format(int.parse(text));
        minimalPembeliancontroler.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    });
    _focusNodeName.addListener(() {
      setState(() {
        focusname = _focusNodeName.hasFocus;
      });
    });
    _focusNodeDeskripsi.addListener(() {
      setState(() {
        focusDeskripsi = _focusNodeDeskripsi.hasFocus;
      });
    });
    _focusfocusTipeDiskon.addListener(() {
      setState(() {
        focusTipeDiskon = _focusfocusTipeDiskon.hasFocus;
      });
    });
    _focusNodeminimalPembelian.addListener(() {
      setState(() {
        focusminimalPembelian = _focusNodeminimalPembelian.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNodeName.dispose();
    _focusNodeDeskripsi.dispose();
    _focusNodeminimalPembelian.dispose();
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
          'Promosi',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outlet',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF09090B)),
                          ),
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                labelForm('Atur outlet'),
                                SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Customdropdown(
                                          data: outletOptions,
                                          onChanged: (String? newvalue) {
                                            if (newvalue != null) {
                                              if (newvalue.toLowerCase() ==
                                                  'semua') {
                                                for (var i = 1;
                                                    i < outletOptions.length;
                                                    i++) {
                                                  setState(() {
                                                    listoutletSelect
                                                        .add(outletOptions[i]);
                                                    idOutlet.add(widget
                                                        .outletOptions[i - 1]);
                                                  });
                                                }

                                                setState(() {
                                                  outletOptions.clear();
                                                  outletOptions.add('Semua');
                                                });
                                                print(
                                                    'Panjang widget outlet =${idOutlet.length}');
                                              } else {
                                                setState(() {
                                                  listoutletSelect
                                                      .add(newvalue);

                                                  int selectedIndex =
                                                      outletOptions
                                                          .indexOf(newvalue);
                                                  idOutlet.add(
                                                      widget.outletOptions[
                                                          selectedIndex - 1]);

                                                  outletOptions
                                                      .remove(newvalue);
                                                });
                                                print(
                                                    'Panjang widget outlet =${idOutlet.length}');
                                              }
                                            }
                                          },
                                          hintText: 'Pilih Outlet',
                                          colorHint: const Color(0xFF09090B),
                                          heightItem: 50)
                                    ],
                                  ),
                                ),
                                listoutletSelect.isEmpty
                                    ? const SizedBox.shrink()
                                    : SizedBox(
                                        height: 56,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Expanded(
                                                child: SizedBox(
                                              height: 40,
                                              width: double.infinity,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    listoutletSelect.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 16),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 8),
                                                      decoration: const BoxDecoration(
                                                          color:
                                                              Color(0xFF2E6CE9),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          28))),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            listoutletSelect[
                                                                index],
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                    0xFFFFFFFF)),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Container(
                                                            width: 16,
                                                            height: 16,
                                                            decoration: const BoxDecoration(
                                                                color: Color(
                                                                    0xFFFFFFFF),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            100))),
                                                            child: IconButton(
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .compact,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              onPressed: () {
                                                                setState(() {
                                                                  // Kembalikan outlet yang dihapus ke outletOptions
                                                                  outletOptions.add(
                                                                      listoutletSelect[
                                                                          index]);
                                                                  outletOptions
                                                                      .sort((a,
                                                                          b) {
                                                                    // Pastikan 'Semua' tetap di atas
                                                                    if (a ==
                                                                        'Semua')
                                                                      return -1;
                                                                    if (b ==
                                                                        'Semua')
                                                                      return 1;

                                                                    // Jika tidak, urutkan berdasarkan urutan yang ada di outletList
                                                                    int indexA =
                                                                        outletsort
                                                                            .indexOf(a);
                                                                    int indexB =
                                                                        outletsort
                                                                            .indexOf(b);

                                                                    // Jika elemen tidak ada di outletList, beri nilai lebih tinggi (terakhir diurutkan)
                                                                    if (indexA ==
                                                                        -1)
                                                                      return 1;
                                                                    if (indexB ==
                                                                        -1)
                                                                      return -1;

                                                                    return indexA
                                                                        .compareTo(
                                                                            indexB); // Urutkan berdasarkan urutan di outletList
                                                                  });
                                                                  // Hapus outlet dari listoutletSelect
                                                                  listoutletSelect
                                                                      .removeAt(
                                                                          index);
                                                                  // Kembalikan outlet yang dihapus dari idOutlet (jika perlu)
                                                                  idOutlet
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                                print(
                                                                    'Panjang widget outlet =${idOutlet.length}');
                                                              },
                                                              icon: const Icon(
                                                                size: 13,
                                                                Icons
                                                                    .close_rounded,
                                                                color: Color(
                                                                    0xFF2E6CE9),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ));
                                                },
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Promosi',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF09090B)),
                          ),
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                labelForm('Nama Promosi'),
                                Inputtextfield(
                                  keyboardType: TextInputType.text,
                                  controller: namecontroler,
                                  focus: _focusNodeName,
                                  hintText: 'Masukkan nama promosi',
                                ),
                                labelForm('Deskripsi'),
                                Inputtextfield(
                                  hintText: 'Masukan Deskripsi',
                                  keyboardType: TextInputType.text,
                                  controller: deskripsicontroler,
                                  focus: _focusNodeDeskripsi,
                                  maxLength: 200,
                                  minline: 3,
                                  maxline: 3,
                                  onChanged: (value) {
                                    setState(() {
                                      length = deskripsicontroler.text.length;
                                    });
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '$length/200 char',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF979899)),
                                  ),
                                ),
                                // const SizedBox(
                                //   height: 16,
                                // ),
                                labelForm('Kategori'),
                                SizedBox(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Customdropdown(
                                            width: 200,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 16),
                                            data: tipeDiskonOptions,
                                            selectValue: tipeDiskonSelect,
                                            onChanged: (String? value) {
                                              setState(() {
                                                tipediskoncontroler.clear();
                                                tipeDiskonSelect = value!;
                                              });
                                            },
                                            hintText: 'Tipe Potongan',
                                            heightItem: 50),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Flexible(
                                            child: Inputtextfield(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 16),
                                          height: 50,
                                          hintText: 'Nilai',
                                          keyboardType: TextInputType.number,
                                          controller: tipediskoncontroler,
                                          focus: _focusfocusTipeDiskon,
                                          onChanged: (value) {
                                            if (tipeDiskonSelect!
                                                    .toLowerCase() ==
                                                'tipe potongan (%)') {
                                              if (value.isNotEmpty) {
                                                int? number =
                                                    int.tryParse(value);
                                                if (number != null &&
                                                    number > 100) {
                                                  tipediskoncontroler.text =
                                                      '100';
                                                  tipediskoncontroler
                                                          .selection =
                                                      TextSelection
                                                          .fromPosition(
                                                    TextPosition(
                                                        offset:
                                                            tipediskoncontroler
                                                                .text.length),
                                                  );
                                                }
                                              }
                                            } else {
                                              String cleanValue =
                                                  value.replaceAll('.', '');

                                              final numberFormat =
                                                  NumberFormat('#,##0', 'id');
                                              int? number =
                                                  int.tryParse(cleanValue);

                                              if (number != null) {
                                                setState(() {
                                                  // Format angka dengan titik setiap 3 digit
                                                  tipediskoncontroler.text =
                                                      numberFormat
                                                          .format(number);
                                                  tipediskoncontroler
                                                          .selection =
                                                      TextSelection
                                                          .fromPosition(
                                                    TextPosition(
                                                        offset:
                                                            tipediskoncontroler
                                                                .text.length),
                                                  );
                                                });
                                              }
                                            }
                                          },
                                        )),
                                      ]),
                                ),
                                labelForm('Tipe Aktivasi'),
                                Customdropdown(
                                    data: aktivasiOptions,
                                    selectValue: tipeAktivasiSelect,
                                    onChanged: (String? value) {
                                      setState(() {
                                        tipeAktivasiSelect = value!;
                                      });
                                    },
                                    hintText: 'Tipe Aktivasi',
                                    heightItem: 50),
                                labelForm('Minimal Pembelian (Opsional)'),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 0),
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
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
                                              color: Color(0xFFA8A8A8),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Flexible(
                                            child: Inputtextfield(
                                          keyboardType: TextInputType.number,
                                          controller: minimalPembeliancontroler,
                                          focus: _focusNodeminimalPembelian,
                                          maxLength: 10,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          hintText: 'Masukkan nilai pembelian',
                                        ))
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ],
                      )),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Durasi Promosi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF09090B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  labelForm('Tanggal Mulai'),
                                  Container(
                                      height: 40,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF6F6F6),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'asset/promosi/vuesaxoutlinecalendar.svg',
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: FormBuilderDateTimePicker(
                                              onChanged: (value) {
                                                print(value);
                                                setState(() {});
                                              },
                                              format: DateFormat(
                                                  'dd MMM yyyy', 'id'),
                                              name: 'TanggalMulai',
                                              firstDate: DateTime.now(),
                                              controller: tanggalMulaicontroler,
                                              initialEntryMode:
                                                  DatePickerEntryMode.calendar,
                                              initialDatePickerMode:
                                                  DatePickerMode.day,
                                              inputType: InputType.date,
                                              style: const TextStyle(
                                                color: Color(0xFF101010),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFA8A8A8)),
                                                hintText: 'dd/mm/yyyy',
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  labelForm('Tanggal Berakhir'),
                                  Container(
                                      height: 40,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF6F6F6),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'asset/promosi/vuesaxoutlinecalendar.svg',
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: FormBuilderDateTimePicker(
                                              onChanged: (value) {
                                                print(value);
                                                setState(() {});
                                              },
                                              format: DateFormat(
                                                  'dd MMM yyyy', 'id'),
                                              name: 'TanggalBerakhir',
                                              firstDate: DateTime.now(),
                                              controller:
                                                  tanggalBerakhircontroler,
                                              initialEntryMode:
                                                  DatePickerEntryMode.calendar,
                                              inputType: InputType.date,
                                              style: const TextStyle(
                                                color: Color(0xFF101010),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                constraints: BoxConstraints(),
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                isDense: true,
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFA8A8A8)),
                                                hintText: 'dd/mm/yyyy',
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  labelForm('Jam Mulai'),
                                  Container(
                                      height: 40,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF6F6F6),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            'asset/promosi/clock.svg',
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: FormBuilderDateTimePicker(
                                              onChanged: (value) {
                                                print(value);

                                                setState(() {});
                                              },
                                              name: 'JamMulai',
                                              firstDate: DateTime.now(),
                                              format: DateFormat('HH:mm'),
                                              controller: jamMulaicontroler,
                                              initialTime: const TimeOfDay(
                                                  hour: 00, minute: 00),
                                              initialEntryMode:
                                                  DatePickerEntryMode.calendar,
                                              inputType: InputType.time,
                                              initialValue: DateTime.now()
                                                  .copyWith(
                                                      hour: 00, minute: 00),
                                              style: const TextStyle(
                                                color: Color(0xFF101010),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                constraints: BoxConstraints(),
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFA8A8A8)),
                                                hintText: 'dd/mm/yyyy',
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  labelForm('Jam Berakhir'),
                                  Container(
                                      height: 40,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF6F6F6),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'asset/promosi/clock.svg',
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: FormBuilderDateTimePicker(
                                              onChanged: (value) {
                                                print(value);
                                                setState(() {});
                                                print(
                                                    jamBerakhircontroler.text);
                                              },
                                              name: 'JamBerakhir',
                                              format: DateFormat('HH:mm'),
                                              firstDate: DateTime.now(),
                                              controller: jamBerakhircontroler,
                                              initialValue: DateTime.now()
                                                  .copyWith(
                                                      hour: 23, minute: 59),
                                              initialEntryMode:
                                                  DatePickerEntryMode.input,
                                              inputType: InputType.time,
                                              style: const TextStyle(
                                                color: Color(0xFF101010),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                constraints: BoxConstraints(),
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                isDense: true,
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFA8A8A8)),
                                                hintText: 'dd/mm/yyyy',
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        labelForm('Pilih Hari'),
                        CustombuttonColor(
                            height: 40,
                            width: double.infinity,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            color: const Color(0xFFF6F6F6),
                            padding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 16),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _quickAccesForm(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  selectdaysFunction(daysSelect),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Color(0xFF09090B)),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFFA8A8A8),
                                  size: 12,
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  )
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
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
                          onPressed: () {
                            print('data berhasil masuk');
                            if (validateForm()) {
                              print('data berhasil masuk');
                              _confirmModal(context, namecontroler.text);
                            } else {
                              print('Isi data');
                            }
                          },
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
              ))
        ],
      )),
    );
  }

  Widget labelForm(String judul) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        judul,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFAAAAAA)),
      ),
    );
  }
}
