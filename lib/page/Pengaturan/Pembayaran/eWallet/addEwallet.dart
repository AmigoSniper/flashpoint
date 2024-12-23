import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salescheck/Service/ApiEwallet.dart';
import 'package:salescheck/component/inputTextField.dart';

import '../../../../component/customButtonColor.dart';
import '../../../../component/customButtonPrimary.dart';
import '../../../../component/notifError.dart';

class Addewallet extends StatefulWidget {
  const Addewallet({super.key});

  @override
  State<Addewallet> createState() => _AddewalletState();
}

class _AddewalletState extends State<Addewallet> {
  Apiewallet _apiewallet = Apiewallet();
  final TextEditingController namecontroler = TextEditingController();
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    _requestPermission();
    super.initState();
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
          'Tambah EWallet',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          minimum: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Stack(
            children: [
              SingleChildScrollView(
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
                          labelForm('E-Wallet'),
                          Inputtextfield(
                              hintText: 'Masukan Nama E-Wallet',
                              controller: namecontroler,
                              keyboardType: TextInputType.name),
                          labelForm('Gambar Qr-Code'),
                          Container(
                            padding: const EdgeInsets.all(8),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: Color(0xFFFFF9E6),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SvgPicture.asset('asset/image/info-circle.svg'),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Text(
                                  ' Upload Gambar QR Code e-wallet anda',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Color(0xFFE5851F)),
                                ),
                              ],
                            ),
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
                                margin: EdgeInsets.only(top: 8),
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
                                                width: 24,
                                                height: 24,
                                              ),
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              const Text(
                                                'Tambah Foto',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                        0xFFA8A8A8)),
                                              )
                                            ],
                                          ),
                                        ),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: namecontroler.text.isNotEmpty && _image != null
                        ? customButtonPrimary(
                            alignment: Alignment.center,
                            height: 48,
                            onPressed: () async {
                              await _apiewallet.addEwallet(
                                  name: namecontroler.text, image: _image);
                              if (_apiewallet.statusCode == 200 ||
                                  _apiewallet.statusCode == 201) {
                                Navigator.pop(context,
                                    'Berhasil Menambahkan Ewallet baru');
                              } else {
                                Notiferror.showNotif(
                                    context: context,
                                    description: _apiewallet.message);
                              }
                            },
                            child: const Text(
                              'Simpan',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF)),
                            ))
                        : CustombuttonColor(
                            color: const Color(0xFFDEDEDE),
                            alignment: Alignment.center,
                            height: 48,
                            onPressed: () {
                              // Navigator.pop(context);
                            },
                            child: const Text(
                              'Selanjutnya',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF717179)),
                            )),
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
