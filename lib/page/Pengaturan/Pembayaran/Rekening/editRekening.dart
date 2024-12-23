import 'package:flutter/material.dart';
import 'package:salescheck/Model/RekeningModel.dart';

import '../../../../Service/ApiRekening.dart';
import '../../../../component/customButtonColor.dart';
import '../../../../component/customButtonPrimary.dart';
import '../../../../component/customDropDown.dart';
import '../../../../component/inputTextField.dart';
import '../../../../component/notifError.dart';

class Editrekening extends StatefulWidget {
  final Rekeningmodel rekeningmodel;
  const Editrekening({super.key, required this.rekeningmodel});

  @override
  State<Editrekening> createState() => _EditrekeningState();
}

class _EditrekeningState extends State<Editrekening> {
  final Apirekening _apirekening = Apirekening();
  final TextEditingController namecontroler = TextEditingController();
  final TextEditingController bankcontroler = TextEditingController();
  final TextEditingController nomerRekeningcontroler = TextEditingController();
  List<String> listBank = [
    'Bank Rakyat Indonesia',
    'Bank Central Asia',
    'Bank Nasional Indonesia',
    'Bank Syariah Indonesia',
    'Bank Mandiri',
    'Bank Lainnya'
  ];
  int tahap = 1;
  String? SelectedBank;
  void selectbankinit() {
    if (listBank.contains(bankcontroler.text)) {
      setState(() {
        SelectedBank = bankcontroler.text;
      });
    } else {
      setState(() {
        SelectedBank = listBank.last;
      });
    }
  }

  void _deleteForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                color: const Color(0xFFE9E9E9),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Text(
                'Apakah anda yakin ingin menghapus Rekening atas nama ${widget.rekeningmodel.namaPemilik}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                          height: 48,
                          alignment: Alignment.center,
                          color: const Color(0xFFF7F7F7),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Tidak, batal',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF09090B)),
                          ))),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                      child: CustombuttonColor(
                          height: 48,
                          alignment: Alignment.center,
                          color: const Color(0xFFFF3E1D),
                          onPressed: () async {
                            await _apirekening
                                .deleteRekening(widget.rekeningmodel.id ?? 0);
                            if (_apirekening.statusCode == 204 ||
                                _apirekening.statusCode == 201) {
                              Navigator.pop(context);
                              Navigator.pop(
                                context,
                                {
                                  'message':
                                      'Rekening atas nama ${widget.rekeningmodel.namaPemilik} berhasil dihapus!',
                                  'isDeleted': true,
                                },
                              );
                            } else {}
                          },
                          child: const Text(
                            'Ya, saya yakin',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFFFF)),
                          )))
                ],
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
    namecontroler.text = widget.rekeningmodel.namaPemilik!;
    bankcontroler.text = widget.rekeningmodel.namaBank!;

    nomerRekeningcontroler.text = widget.rekeningmodel.nomerRekening!;
    selectbankinit();
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
          'Edit Rekening',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tahap == 1
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              labelForm('Bank'),
                              Flexible(
                                  child: Customdropdown(
                                      data: listBank,
                                      selectValue: SelectedBank,
                                      onChanged: (p0) {
                                        setState(() {
                                          SelectedBank = p0;
                                        });
                                      },
                                      hintText: 'Pilih bank',
                                      heightItem: 42)),
                              SelectedBank == 'Bank Lainnya'
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        labelForm('Bank'),
                                        Flexible(
                                            child: Inputtextfield(
                                                hintText: 'Masukan Nama bank',
                                                controller: bankcontroler,
                                                keyboardType:
                                                    TextInputType.name))
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                              labelForm('Nomer Rekening'),
                              Flexible(
                                  child: Inputtextfield(
                                      hintText: 'Masukan Nomer Rekening',
                                      controller: nomerRekeningcontroler,
                                      keyboardType: TextInputType.number)),
                              labelForm('Pemilik Rekening'),
                              Flexible(
                                  child: Inputtextfield(
                                      hintText: 'Masukan Pemilik Rekening',
                                      controller: namecontroler,
                                      keyboardType: TextInputType.number))
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          decoration:
                              const BoxDecoration(color: Color(0xFFF6F8FA)),
                          child: ElevatedButton(
                              onPressed: () {
                                _deleteForm(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  backgroundColor: const Color(0xFFFFFFFF),
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 50)),
                              child: const Text(
                                'Hapus Produk',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF3E1D)),
                              )),
                        ),
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.only(
                          top: 24, left: 16, right: 16, bottom: 16),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'asset/Rekening/$SelectedBank.png',
                            width: 63,
                            height: 42,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            bankcontroler.text.isEmpty
                                ? SelectedBank ?? ''
                                : bankcontroler.text,
                            style: const TextStyle(
                                color: Color(0xFF92A0AD),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            nomerRekeningcontroler.text,
                            style: const TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'a.n ${namecontroler.text}',
                            style: const TextStyle(
                                color: Color(0xFF92A0AD),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
              customButtonPrimary(
                  alignment: Alignment.center,
                  height: 48,
                  onPressed: () async {
                    if (SelectedBank != null) {
                      if (nomerRekeningcontroler.text.isNotEmpty &&
                          namecontroler.text.isNotEmpty) {
                        if (tahap == 1) {
                          setState(() {
                            tahap = 2;
                          });
                        } else {
                          await _apirekening.editRekening(
                              id: widget.rekeningmodel.id ?? 0,
                              name: namecontroler.text,
                              namabank: SelectedBank == 'Bank Lainnya'
                                  ? bankcontroler.text
                                  : SelectedBank ?? '',
                              nomerRekening: nomerRekeningcontroler.text);
                          if (_apirekening.statusCode == 200) {
                            Navigator.pop(
                              context,
                              {
                                'message':
                                    'Rekening ${namecontroler.text} berhasil disimpan!',
                                'isDeleted': false,
                              },
                            );
                          } else {
                            Notiferror.showNotif(
                                context: context, description: 'Error');
                          }
                        }
                      } else {
                        Notiferror.showNotif(
                            context: context,
                            description: 'Pastikan Data sudah lengkap');
                      }
                    } else {
                      Notiferror.showNotif(
                          context: context,
                          description: 'Pastikan Data sudah lengkap');
                    }
                  },
                  child: Text(
                    tahap == 1 ? 'Selanjutnya' : 'Simpan',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF)),
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
            color: Color(0xFF8D8D8D)),
      ),
    );
  }
}
