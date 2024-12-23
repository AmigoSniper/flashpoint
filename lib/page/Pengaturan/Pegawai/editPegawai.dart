import 'dart:io';

import 'package:avatar_plus/avatar_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salescheck/Model/Pegawai.dart';
import 'package:salescheck/Model/User.dart';
import 'package:salescheck/Service/Api.dart';
import 'package:salescheck/Service/ApiPegawai.dart';
import 'package:salescheck/component/customButtonColor.dart';
import 'package:salescheck/component/notifSucces.dart';

import '../../../component/customButtonPrimary.dart';
import '../../../component/customDropDown.dart';
import '../../../component/inputTextField.dart';
import '../../../component/notifError.dart';

class Editpegawai extends StatefulWidget {
  final User user;
  const Editpegawai({super.key, required this.user});

  @override
  State<Editpegawai> createState() => _EditpegawaiState();
}

class _EditpegawaiState extends State<Editpegawai> {
  final Apipegawai _apipegawai = new Apipegawai();
  final Api _api = Api();
  File? _image;
  bool permissionGalery = false;
  bool info = true;
  int stepindex = 1;
  List<String> step = [
    'Detail cabang',
    'Pilih koordinator cabang',
    'Tambah Produk'
  ];
  final TextEditingController namecontroler = TextEditingController();
  final TextEditingController passwordcontroler = TextEditingController();
  final TextEditingController emailcontroler = TextEditingController();
  final TextEditingController searchcontroler = TextEditingController();
  final ScrollController _scrollController = new ScrollController();
  final _formKey = GlobalKey<FormState>();
  bool focusname = false;
  bool focuspassword = false;
  bool focusemail = false;
  String? selectRole;
  String selectActive = 'Aktif';
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeemail = FocusNode();
  FocusNode _focusNodepassword = FocusNode();
  List<String> roleOptions = ['Admin', 'Manajer', 'Kasir'];
  List<String> activeOptions = ['Aktif', 'Nonaktif'];
  String? tokenNew;
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
    super.initState();
    namecontroler.text = widget.user.name;
    emailcontroler.text = widget.user.email;
    selectRole = widget.user.role;
    statusChange(widget.user);
    _requestPermission();
    _focusNodeName.addListener(() {
      setState(() {
        focusname = _focusNodeName.hasFocus;
      });
    });

    _focusNodeemail.addListener(() {
      setState(() {
        focusemail = _focusNodeemail.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNodeName.dispose();
    _focusNodeemail.dispose();
  }

  void statusChange(User user) {
    if (user.status == 'Active') {
      setState(() {
        selectActive = 'Aktif';
      });
    } else {
      setState(() {
        selectActive = 'Nonaktif';
      });
    }
  }

  bool validForm() {
    final form = _formKey.currentState;
    if (form != null && form.validate() && _image != null) {
      return true;
    } else {
      return false;
    }
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
        title: const Text(
          'Edit Pegawai',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          permissionGalery
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: const EdgeInsets.all(8),
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFFFF9E6),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SvgPicture.asset(
                                          'asset/image/info-circle.svg'),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Untuk memudahkan dalam upload foto',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Color(0xFFE5851F)),
                                          ),
                                          Text(
                                            'Izinkan mengakses galeri',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Color(0xFFE5851F)),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                          Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Foto',
                                      style: TextStyle(
                                        color: Color(0xFF8D8D8D),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
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
                                          width: 105,
                                          height: 105,
                                          padding: EdgeInsets.zero,
                                          decoration: BoxDecoration(
                                              border: _image != null
                                                  ? Border.all(
                                                      width: 0,
                                                      color: Colors.transparent)
                                                  : Border.all(
                                                      width: 1,
                                                      color: const Color(
                                                          0xFFC9C9CE)),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          alignment: Alignment.centerLeft,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: _image != null
                                                  ? Image.file(
                                                      _image!,
                                                      height: 100,
                                                      width: 100,
                                                    )
                                                  : Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Image.network(
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return AvatarPlus(
                                                                widget
                                                                    .user.name);
                                                          },
                                                          _apipegawai.getImage(
                                                              widget.user
                                                                      .image ??
                                                                  ''),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                      0xFF000000)
                                                                  .withOpacity(
                                                                      0.25)),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 4,
                                                                    horizontal:
                                                                        8),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            50)),
                                                                    color: const Color(
                                                                            0xFFFFFFFF)
                                                                        .withOpacity(
                                                                            0.3)),
                                                                child:
                                                                    const Text(
                                                                  'Edit Foto',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Color(
                                                                          0xFFFFFFFF)),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ))),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    const Text(
                                      'Gunakan foto dengan rasio 1:1, Upload dalam format .jpg/.png ukuran maksimal 5 mb',
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Color(0xFF8D8D8D),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    labelForm('Nama'),
                                    Inputtextfield(
                                      hintText: 'Masukan Nama',
                                      keyboardType: TextInputType.text,
                                      controller: namecontroler,
                                      focus: _focusNodeName,
                                    ),
                                    labelForm('Email'),
                                    Inputtextfield(
                                      hintText: 'Masukkan email',
                                      keyboardType: TextInputType.text,
                                      controller: emailcontroler,
                                      focus: _focusNodeemail,
                                    ),
                                    labelForm('Password'),
                                    Inputtextfield(
                                      hintText: 'Masukkan Password',
                                      keyboardType: TextInputType.text,
                                      controller: passwordcontroler,
                                      focus: _focusNodepassword,
                                    ),
                                    labelForm('Role'),
                                    Customdropdown(
                                        selectValue: selectRole,
                                        data: roleOptions,
                                        onChanged: (p0) {
                                          setState(() {
                                            selectRole = p0;
                                          });
                                        },
                                        hintText: 'Pilih role',
                                        heightItem: 50),
                                    labelForm('Status'),
                                    Customdropdown(
                                        data: activeOptions,
                                        onChanged: (p0) {
                                          setState(() {
                                            selectActive = p0!;
                                          });
                                        },
                                        selectValue: selectActive,
                                        hintText: 'Pilih Status',
                                        heightItem: 50),
                                    labelForm('ID Token'),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 11, horizontal: 16),
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                            color: Color(0xFFF6F6F6),
                                          ),
                                          child: (tokenNew != null &&
                                                  tokenNew!.isNotEmpty)
                                              ? Text(
                                                  tokenNew!,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: const TextStyle(
                                                    color: Color(0xFF09090B),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              : (widget.user.tokenLogin !=
                                                          null &&
                                                      widget.user.tokenLogin!
                                                          .isNotEmpty)
                                                  ? Text(
                                                      widget.user.tokenLogin!,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF09090B),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'ID Token belum tersedia',
                                                      overflow:
                                                          TextOverflow.visible,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFFAAAAAA),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Flexible(
                                            child: CustombuttonColor(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 11,
                                                        horizontal: 16),
                                                color: const Color(0xFFF6F6F6),
                                                height: 40,
                                                onPressed: () async {
                                                  String? token =
                                                      await _apipegawai
                                                          .generateToken(
                                                              widget.user.id);
                                                  if (_apipegawai.statusCode ==
                                                      200) {
                                                    setState(() {
                                                      tokenNew = token;
                                                    });
                                                    print(
                                                        'Tokennya lur $token');
                                                    Notifsucces.showNotif(
                                                        context: context,
                                                        description:
                                                            'Buat Token Berhasil');
                                                  }
                                                },
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.refresh),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      'Buat Token',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF09090B),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ))),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                          Container(
                            decoration:
                                const BoxDecoration(color: Color(0xFFF6F8FA)),
                            child: ElevatedButton(
                                onPressed: () async {
                                  await _apipegawai.deletePegawaitApi(
                                      idPegawai: widget.user.id);
                                  if (_apipegawai.statusCode == 200 ||
                                      _apipegawai.statusCode == 201) {
                                    Navigator.pop(
                                      context,
                                      {
                                        'message':
                                            'Pegawai ${namecontroler.text} berhasil dihapus',
                                        'isDeleted': true,
                                      },
                                    );
                                  } else {
                                    Notiferror.showNotif(
                                        context: context,
                                        description: _apipegawai.message);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    shadowColor: Colors.transparent,
                                    minimumSize:
                                        const Size(double.infinity, 50)),
                                child: const Text(
                                  'Hapus Pegawai',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF3E1D)),
                                )),
                          ),
                          const SizedBox(
                            height: 80,
                          )
                        ],
                      ),
                    )),
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF09090B)),
                          )),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child: customButtonPrimary(
                          alignment: Alignment.center,
                          height: 48,
                          onPressed: () async {
                            await _apipegawai.editPegawaiApi(
                                id: widget.user.id,
                                nama: namecontroler.text,
                                email: emailcontroler.text,
                                password: passwordcontroler.text,
                                role: selectRole ?? '',
                                status: selectActive == 'Aktif'
                                    ? 'Active'
                                    : 'Inactive',
                                image: _image);
                            if (_apipegawai.statusCode == 200 ||
                                _apipegawai.statusCode == 201) {
                              Navigator.pop(
                                context,
                                {
                                  'message':
                                      'Pegawai ${namecontroler.text} berhasil disimpan',
                                  'isDeleted': false,
                                },
                              );
                            } else {
                              Notiferror.showNotif(
                                  context: context,
                                  description: _apipegawai.message);
                            }
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFFFF)),
                          )),
                    )
                  ],
                ),
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
