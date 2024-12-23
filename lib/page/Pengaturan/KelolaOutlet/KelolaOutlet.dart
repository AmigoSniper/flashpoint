import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salescheck/component/customButtonColor.dart';
import 'package:salescheck/component/customButtonPrimary.dart';

import 'Kelolaoutletfalse.dart';
import 'kelolaOutlettrue.dart';

class Kelolaoutlet extends StatefulWidget {
  final bool? premisOutlet;
  const Kelolaoutlet({super.key, this.premisOutlet});

  @override
  State<Kelolaoutlet> createState() => _KelolaoutletState();
}

class _KelolaoutletState extends State<Kelolaoutlet> {
  bool permisOpen = false;
  void _openPermis() {
    bool checkBox = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDFEFE),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setModalState) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                  top: 30,
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
                  SizedBox(
                    height: 500,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Syarat dan Ketentuan kelola cabang di Sirqu',
                            style: const TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text(
                            'Fitur Kelola Cabang di Sirqu memungkinkan pengguna untuk menambahkan, mengelola, dan menghapus cabang bisnis dengan mudah.Pengguna bertanggung jawab penuh atas data yang dikelola serta harus memastikan bahwa setiap cabang beroperasi sesuai hukum yang berlaku..Sirqu berhak untuk memperbarui ketentuan ini sewaktu-waktu.',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF2C3E50)),
                          ),
                          const Text(
                            'Poin ketentuan:',
                            style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          listText(context,
                              'Pendaftaran Cabang: Pengguna wajib mengisi data cabang dengan lengkap dan akurat.'),
                          listText(context,
                              'Pengelolaan Data: Administrator bertanggung jawab atas transaksi, laporan, dan pengaturan karyawan di setiap cabang.'),
                          listText(context,
                              'Akses Otorisasi: Hanya pengguna dengan hak akses yang dapat mengelola cabang.'),
                          listText(context,
                              'Keamanan Data: Pengguna wajib menjaga keamanan akun dan data cabang.'),
                          listText(context,
                              'Kepatuhan Hukum: Pengguna harus memastikan cabang memenuhi regulasi setempat.'),
                          listText(context,
                              'Penghapusan Cabang: Cabang yang tidak aktif dapat dihapus, namun data terkait tetap disimpan.'),
                          listText(context,
                              'Perubahan Syarat: Sirqu dapat memperbarui syarat dan ketentuan sesuai kebutuhan'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        checkBox = !checkBox;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: checkBox
                              ? const Color(0xFFE6EEFF)
                              : const Color(0xFFF0F0F0),
                          border: Border.all(
                              color: checkBox
                                  ? const Color(0xFF2E6CE9)
                                  : Colors.transparent),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(10))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: Transform.scale(
                              scale: 0.8,
                              child: Checkbox(
                                checkColor: Colors.white,
                                activeColor: const Color(0xFF2E6CE9),
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF717179),
                                ),
                                value: checkBox,
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    checkBox = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Flexible(
                            child: Text(
                              'Saya telah membaca, mengerti dan menyetujui syarat dan ketentuan diatas.',
                              style: TextStyle(
                                  color: checkBox
                                      ? const Color(0xFF2E6CE9)
                                      : const Color(0xFF2C3E50),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                            child: CustombuttonColor(
                                alignment: Alignment.center,
                                height: 48,
                                color: const Color(0xFFF6F6F6),
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
                          height: 15,
                          width: 8,
                        ),
                        Flexible(
                            child: checkBox
                                ? customButtonPrimary(
                                    alignment: Alignment.center,
                                    height: 48,
                                    onPressed: () {
                                      if (checkBox == true) {
                                        setState(() {
                                          permisOpen = true;
                                        });
                                        Navigator.pop(context);
                                      } else {}
                                    },
                                    child: const Text(
                                      'Lanjutkan',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFFFFF)),
                                    ))
                                : CustombuttonColor(
                                    color: const Color(0xFFF6F6F6),
                                    alignment: Alignment.center,
                                    height: 48,
                                    onPressed: () {
                                      if (checkBox == true) {
                                        setState(() {
                                          permisOpen = true;
                                        });
                                        Navigator.pop(context);
                                      } else {}
                                    },
                                    child: const Text(
                                      'Lanjutkan',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFAAAAAA)),
                                    )))
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

  Widget listText(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2C3E50)),
          ),
          const SizedBox(
            width: 8,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF2C3E50)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.premisOutlet);
    permisOpen = widget.premisOutlet ?? false;
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
          'Kelola Outlet',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: permisOpen
          ? const Kelolaoutlettrue()
          : Kelolaoutletfalse(
              onOpenPermis: _openPermis,
            ),
    );
  }
}

//permis true

//permis false

