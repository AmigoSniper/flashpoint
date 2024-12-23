import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salescheck/Model/User.dart';
import 'package:salescheck/Service/ApiOutlet.dart';
import 'package:salescheck/Service/ApiPegawai.dart';
import 'package:salescheck/component/customButtonColor.dart';
import 'package:salescheck/component/customDropDown.dart';
import 'package:salescheck/component/inputTextField.dart';

import '../../../Service/Api.dart';
import '../../../component/customButtonPrimary.dart';

class Addoutlet extends StatefulWidget {
  const Addoutlet({super.key});

  @override
  State<Addoutlet> createState() => _AddoutletState();
}

class _AddoutletState extends State<Addoutlet> {
  // final Api _api = new Api();
  final Apioutlet _api = new Apioutlet();
  final Apipegawai _apipegawai = new Apipegawai();
  File? _image;
  bool permissionGalery = false;
  bool info = true;
  int stepindex = 1;
  int? idKoordinator;
  List<String> step = [
    'Detail cabang',
    'Pilih koordinator cabang',
    'Tambah Produk'
  ];
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
      print(_image?.path);
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

  void _skipimportForm(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apakah anda yakin? ',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000)),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'Untuk mempermudah, anda dapat mengimpor produk dari toko utama ke cabang yang baru anda buat',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF717179)),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
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
                          print(_image?.path);
                          print('id koordinator = $idKoordinator');
                          await _api.addOutletApi(
                              nama: namecontroler.text,
                              alamat: alamatcontroler.text,
                              image: _image,
                              KoordinatorId: idKoordinator,
                              syaratKetentuan: true);
                          Navigator.pop(context);
                          Navigator.pop(
                              context, 'Berhasil menambahkan cabang baru');
                        },
                        child: const Text(
                          'Lewati',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF)),
                        )),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
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
          'Tambah Cabang',
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
                                  margin: const EdgeInsets.only(bottom: 10),
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
                          info
                              ? Container(
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
                                      const Flexible(
                                        child: Text(
                                          'Ikuti langkah-langkah berikut untuk membuka cabang',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: Color(0xFFE5851F)),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              info = false;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Color(0xFFE5851F),
                                            size: 24,
                                          ))
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Step $stepindex',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Color(0xFF717179)),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      step[stepindex - 1],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF09090B)),
                                    ),
                                    Text(
                                      '$stepindex/${step.length}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Color(0xFF717179)),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                LinearProgressIndicator(
                                  value: stepindex / step.length,
                                  color: const Color(0xFF2E6CE9),
                                  minHeight: 2,
                                )
                              ],
                            ),
                          ),
                          stepindex == 1
                              ? Container(
                                  margin: const EdgeInsets.only(bottom: 70),
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                          color: Colors
                                                              .transparent)
                                                      : Border.all(
                                                          width: 1,
                                                          color: const Color(
                                                              0xFFC9C9CE)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
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
                                                    : Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: Color(
                                                                    0xFFF6F6F6)),
                                                        child: Column(
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
                                                                      FontWeight
                                                                          .w500,
                                                                  color: const Color(
                                                                      0xFFA8A8A8)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                              )),
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
                                        labelForm('Nama Cabang'),
                                        Inputtextfield(
                                            hintText: 'Masukkan nama cabang',
                                            controller: namecontroler,
                                            onChanged: (p0) {},
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
                                  ))
                              : (stepindex == 2
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Color(0xFFFFFFFF)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Koordinator cabang',
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
                                                  selectKoordinator();
                                                });
                                              },
                                              hintText: 'Pilih Koordinator',
                                              heightItem: 50)
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 518,
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'asset/kelolaOutlet/login.svg'),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          const Text(
                                            'Import data produk',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF09090B)),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          const Text(
                                            'Untuk mempermudah, anda dapat mengimpor produk dari toko utama ke cabang yang baru anda buat',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF717179)),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          customButtonPrimary(
                                              width: 168.5,
                                              height: 48,
                                              alignment: Alignment.center,
                                              onPressed: () {},
                                              child: const Text(
                                                'import',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFFFFFFF)),
                                              ))
                                        ],
                                      ),
                                    ))
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
                    stepindex > 1
                        ? Flexible(
                            child: CustombuttonColor(
                                onPressed: () {
                                  if (stepindex <= step.length) {
                                    setState(() {
                                      stepindex -= 1;
                                    });
                                  }
                                },
                                alignment: Alignment.center,
                                height: 48,
                                color: const Color(0xFFF6F6F6),
                                child: const Text(
                                  'Sebelumnya',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF09090B)),
                                )),
                          )
                        : Flexible(
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
                    stepindex == step.length
                        ? Flexible(
                            child: CustombuttonColor(
                                onPressed: () {
                                  _skipimportForm(context);
                                },
                                alignment: Alignment.center,
                                height: 48,
                                color: const Color(0xFFF6F6F6),
                                child: const Text(
                                  'Lewati',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF09090B)),
                                )),
                          )
                        : Flexible(
                            child: customButtonPrimary(
                                alignment: Alignment.center,
                                height: 48,
                                onPressed: () {
                                  if (stepindex <= step.length) {
                                    setState(() {
                                      stepindex += 1;
                                    });
                                  }
                                },
                                child: const Text(
                                  'Lanjutkan',
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
