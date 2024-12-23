import 'package:flutter/material.dart';
import 'package:salescheck/Service/ApiRekening.dart';
import 'package:salescheck/component/customButtonPrimary.dart';
import 'package:salescheck/component/customDropDown.dart';
import 'package:salescheck/component/inputTextField.dart';
import 'package:salescheck/component/notifError.dart';

class Addrekening extends StatefulWidget {
  const Addrekening({super.key});

  @override
  State<Addrekening> createState() => _AddrekeningState();
}

class _AddrekeningState extends State<Addrekening> {
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
          'Tambah Rekening',
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
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    labelForm('Bank'),
                                    Flexible(
                                        child: Inputtextfield(
                                            hintText: 'Masukan Nama bank',
                                            controller: bankcontroler,
                                            keyboardType: TextInputType.name))
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
                            'asset/Rekening/${SelectedBank}.png',
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
                          )
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
                          await _apirekening.addRekening(
                              name: namecontroler.text,
                              namabank: SelectedBank == 'Bank Lainnya'
                                  ? bankcontroler.text
                                  : SelectedBank ?? '',
                              nomerRekening: nomerRekeningcontroler.text);
                          if (_apirekening.statusCode == 201) {
                            Navigator.pop(
                                context, 'Berhasil Menambahkan Rekening baru');
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
