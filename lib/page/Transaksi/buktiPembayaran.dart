import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salescheck/Service/ApiTransaksi.dart';
import 'package:salescheck/component/customButtonColor.dart';
import 'package:salescheck/component/customButtonPrimary.dart';
import 'package:salescheck/component/notifError.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../landingPage/landingPage.dart';

class Buktipembayaran extends StatefulWidget {
  final int idOutlet;
  final int idTransaksi;
  final String metodePembayaran;
  final int totalKembalian;
  const Buktipembayaran(
      {super.key,
      required this.idTransaksi,
      required this.metodePembayaran,
      required this.totalKembalian,
      required this.idOutlet});

  @override
  State<Buktipembayaran> createState() => _BuktipembayaranState();
}

class _BuktipembayaranState extends State<Buktipembayaran> {
  final Apitransaksi _apitransaksi = Apitransaksi();
  late final WebViewController _controller;
  String? html;
  final numberFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  String? logoPath;
  File? _image;
  bool permissionGalery = false;
  Future<void> _requestPermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    print('Memnita permission');
    if (status.isDenied || status.isPermanentlyDenied) {
      await Permission.manageExternalStorage.request();
      print('Ditolak permission');
      // _showPermissionDialog(); // Tampilkan Alert Dialog jika izin ditolak
      setState(() {
        permissionGalery = false;
      });
    } else if (status.isGranted) {
      print('Diterima permission');
      setState(() {
        permissionGalery = true;
      });
    } else {
      print('Memnita ulang permission');
      await Permission.photos.request(); // Meminta izin
      if (await Permission.photos.isGranted) {
        _pickImage(); // Lanjutkan jika izin diberikan setelah diminta
      }
    }
  }

  Future<void> _readPrintStruck() async {
    html = await _apitransaksi.getTransaksiStruck(widget.idTransaksi);
    setState(() {
      html;
    });
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(html ?? ''));
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Untuk rounded corner
          ),
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.7,
              child: WebViewWidget(controller: _controller)),
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Diperlukan'),
          content: const Text(
              'Aplikasi membutuhkan izin akses galeri untuk memilih foto. '
              'Silakan berikan izin melalui pengaturan aplikasi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Membuka pengaturan aplikasi untuk memberikan izin
              },
              child: const Text('Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (pickedFile != null) {
      File? croppedFile = await _cropImage(File(pickedFile.path));
      setState(() {
        _image = croppedFile;
      });
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Media',
            toolbarColor: const Color(0xFFF6F8FA),
            toolbarWidgetColor: const Color(0xFF121212),
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Edit Media',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4));

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  void pushHomepage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => Landingpage(
                idOutlab: widget.idOutlet,
              )),
      (Route<dynamic> route) => false,
    );
  }

  void logoBayar() {
    if (widget.metodePembayaran == 'Cash') {
      setState(() {
        logoPath = 'asset/buktipembayaran/Cash.svg';
      });
    } else if (widget.metodePembayaran == 'e-Wallet') {
      setState(() {
        logoPath = 'asset/buktipembayaran/e-Wallet.svg';
      });
    } else {
      setState(() {
        logoPath = 'asset/buktipembayaran/Transfer.svg';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _requestPermission();
    logoBayar();
    _readPrintStruck();
    super.initState();
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
          automaticallyImplyLeading: false,
          title: const Text(
            'Pembayaran',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xFF121212)),
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SvgPicture.asset(
                                'asset/buktipembayaran/tickcircle.svg'),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 16, bottom: 20),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Pembayaran Berhasil !',
                                  style: TextStyle(
                                      color: Color(0xFF09090B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Selesaikan order atau cetak struk',
                                  style: TextStyle(
                                      color: Color(0xFF717179),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 16, bottom: 20),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Metode Pembayaran',
                                      style: TextStyle(
                                          color: Color(0xFF717179),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(logoPath ?? ''),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.metodePembayaran,
                                          style: const TextStyle(
                                              color: Color(0xFF30363D),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                widget.metodePembayaran == 'Cash'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Total Kembalian',
                                            style: TextStyle(
                                                color: Color(0xFF717179),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            numberFormat.format(5000),
                                            style: const TextStyle(
                                                color: Color(0xFF2E6CE9),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                          CustombuttonColor(
                              alignment: Alignment.center,
                              height: 48,
                              color: const Color(0xFFF6F6F6),
                              border: Border.all(
                                  color: const Color(0xFFE4E7EB), width: 1),
                              onPressed: () {},
                              child: const Text(
                                'Cetak Struk',
                                style: TextStyle(
                                    color: Color(0xFF09090B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              )),
                          const SizedBox(
                            height: 12,
                          ),
                          CustombuttonColor(
                              alignment: Alignment.center,
                              height: 48,
                              color: const Color(0xFFF6F6F6),
                              border: Border.all(
                                  color: const Color(0xFFE4E7EB), width: 1),
                              onPressed: () {
                                _dialogBuilder(context);
                              },
                              child: const Text(
                                'Lihat Struk',
                                style: TextStyle(
                                    color: Color(0xFF09090B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          widget.metodePembayaran == 'Cash'
                              ? const SizedBox.shrink()
                              : const Text(
                                  'Bukti bayar',
                                  style: TextStyle(
                                      color: Color(0xFFAAAAAA),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                          const SizedBox(
                            height: 8,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (permissionGalery == true) {
                                _pickImage();
                              } else {
                                _requestPermission();
                              }
                            },
                            child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: double.infinity,
                                height: 411,
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                    border: _image != null
                                        ? Border.all(
                                            width: 0, color: Colors.transparent)
                                        : Border.all(
                                            width: 1,
                                            color: const Color(0xFFC9C9CE)),
                                    borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.centerLeft,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _image != null
                                      ? Image.file(
                                          _image!,
                                          fit: BoxFit.fitWidth,
                                          width: double.infinity,
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                              color: Color(0xFFF6F6F6)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'asset/image/gallery-add.svg',
                                                width: 48,
                                                height: 48,
                                              ),
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              const Text(
                                                'Tambah Foto',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                        0xFFA8A8A8)),
                                              )
                                            ],
                                          ),
                                        ),
                                )),
                          ),
                          const SizedBox(
                            height: 75,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 16, left: 24, right: 24, bottom: 24),
                decoration:
                    BoxDecoration(color: const Color(0xFFFDFEFE), boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF888888).withOpacity(0.08),
                    blurRadius: 7,
                    offset: const Offset(0, -4),
                  )
                ]),
                child: customButtonPrimary(
                    alignment: Alignment.center,
                    height: 48,
                    onPressed: () async {
                      if (widget.metodePembayaran == 'Cash') {
                        pushHomepage();
                      } else {
                        if (_image != null) {
                          await _apitransaksi.addBuktiTransaksi(
                              _image!, widget.idTransaksi);
                          pushHomepage();
                        } else {
                          Notiferror.showNotif(
                              context: context,
                              description:
                                  'Pastikan Bukti Bayar telah ditambahkan');
                        }
                      }
                    },
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    )),
              ),
            )
          ],
        ));
  }
}
