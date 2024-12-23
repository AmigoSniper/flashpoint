import 'dart:convert';

import 'package:avatar_plus/avatar_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart' as SvgIcon;
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:salescheck/Service/ApiPegawai.dart';
import 'package:salescheck/page/Pengaturan/Account/SetAccount.dart';
import 'package:salescheck/page/Pengaturan/BiayaTambahan/biayaTambahan.dart';
import 'package:salescheck/page/Pengaturan/KelolaOutlet/KelolaOutlet.dart';
import 'package:salescheck/page/Pengaturan/Lainnya/Bantuan.dart';
import 'package:salescheck/page/Pengaturan/Lainnya/KebijakanPrivasi.dart';
import 'package:salescheck/page/Pengaturan/Pegawai/pegawaiPage.dart';
import 'package:salescheck/page/Pengaturan/Pembayaran/pembayaran.dart';
import 'package:salescheck/page/Pengaturan/Promosi/promosiPage.dart';
import 'package:salescheck/page/Pengaturan/Struk/Struk.dart';
import 'package:salescheck/page/Pengaturan/Lainnya/SyaratDanKetentuan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/UserData.dart';

class Settingpage extends StatefulWidget {
  final bool? permisOutlet;
  const Settingpage({super.key, this.permisOutlet});

  @override
  State<Settingpage> createState() => _SettingpageState();
}

class _SettingpageState extends State<Settingpage> {
  final Apipegawai _apipegawai = new Apipegawai();
  ScrollController _scrollController = new ScrollController();
  String name = '';
  String otority = '';
  String? imageUrl;
  UserData? userData;
  Future<void> _readAndPrintUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil data yang disimpan sebagai JSON string
    final data = prefs.getString('userData');

    if (data != null) {
      // Decode JSON string ke Map<String, dynamic>
      final jsonData = jsonDecode(data) as Map<String, dynamic>;

      // Parse JSON ke model UserData
      userData = UserData.fromJson(jsonData);

      // Cetak informasi user
      print('Token: ${userData?.token}');
      print('User Name: ${userData?.user.name}');
      print('User Email: ${userData?.user.email}');
      print('User Role: ${userData?.user.role}');
      setState(() {
        name = userData!.user.name;
        otority = userData!.user.role;
      });
      imageUrl = await userData!.user.image!;
    } else {
      print('No data found');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readAndPrintUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffF6F8FA),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(15),
              child: const Text(
                'Pengaturan',
                style: TextStyle(
                    color: Color(0xFF0C0D11),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.red,
                        image: DecorationImage(
                            image: Svg('asset/background/Wallet.svg'),
                            fit: BoxFit.cover)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  color: Colors.transparent,
                                  height: 50,
                                  width: 50,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100)),
                                    child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        imageUrl: _apipegawai
                                            .getImage(imageUrl ?? ''),
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
                                            AvatarPlus(
                                              name,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )),
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: 120,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Text(
                                      otority,
                                      style: TextStyle(
                                          color: const Color(0xFFFFFFFF)
                                              .withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration:
                              const BoxDecoration(color: Colors.transparent),
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Setaccount(),
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(0),
                                  shadowColor: Colors.transparent,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  backgroundColor:
                                      const Color(0xFFFFFFFF).withOpacity(0.3),
                                  minimumSize: const Size(93, 24)),
                              child: const Text(
                                'Sunting Akun',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFFFFFFF)),
                              )),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengaturan Toko',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF717179)),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Kelolaoutlet(
                                    premisOutlet: widget.permisOutlet,
                                  ),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/shop.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kelola Outlet',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0B0C17)),
                                    ),
                                    Text(
                                      'Atur profil outlet',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA3A3A3)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Biayatambahan(),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/percentage-circle.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pengaturan Biaya Tambahan',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0B0C17)),
                                    ),
                                    Text(
                                      'Pajak & servis atur disini',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA3A3A3)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Pembayaran(),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/wallet.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pengaturan Pembayaran',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0B0C17)),
                                    ),
                                    Text(
                                      'Rekening dan e-wallet atur disini',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA3A3A3)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Promosipage(),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/ticket-discount.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Promosi',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0B0C17)),
                                    ),
                                    Text(
                                      'Buat program diskon',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA3A3A3)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Struk(),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/receipt-text.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tampilan Struk',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0B0C17)),
                                    ),
                                    Text(
                                      'Edit tampilan struk yang dicetak',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA3A3A3)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const pegawaiPage(),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/profile-2user.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pegawai',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0B0C17)),
                                    ),
                                    Text(
                                      'Manajemen pegawai',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA3A3A3)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lainnya',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF717179)),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Bantuan(),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/message-question.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bantuan',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0B0C17)),
                                    ),
                                    Text(
                                      'FAQ & Laporkan masalah',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA3A3A3)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const Syaratdanketentuan(),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/task-square.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Text(
                                  'Syarat & Ketentuan',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0B0C17)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const Kebijakanprivasi(),
                                ));
                          },
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Color(0xFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgIcon.SvgPicture.asset(
                                    'asset/setting/security-safe.svg'),
                                const SizedBox(
                                  width: 16,
                                ),
                                const Text(
                                  'Kebijakan Privasi',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF0B0C17)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
