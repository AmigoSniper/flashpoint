import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class Detailbarang extends StatefulWidget {
  const Detailbarang({super.key});

  @override
  State<Detailbarang> createState() => _DetailbarangState();
}

class _DetailbarangState extends State<Detailbarang> {
  final numberFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  File? _image;
  bool permissionGalery = false;
  TextEditingController namecontroler = TextEditingController();
  TextEditingController deskripsicontroler = TextEditingController();
  TextEditingController hargacontroler = TextEditingController();
  TextEditingController stockcontroler = TextEditingController();
  final ScrollController _scrollController = new ScrollController();
  bool read = true;
  bool focusname = false;
  bool focusDeskripsi = false;
  bool focusHarga = false;
  bool focusStock = false;
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeDeskripsi = FocusNode();
  FocusNode _focusNodeharga = FocusNode();
  FocusNode _focusNodestock = FocusNode();
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

  void _showForm(
      BuildContext context, String namaBarang, String title, bool delete) {
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF000000)),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (delete == true) {
                      Navigator.pop(
                          context, 'Barang $namaBarang berhasil dihapus!');
                    } else if (delete == false) {
                      Navigator.pop(
                          context, 'Barang $namaBarang berhasil diupdate!');
                    } else {}
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(48))),
                      backgroundColor: const Color(0xFF00409A),
                      minimumSize: const Size(double.infinity, 50)),
                  child: Text(
                    'Ya, saya yakin',
                    style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF)),
                  )),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(48))),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 50)),
                  child: Text(
                    'Tidak, batal',
                    style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB71221)),
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    namecontroler = TextEditingController(text: 'Sepatu “Nike” ');
    deskripsicontroler = TextEditingController(
        text:
            'Dengan design yang menarik, teknologi inovatif, dan kualitas yang terjamin, sepatu Nike menjadi pilihan utama');
    hargacontroler = TextEditingController(text: numberFormat.format(500000));
    stockcontroler = TextEditingController(text: '5');
    _requestPermission();
    hargacontroler.addListener(() {
      String text = hargacontroler.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isNotEmpty) {
        final formattedValue = numberFormat.format(int.parse(text));
        hargacontroler.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    });
    _focusNodeName.addListener(() {
      setState(() {
        focusname = _focusNodeName.hasFocus;
      });
    });
    _focusNodeDeskripsi.addListener(() {
      setState(() {
        focusDeskripsi = _focusNodeDeskripsi.hasFocus;
      });
    });
    _focusNodeharga.addListener(() {
      setState(() {
        focusHarga = _focusNodeharga.hasFocus;
      });
    });
    _focusNodestock.addListener(() {
      setState(() {
        focusStock = _focusNodestock.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNodeName.dispose();
    _focusNodeDeskripsi.dispose();
    _focusNodeharga.dispose();
    _focusNodestock.dispose();
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
        title: Text(
          !read ? 'Edit barang' : 'Detail Barang',
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: const Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFFFFFFF),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namecontroler.text,
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: const Color(0xFF303030)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: 297,
                            height: 176,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _image != null
                                  ? Image.file(
                                      _image!,
                                      height: 176,
                                      width: 297,
                                    )
                                  : const Placeholder(
                                      fallbackHeight: 100, fallbackWidth: 100),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      !read
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      _pickImage();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                color: Color(0xFF002A66)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        minimumSize:
                                            const Size(double.infinity, 50)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.edit_outlined,
                                            color: Color(0xFF002A66)),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Ganti Foto',
                                          style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF002A66)),
                                        )
                                      ],
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                labelForm('Nama Barang'),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 1,
                                              color: Colors.black
                                                  .withOpacity(0.2)))),
                                  child: TextField(
                                    keyboardType: TextInputType.text,
                                    controller: namecontroler,
                                    focusNode: _focusNodeName,
                                    readOnly: read,
                                    style: GoogleFonts.openSans(
                                        color: const Color(0xFF101010),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                    decoration: InputDecoration(
                                        hintStyle: GoogleFonts.openSans(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: const Color(0xFFA8A8A8)),
                                        hintText: 'Masukkan nama barang',
                                        border: InputBorder.none),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                            )
                          : const SizedBox.shrink(),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1,
                                    color: Colors.black.withOpacity(0.2)))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            labelForm('Deskripsi'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1,
                                          color:
                                              Colors.black.withOpacity(0.2)))),
                              child: TextField(
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.justify,
                                controller: deskripsicontroler,
                                focusNode: _focusNodeDeskripsi,
                                readOnly: read,
                                minLines: 1,
                                maxLines: 3,
                                style: GoogleFonts.openSans(
                                    color: const Color(0xFF101010),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                                decoration: InputDecoration(
                                    hintStyle: GoogleFonts.openSans(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: const Color(0x28A74599)),
                                    hintText: 'Masukkan deskripsi barang',
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            labelForm('Harga'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1,
                                          color:
                                              Colors.black.withOpacity(0.2)))),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: hargacontroler,
                                focusNode: _focusNodeharga,
                                readOnly: read,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onSubmitted: (value) {
                                  print(value);
                                  String harganya =
                                      value.replaceAll(RegExp(r'[^\d]'), '');
                                  print(harganya);
                                  int hargatotal = int.parse(harganya);
                                  print(hargatotal + 10000);
                                },
                                style: GoogleFonts.openSans(
                                    color: const Color(0xFF101010),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                                decoration: InputDecoration(
                                    hintStyle: GoogleFonts.openSans(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: const Color(0xFFA8A8A8)),
                                    hintText: 'Masukkan harga barang',
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            labelForm('Stok'),
                            Container(
                                padding: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Colors.black
                                                .withOpacity(0.2)))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      !read ? 'Barang Masuk' : 'Stok Tersedia',
                                      style: GoogleFonts.openSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFFB1B5C0)),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: stockcontroler,
                                        focusNode: _focusNodestock,
                                        readOnly: read,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        style: GoogleFonts.openSans(
                                            color: const Color(0xFF101010),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                        decoration: InputDecoration(
                                            hintStyle: GoogleFonts.openSans(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: const Color(0xFFA8A8A8)),
                                            hintText: '1',
                                            border: InputBorder.none),
                                      ),
                                    )
                                  ],
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            read
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            read = !read;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(48))),
                                            backgroundColor:
                                                const Color(0xFF00409A),
                                            minimumSize: const Size(
                                                double.infinity, 50)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.edit_outlined,
                                                color: Color(0xFFFFFFFF)),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Edit Barang',
                                              style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFFFFFFFF)),
                                            )
                                          ],
                                        )),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              if (namecontroler
                                                      .value.text.isNotEmpty &&
                                                  deskripsicontroler
                                                      .value.text.isNotEmpty &&
                                                  hargacontroler
                                                      .value.text.isNotEmpty &&
                                                  stockcontroler
                                                      .value.text.isNotEmpty) {
                                                _showForm(
                                                    context,
                                                    namecontroler.text,
                                                    'Apakah anda yakin ingin mengupdate barang ${namecontroler.text} ?',
                                                    false);
                                              } else {
                                                AnimatedSnackBar.material(
                                                  'Pastikan data sudaht terisi!',
                                                  type: AnimatedSnackBarType
                                                      .error,
                                                ).show(context);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    48))),
                                                backgroundColor:
                                                    const Color(0xFF00409A),
                                                minimumSize: const Size(
                                                    double.infinity, 50)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.save_outlined,
                                                    color: Color(0xFFFFFFFF)),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Update Barang',
                                                  style: GoogleFonts.openSans(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFFFFFFFF)),
                                                )
                                              ],
                                            )),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              _showForm(
                                                  context,
                                                  namecontroler.text,
                                                  'Apakah anda yakin ingin menghapus barang ${namecontroler.text}?',
                                                  true);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    48))),
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                minimumSize: const Size(
                                                    double.infinity, 50)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.delete_outline,
                                                    color: Color(0xFFFF3E1D)),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Hapus Barang',
                                                  style: GoogleFonts.openSans(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFFFF3E1D)),
                                                )
                                              ],
                                            )),
                                      )
                                    ],
                                  )
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          )),
    );
  }

  Widget labelForm(String judul) {
    return Text(
      judul,
      style: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF303030)),
    );
  }
}
