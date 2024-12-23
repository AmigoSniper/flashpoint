import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../component/customButtonPrimary.dart';

class Kelolaoutletfalse extends StatefulWidget {
  final VoidCallback onOpenPermis;
  const Kelolaoutletfalse({super.key, required this.onOpenPermis});

  @override
  State<Kelolaoutletfalse> createState() => _KelolaoutletfalseState();
}

class _KelolaoutletfalseState extends State<Kelolaoutletfalse> {
  Widget listText(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                        'asset/kelolaOutlet/clarity_store-solid.svg'),
                    const SizedBox(
                      height: 16,
                    ),
                    const Center(
                      child: Text(
                        'Saat ini anda belum memiliki cabang yang terdaftar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Fitur kelola cabang memungkinkan Anda untuk:',
                style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
              listText(context,
                  'Menambahkan, mengubah, dan menghapus cabang dengan mudah.'),
              listText(context,
                  'Mengelola stok, transaksi, dan laporan operasional untuk setiap cabang secara terpisah.'),
              listText(context,
                  'Menetapkan akses dan peran khusus bagi karyawan di masing-masing cabang.'),
              const SizedBox(
                height: 16,
              ),
              customButtonPrimary(
                width: double.infinity,
                height: 48,
                alignment: Alignment.center,
                onPressed: widget.onOpenPermis,
                child: const Text(
                  'Buka Cabang',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
