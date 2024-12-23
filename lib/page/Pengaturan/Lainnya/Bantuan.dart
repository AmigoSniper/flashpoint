import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Bantuan extends StatefulWidget {
  const Bantuan({super.key});

  @override
  State<Bantuan> createState() => _BantuanState();
}

class _BantuanState extends State<Bantuan> {
  final TextEditingController search = new TextEditingController();
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
          'Bantuan',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Container(
                height: 40,
                decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFFA2A2A2),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          // print('cari');
                          // setState(() {
                          //   searchQuery = search.text;
                          // });
                          // searchfunction();
                          // print('hasil');
                        },
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFA2A2A2)),
                        controller: search,
                        decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Cari bantuan',
                            contentPadding: EdgeInsets.symmetric(vertical: 0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Kategori Layanan',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF717179)),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _IconHelp('asset/image/transaksi.svg', 'Transaksi'),
                        _IconHelp('asset/image/box.svg', 'Inventori'),
                        _IconHelp('asset/image/pengaturan.svg', 'Pengaturan'),
                        _IconHelp('asset/promosi/shop.svg', 'Toko'),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Kendala umum',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF717179)),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  GridView(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.29,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            crossAxisCount: 2),
                    children: [
                      _gridContainer(
                          'Apa yang harus dilakukan jika transaksi tidak tercatat dengan benar?'),
                      _gridContainer(
                          'Bagaimana cara menambahkan produk baru ke dalam sistem POS?'),
                      _gridContainer(
                          'Bagaimana cara menghubungkan printer struk dengan aplikasi POS?'),
                      _gridContainer(
                          'laporan penjualan saya tidak muncul atau tidak sesuai?'),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget _IconHelp(String asset, String name) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 52,
              width: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(46))),
              child: SvgPicture.asset(
                asset,
                color: const Color(0xFF2E6CE9),
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000)),
            )
          ],
        ),
      ),
    );
  }

  Widget _gridContainer(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF34495E)),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'asset/image/box.svg',
                color: const Color(0xFF9399A7),
              ),
              const SizedBox(width: 6),
              const Text(
                'Inventori',
                style: TextStyle(
                    color: Color(0xFF979899),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              )
            ],
          )
        ],
      ),
    );
  }
}
