import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Syaratdanketentuan extends StatefulWidget {
  const Syaratdanketentuan({super.key});

  @override
  State<Syaratdanketentuan> createState() => _SyaratdanketentuanState();
}

class _SyaratdanketentuanState extends State<Syaratdanketentuan> {
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
          'Syarat dan Ketentuan',
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
              _buildSection('1. Pendahuluan', [
                'Syarat dan ketentuan ini mengatur penggunaan situs web dan aplikasi mobile kami.',
                'Dengan mengakses atau menggunakan layanan kami, Anda setuju untuk mematuhi syarat dan ketentuan ini.'
              ]),
              _buildSection('2. Penggunaan Layanan', [
                'Anda harus berusia minimal 18 tahun untuk menggunakan layanan kami.',
                'Anda setuju untuk memberikan informasi yang akurat dan terbaru saat menggunakan platform kami',
                'Penggunaan layanan kami tanpa izin dilarang.'
              ]),
              _buildSection('3. Privasi', [
                'Kami menghormati privasi Anda dan menangani informasi pribadi Anda sesuai dengan Kebijakan Privasi kami.'
              ]),
              _buildSection('4. Kekayaan Intelektual', [
                'Semua konten yang disediakan di platform kami adalah milik [Nama Perusahaan Anda] dan dilindungi oleh undang-undang kekayaan intelektual.'
              ]),
              _buildSection('5. Batasan Tanggung Jawab', [
                'Kami tidak bertanggung jawab atas kerugian yang timbul dari penggunaan layanan kami.'
              ]),
              _buildSection('6. Perubahan Syarat dan Ketentuan', [
                'Kami berhak untuk memperbarui syarat dan ketentuan ini kapan saja tanpa pemberitahuan sebelumnya.'
              ]),
              _buildSection('7. Hukum yang Berlaku', [
                'Syarat dan ketentuan ini diatur oleh hukum [Negara/Provinsi Anda].'
              ]),
              _buildSection('8. Hubungi Kami', [
                'Jika Anda memiliki pertanyaan atau kekhawatiran tentang syarat dan ketentuan ini, silakan hubungi kami di [Email Kontak].'
              ])
            ],
          )),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 8),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(left: 24.0, bottom: 8.0),
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
