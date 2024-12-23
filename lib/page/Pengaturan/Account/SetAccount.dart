import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salescheck/component/customButtonColor.dart';
import 'package:salescheck/page/boardingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setaccount extends StatefulWidget {
  const Setaccount({super.key});

  @override
  State<Setaccount> createState() => _SetaccountState();
}

class _SetaccountState extends State<Setaccount> {
  void _confirmLogOut(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      scrollControlDisabledMaxHeightRatio: 300,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 30, right: 16, bottom: 30, left: 16),
          child: Container(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 4,
                      color: const Color(0xFFE9E9E9),
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                    Container(
                      width: 66,
                      height: 66,
                      margin: const EdgeInsets.only(bottom: 16),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.all(Radius.circular(33))),
                      child: SvgPicture.asset(
                        'asset/settingAccount/user-remove.svg',
                        fit: BoxFit.fitHeight,
                        width: 36,
                        height: 36,
                      ),
                    ),
                    const Text(
                      'Konfirmasi Log Out',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                          fontSize: 16),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Flexible(
                      child: Text(
                        'Harap diperhatikan bahwa setelah keluar, Anda harus masuk kembali untuk menerima penawaran dan notifikasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF979899),
                            fontSize: 14),
                      ),
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
                                alignment: Alignment.center,
                                height: 48,
                                color: const Color(0xFFF6F6F6),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Kembali',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF09090B),
                                      fontSize: 16),
                                ))),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                            child: CustombuttonColor(
                                alignment: Alignment.center,
                                height: 48,
                                color: const Color(0xFFFF3E1D),
                                onPressed: () async {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.remove('userData');
                                  print('Login dihapus');
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Boardingpage()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16),
                                )))
                      ],
                    )
                  ],
                ),
              )),
        );
      },
    );
  }

  void _confirmDeleteAccopunt(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      scrollControlDisabledMaxHeightRatio: 300,
      isScrollControlled: true,
      builder: (context) {
        bool checkBox = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.only(
                  top: 30, right: 16, bottom: 30, left: 16),
              child: Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 4,
                          color: const Color(0xFFE9E9E9),
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                        Container(
                          width: 66,
                          height: 66,
                          margin: const EdgeInsets.only(bottom: 30),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFF1F2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(33))),
                          child: SvgPicture.asset(
                            'asset/settingAccount/user-remove.svg',
                            fit: BoxFit.fitHeight,
                            width: 36,
                            height: 36,
                          ),
                        ),
                        const Text(
                          'Setelah menghapus akun Anda, Anda akan kehilangan akses ke semua data dan informasi Anda, termasuk:',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF303030),
                              fontSize: 15),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection('1. Riwayat Transaksi',
                                  'Semua riwayat penjualan, pembelian, dan laporan transaksi lainnya akan dihapus secara permanen.'),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildSection('2. Sirqu Wallet ',
                                  'Saldo atau dana apa pun di Sirqu Anda akan hilang.'),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildSection('3. Data Inventori',
                                  'Informasi produk, stok, serta catatan inventaris yang telah Anda input akan hilang.'),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildSection('4. Profil Sirqu ',
                                  'Anda tidak akan dapat lagi mengakses aplikasi POS atau layanan yang terkait dengan akun ini.'),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        const Text(
                          'Kami tidak bertanggung jawab atas hilangnya informasi, data, atau dana setelah penghapusan akun Anda.',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF303030),
                              fontSize: 15),
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
                                    ? const Color(0xFFFAEEEC)
                                    : const Color(0xFFF0F0F0),
                                border: Border.all(
                                    color: checkBox
                                        ? const Color(0xFFFF3E1D)
                                        : Colors.transparent),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: const Color(0xFFFF3E1D),
                                      side: const BorderSide(
                                        width: 1,
                                        color: const Color(0xFF717179),
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
                                const Flexible(
                                  child: Text(
                                    'Saya telah membaca, mengerti dan menyetujui syarat dan ketentuan diatas.',
                                    style: TextStyle(
                                        color: Color(0xFF2C3E50),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                    alignment: Alignment.center,
                                    height: 48,
                                    color: const Color(0xFFF6F6F6),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF09090B),
                                          fontSize: 16),
                                    ))),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                                child: CustombuttonColor(
                                    alignment: Alignment.center,
                                    height: 48,
                                    color: checkBox
                                        ? const Color(0xFFFF3E1D)
                                        : const Color(0xFFF6F6F6),
                                    onPressed: () {
                                      if (checkBox) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Boardingpage()),
                                          (Route<dynamic> route) => false,
                                        );
                                      } else {
                                        null;
                                      }
                                    },
                                    child: Text(
                                      'Hapus Akun',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: checkBox
                                              ? const Color(0xFFFFFFFF)
                                              : const Color(0xFFAAAAAA),
                                          fontSize: 16),
                                    )))
                          ],
                        )
                      ],
                    ),
                  )),
            );
          },
        );
      },
    );
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
          'Pengaturan Akun',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _confirmLogOut(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 92,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'asset/settingAccount/logout.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logout',
                              style: TextStyle(
                                  color: Color(0xFF0B0C17),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            Flexible(
                                child: Text(
                              'Harap diperhatikan bahwa setelah keluar, Anda harus masuk kembali untuk menerima penawaran dan notifikasi.',
                              style: TextStyle(
                                  color: Color(0xFFA3A3A3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _confirmDeleteAccopunt(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: double.infinity,
                  height: 92,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'asset/settingAccount/user-minus.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hapus Akun',
                              style: TextStyle(
                                  color: Color(0xFF0B0C17),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            Flexible(
                                child: Text(
                              'Menghapus akun Anda akan menghapus semua data Anda secara permanen, termasuk riwayat transaksi dan detail pribadi lainnya. Tindakan ini tidak dapat dibatalkan.',
                              style: TextStyle(
                                  color: Color(0xFFA3A3A3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildSection(String title, String points) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50)),
          ),
          Text(
            points,
            textAlign: TextAlign.justify,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF979899)),
          ),
        ],
      ),
    );
  }
}
