import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:salescheck/Model/biayaTambahanModel.dart';
import 'package:salescheck/Service/ApiBiayaTambahan.dart';
import 'package:salescheck/component/inputTextField.dart';

class Biayatambahan extends StatefulWidget {
  const Biayatambahan({super.key});

  @override
  State<Biayatambahan> createState() => _BiayatambahanState();
}

class _BiayatambahanState extends State<Biayatambahan> {
  Apibiayatambahan _apibiayatambahan = Apibiayatambahan();
  List<biayaTambahanModel> biaya = [];
  bool pajakEnable = false;
  bool biayaOperasionalEnable = false;
  int pajak = 0;
  int biayaOperasional = 0;
  final TextEditingController pajakcontroler = TextEditingController();
  final TextEditingController biayaOperasionalcontroler =
      TextEditingController();
  bool focusPajak = false;
  bool focusbiayaOperasional = false;
  FocusNode _focusNodepajak = FocusNode();
  FocusNode _focusNodebiayaOperasional = FocusNode();
  Future<void> _readAndPrintBiaya() async {
    biaya = await _apibiayatambahan.getBiayaTambahan();
    setState(() {
      biaya = biaya;
      pajakEnable = biaya.first.status ?? false;
      biayaOperasionalEnable = biaya.last.status ?? false;
      pajakcontroler.text = biaya.first.nilaiPajak!.replaceAll('%', '') ?? '0';
      biayaOperasionalcontroler.text =
          biaya.last.nilaiPajak!.replaceAll('%', '') ?? '0';
    });
  }

  @override
  void initState() {
    super.initState();
    _readAndPrintBiaya();
    _focusNodepajak.addListener(() {
      setState(() {
        focusPajak = _focusNodepajak.hasFocus;
      });
    });
    _focusNodebiayaOperasional.addListener(() {
      setState(() {
        focusbiayaOperasional = _focusNodebiayaOperasional.hasFocus;
      });
    });
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
          'Biaya Tambahan',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          'Pajak',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF09090B)),
                        ),
                        SizedBox(
                            width: 44,
                            height: 24,
                            child: CupertinoSwitch(
                              activeColor: const Color(0xFF10B981),
                              trackColor: const Color(0xFFE2E8F0),
                              thumbColor: const Color(0xFFFFFFFF),
                              value: pajakEnable,
                              onChanged: (value) async {
                                setState(() {
                                  pajakEnable = value;
                                });
                                await _apibiayatambahan.editstatusbiayaTambahan(
                                    biaya.first.id ?? 0, pajakEnable);
                              },
                            )),
                      ],
                    ),
                    !pajakEnable
                        ? const SizedBox.shrink()
                        : SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                labelForm('Jumlah pajak'),
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
                                        Flexible(
                                            child: Inputtextfield(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 0),
                                          hintText: 'Masukkan jumlah pajak',
                                          keyboardType: TextInputType.number,
                                          controller: pajakcontroler,
                                          focus: _focusNodepajak,
                                          maxLength: 3,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              int? number = int.tryParse(value);
                                              if (number != null &&
                                                  number > 100) {
                                                pajakcontroler.text = '100';
                                                pajakcontroler.selection =
                                                    TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: pajakcontroler
                                                          .text.length),
                                                );
                                              }
                                            }
                                          },
                                          onSubmit: () {
                                            _apibiayatambahan
                                                .editnilaibiayaTambahan(
                                                    biaya.first.id ?? 0,
                                                    '${pajakcontroler.text}%');
                                          },
                                        )),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        const Text(
                                          '%',
                                          style: TextStyle(
                                              color: Color(0xFFA8A8A8),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ],
                                    )),
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  padding: const EdgeInsets.all(8),
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFFFF9E6),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SvgPicture.asset(
                                          'asset/image/info-circle.svg'),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const Flexible(
                                        child: Text(
                                          'Gunakan apabila memerlukan biaya pajak pada setiap transaksi',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Color(0xFFE5851F)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                  ],
                )),
            Container(
                margin: const EdgeInsets.only(top: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          'Biaya Operasional',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF09090B)),
                        ),
                        SizedBox(
                            width: 44,
                            height: 24,
                            child: CupertinoSwitch(
                              activeColor: const Color(0xFF10B981),
                              trackColor: const Color(0xFFE2E8F0),
                              thumbColor: const Color(0xFFFFFFFF),
                              value: biayaOperasionalEnable,
                              onChanged: (value) async {
                                setState(() {
                                  biayaOperasionalEnable = value;
                                });
                                await _apibiayatambahan.editstatusbiayaTambahan(
                                    biaya.last.id ?? 0, biayaOperasionalEnable);
                              },
                            )),
                      ],
                    ),
                    !biayaOperasionalEnable
                        ? const SizedBox.shrink()
                        : SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                labelForm('Jumlah Biaya Operasional'),
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
                                        Flexible(
                                            child: Inputtextfield(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 0),
                                          hintText:
                                              'Masukkan jumlah biaya operasional',
                                          keyboardType: TextInputType.number,
                                          controller: biayaOperasionalcontroler,
                                          focus: _focusNodebiayaOperasional,
                                          maxLength: 3,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              int? number = int.tryParse(value);
                                              if (number != null &&
                                                  number > 100) {
                                                biayaOperasionalcontroler.text =
                                                    '100';
                                                biayaOperasionalcontroler
                                                        .selection =
                                                    TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset:
                                                          biayaOperasionalcontroler
                                                              .text.length),
                                                );
                                              }
                                            }
                                          },
                                          onSubmit: () {
                                            _apibiayatambahan
                                                .editnilaibiayaTambahan(
                                                    biaya.last.id ?? 0,
                                                    '${biayaOperasionalcontroler.text}%');
                                          },
                                        )),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        const Text(
                                          '%',
                                          style: TextStyle(
                                              color: Color(0xFFA8A8A8),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ],
                                    )),
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  padding: const EdgeInsets.all(8),
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFFFF9E6),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SvgPicture.asset(
                                          'asset/image/info-circle.svg'),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const Flexible(
                                        child: Text(
                                          'Gunakan apabila memerlukan biaya layanan pada setiap transaksi',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Color(0xFFE5851F)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                  ],
                ))
          ],
        ),
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
