import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salescheck/Model/outlets.dart';
import 'package:salescheck/component/inputTextField.dart';

import '../../../Model/Outlet.dart';
import '../../../Model/User.dart';
import '../../../Service/ApiOutlet.dart';
import '../../../Service/ApiPegawai.dart';
import '../../../component/customButtonPrimary.dart';
import '../../../component/customButtonColor.dart';
import '../../../component/customDropDown.dart';
import '../../../component/notifError.dart';

class Editoutlet extends StatefulWidget {
  final Outlets outlet;
  const Editoutlet({super.key, required this.outlet});

  @override
  State<Editoutlet> createState() => _EditoutletState();
}

class _EditoutletState extends State<Editoutlet> {
  final Apioutlet _api = new Apioutlet();
  final Apipegawai _apipegawai = new Apipegawai();
  File? _image;
  bool permissionGalery = false;
  final TextEditingController namecontroler = TextEditingController();
  final TextEditingController alamatcontroler = TextEditingController();
  final TextEditingController searchcontroler = TextEditingController();
  final ScrollController _scrollController = new ScrollController();
  final _formKey = GlobalKey<FormState>();
  bool focusname = false;
  bool focusalamat = false;
  String? selectCoordinator;
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodealamat = FocusNode();
  List<User> userkoordinatorOptions = [];
  List<String> koordinatorOptions = [];
  int? idKoordinator;
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

  Future<void> _readAndPrintPegawaiData() async {
    print('Get api category');
    userkoordinatorOptions = await _apipegawai.getPegawaiApi();
    print(userkoordinatorOptions.length);
    if (_apipegawai.statusCode == 200) {
      setState(() {
        for (var element in userkoordinatorOptions) {
          koordinatorOptions.add(element.name);
        }
      });
      print(koordinatorOptions.length);
    } else {
      print(_api.message);
      print('Panjang data');
      print(koordinatorOptions.length);
    }
  }

  Future<void> selectKoordinator() async {
    final koordinator = userkoordinatorOptions.firstWhere(
      (koordinator) => koordinator.name == selectCoordinator,
    );

    // Ambil id_outlet
    setState(() {
      idKoordinator = koordinator.id;
    });
    print(idKoordinator);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readAndPrintPegawaiData();
    selectCoordinator = widget.outlet.nameUser;
    idKoordinator = widget.outlet.koordinator;
    namecontroler.text = widget.outlet.namaOutlet ?? '';
    alamatcontroler.text = widget.outlet.alamat ?? '';
    _requestPermission();
    _focusNodeName.addListener(() {
      setState(() {
        focusname = _focusNodeName.hasFocus;
      });
    });
    _focusNodealamat.addListener(() {
      setState(() {
        focusalamat = _focusNodealamat.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNodeName.dispose();
    _focusNodealamat.dispose();
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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Edit Cabang',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    labelForm('Nomor Cabang'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 0),
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color: Color(0XFFF6F6F6)),
                                      child: TextFormField(
                                        initialValue:
                                            widget.outlet.idOutlet.toString() ??
                                                '',
                                        enabled: false,
                                        // validator: (value) {
                                        //   if (value == null || value.isEmpty) {
                                        //     return 'Isi data lebih dahulu';
                                        //   }
                                        //   return null;
                                        // },
                                        style: const TextStyle(
                                            color: Color(0xFFA8A8A8),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                        decoration: const InputDecoration(
                                            hintStyle: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Color(0xFFA8A8A8)),
                                            hintText: 'Masukkan nama cabang',
                                            border: InputBorder.none),
                                      ),
                                    ),
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
                                    Container(
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
                                              ? GestureDetector(
                                                  onTap: () {
                                                    if (permissionGalery ==
                                                        true) {
                                                      _pickImage();
                                                    } else {
                                                      _requestPermission();
                                                    }
                                                  },
                                                  child: Image.file(
                                                    _image!,
                                                    height: 100,
                                                    width: 100,
                                                  ),
                                                )
                                              : Container(
                                                  alignment: Alignment.center,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xFFF6F6F6)),
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                          width: 105,
                                                          height: 105,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.blue,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  ColorFiltered(
                                                                      colorFilter:
                                                                          ColorFilter
                                                                              .mode(
                                                                        Colors
                                                                            .black
                                                                            .withOpacity(0.2),
                                                                        BlendMode
                                                                            .darken,
                                                                      ),
                                                                      child: Image
                                                                          .network(
                                                                        _api.getImage(widget
                                                                            .outlet
                                                                            .image),
                                                                        errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) {
                                                                          return Image
                                                                              .asset(
                                                                            'asset/kelolaOutlet/Frame.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            width:
                                                                                105,
                                                                            height:
                                                                                105,
                                                                          );
                                                                        },
                                                                      )))),
                                                      SizedBox(
                                                        height: 24,
                                                        width: 67,
                                                        child: TextButton(
                                                            style: TextButton.styleFrom(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 4,
                                                                    horizontal:
                                                                        8),
                                                                backgroundColor:
                                                                    const Color(
                                                                            0xFFFFFFFF)
                                                                        .withOpacity(
                                                                            0.3)),
                                                            onPressed: () {
                                                              if (permissionGalery ==
                                                                  true) {
                                                                _pickImage();
                                                              } else {
                                                                _requestPermission();
                                                              }
                                                            },
                                                            child: const Text(
                                                              'Edit Foto',
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color(
                                                                      0xFFFFFFFF)),
                                                            )),
                                                      )
                                                    ],
                                                  )),
                                        )),
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
                                    labelForm('Nama Cabang'),
                                    Inputtextfield(
                                        hintText: 'Masukkan nama cabang',
                                        focus: _focusNodeName,
                                        controller: namecontroler,
                                        keyboardType: TextInputType.text),
                                    labelForm('Alamat'),
                                    Inputtextfield(
                                      hintText: 'Masukan Alamat',
                                      keyboardType: TextInputType.text,
                                      controller: alamatcontroler,
                                      focus: _focusNodealamat,
                                      minline: 3,
                                      maxline: 3,
                                    )
                                  ],
                                ),
                              )),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Color(0xFFFFFFFF)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Koordinator Outlet',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF09090B)),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                const Text(
                                  'Pegawai',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8D8D8D)),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Customdropdown(
                                    data: koordinatorOptions,
                                    selectValue: selectCoordinator,
                                    onChanged: (p0) {
                                      setState(() {
                                        selectCoordinator = p0;
                                      });
                                      selectKoordinator();
                                    },
                                    hintText: 'Pilih Kategori',
                                    heightItem: 50)
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            decoration:
                                const BoxDecoration(color: Color(0xFFF6F8FA)),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    {
                                      'message':
                                          'Cabang ${widget.outlet.namaOutlet} berhasil dihapus',
                                      'isDeleted': true,
                                    },
                                  );
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
                                  'Hapus Outlet',
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          alignment: Alignment.center,
                          height: 48,
                          color: const Color(0xFFF6F6F6),
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
                            await _api.editOutletApi(
                                id: widget.outlet.idOutlet ?? 0,
                                nama: namecontroler.text,
                                alamat: alamatcontroler.text,
                                image: _image,
                                KoordinatorId: idKoordinator);

                            if (_api.statusCode == 200 ||
                                _api.statusCode == 201) {
                              Navigator.pop(
                                context,
                                {
                                  'message':
                                      'Berhasil mengedit Toko ${namecontroler.text}',
                                  'isDeleted': false,
                                },
                              );
                            } else {
                              Notiferror.showNotif(
                                  context: context, description: _api.message);
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
            color: Color(0xFFAAAAAA)),
      ),
    );
  }
}
