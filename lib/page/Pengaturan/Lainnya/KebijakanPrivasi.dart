import 'package:flutter/material.dart';

class Kebijakanprivasi extends StatefulWidget {
  const Kebijakanprivasi({super.key});

  @override
  State<Kebijakanprivasi> createState() => _KebijakanprivasiState();
}

class _KebijakanprivasiState extends State<Kebijakanprivasi> {
  String text =
      '("kami", "kita", "milik kami") berkomitmen untuk melindungi privasi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, mengungkapkan, dan melindungi informasi Anda ketika Anda mengunjungi situs web kami [URL Website] atau menggunakan aplikasi mobile kami [Nama Aplikasi], termasuk bentuk media lain, saluran media, situs web mobile, atau aplikasi mobile terkait lainnya (secara kolektif disebut "Situs"). Harap baca kebijakan privasi ini dengan saksama. Jika Anda tidak setuju dengan ketentuan dalam kebijakan privasi ini, mohon untuk tidak mengakses Situs.';
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
          'Kebijakan Privasi',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: ListView(
            children: [
              const Text(
                'Tanggal Efektif : 2 Juli 2024',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50)),
              ),
              const SizedBox(
                height: 24,
              ),
              RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                      text: 'Sirqu ',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color: Color(0xFF2C3E50)),
                      children: [
                        TextSpan(
                          text: text,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: Color(0xFF2C3E50)),
                        )
                      ])),
              _buildSection('a. Informasi yang Kami Kumpulkan', [
                'Kami dapat mengumpulkan informasi pribadi seperti nama, alamat email, nomor telepon, dan detail pembayaran saat Anda berinteraksi dengan layanan kami.'
              ]),
              _buildSection('b. Bagaimana Kami Menggunakan Informasi Anda', [
                'Kami menggunakan informasi yang kami kumpulkan untuk menyediakan dan meningkatkan layanan kami, memproses transaksi, dan berkomunikasi dengan Anda.'
              ]),
              _buildSection('c. Berbagi Informasi Anda', [
                'Kami tidak menjual, memperdagangkan, atau mentransfer informasi pribadi Anda kepada pihak luar kecuali kami memberi tahu Anda terlebih dahulu.'
              ]),
              _buildSection('d. Keamanan Informasi Anda', [
                'Kami menerapkan langkah-langkah keamanan yang dirancang untuk melindungi informasi Anda dari akses yang tidak sah dan menjaga akurasi data.'
              ]),
              _buildSection('e. Tautan ke Situs Web Pihak Ketiga', [
                'Situs kami mungkin berisi tautan ke situs web pihak ketiga. Kami tidak memiliki kendali atas praktik privasi atau konten dari situs-situs ini.'
              ]),
              _buildSection('f. Perubahan pada Kebijakan Privasi Ini', [
                'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan dengan memposting Kebijakan Privasi yang baru di Situs.'
              ]),
              _buildSection('h. Hubungi Kami', [
                'Jika Anda memiliki pertanyaan atau kekhawatiran tentang Kebijakan Privasi ini, silakan hubungi kami di [Email Kontak].'
              ])
            ],
          )),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
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
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF2C3E50))),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF2C3E50)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
