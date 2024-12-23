import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salescheck/Service/ApiEwallet.dart';
import 'package:salescheck/component/inputTextField.dart';

import '../../../../Model/eWalletModel.dart';
import '../../../../component/customButtonColor.dart';
import '../../../../component/customButtonPrimary.dart';
import '../../../../component/notifError.dart';

class Editwallet extends StatefulWidget {
  final Ewalletmodel ewalletmodel;
  const Editwallet({super.key, required this.ewalletmodel});

  @override
  State<Editwallet> createState() => _EditwalletState();
}

class _EditwalletState extends State<Editwallet> {
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

  void _deleteForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                color: const Color(0xFFE9E9E9),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Text(
                'Apakah anda yakin ingin menghapus eWallet ${widget.ewalletmodel.namaEwallet}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000)),
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
                          height: 48,
                          alignment: Alignment.center,
                          color: const Color(0xFFF7F7F7),
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
                    width: 8,
                  ),
                  Flexible(
                      child: CustombuttonColor(
                          height: 48,
                          alignment: Alignment.center,
                          color: const Color(0xFFFF3E1D),
                          onPressed: () async {
                            await _apiewallet
                                .deleteEwallet(widget.ewalletmodel.id ?? 0);
                            if (_apiewallet.statusCode == 204 ||
                                _apiewallet.statusCode == 201) {
                              Navigator.pop(context);
                              Navigator.pop(
                                context,
                                {
                                  'message':
                                      'Ewallet ${widget.ewalletmodel.namaEwallet} berhasil dihapus!',
                                  'isDeleted': true,
                                },
                              );
                            } else {}
                          },
                          child: const Text(
                            'Ya, saya yakin',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFFFF)),
                          )))
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    _requestPermission();
    namecontroler.text = widget.ewalletmodel.namaEwallet!;
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
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                              color: Color(0xFFF6F6F6)),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CachedNetworkImage(
                                                fit: BoxFit.fitWidth,
                                                imageUrl: _apiewallet.getImage(
                                                    widget.ewalletmodel.image ??
                                                        ''),
                                                progressIndicatorBuilder:
                                                    (context, url, progress) {
                                                  return Center(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        value: progress
                                                                    .totalSize !=
                                                                null
                                                            ? progress
                                                                    .downloaded /
                                                                (progress
                                                                        .totalSize ??
                                                                    1)
                                                            : null,
                                                      ),
                                                      if (progress.totalSize !=
                                                          null)
                                                        Text(
                                                          '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                    ],
                                                  ));
                                                },
                                                errorWidget:
                                                    (context, url, error) {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
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
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                                0xFFA8A8A8)),
                                                      )
                                                    ],
                                                  );
                                                },
                                              ),
                                              Container(
                                                height: 26,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 8),
                                                decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                43)),
                                                    color: Color(0xFFFFFFFF)),
                                                child: const Text(
                                                  'Ubah Foto',
                                                  style: const TextStyle(
                                                      color: Color(0xFF30363D),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: const BoxDecoration(color: Color(0xFFF6F8FA)),
                      child: ElevatedButton(
                          onPressed: () {
                            _deleteForm(context);
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              backgroundColor: const Color(0xFFFFFFFF),
                              shadowColor: Colors.transparent,
                              minimumSize: const Size(double.infinity, 50)),
                          child: const Text(
                            'Hapus Produk',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF3E1D)),
                          )),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: namecontroler.text.isNotEmpty
                        ? customButtonPrimary(
                            alignment: Alignment.center,
                            height: 48,
                            onPressed: () async {
                              await _apiewallet.editEwallet(
                                  id: widget.ewalletmodel.id ?? 0,
                                  name: namecontroler.text,
                                  image: _image);
                              if (_apiewallet.statusCode == 200 ||
                                  _apiewallet.statusCode == 201) {
                                Navigator.pop(
                                  context,
                                  {
                                    'message':
                                        'Berhasil mengubah Ewallet ${namecontroler.text}',
                                    'isDeleted': false,
                                  },
                                );
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
