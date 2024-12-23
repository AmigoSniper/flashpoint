import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salescheck/Model/struckModel.dart';
import 'package:salescheck/Service/Apistrucksetting.dart';
import 'package:salescheck/component/customButtonPrimary.dart';
import 'package:salescheck/component/customDropDown.dart';
import 'package:salescheck/component/inputTextField.dart';
import 'package:salescheck/page/Pengaturan/Struk/previewStruk.dart';

class Struk extends StatefulWidget {
  const Struk({super.key});

  @override
  State<Struk> createState() => _StrukState();
}

class _StrukState extends State<Struk> {
  final Apistrucksetting _apistrucksetting = new Apistrucksetting();
  struckModel? struck = struckModel();
  File? _image;
  bool permissionGalery = false;
  bool logo = false;
  bool namaToko = false;
  bool alamat = false;
  bool kontak = false;
  bool socialMedia = false;
  bool catatan = false;

  final TextEditingController namecontroler = TextEditingController();
  final TextEditingController alamatcontroler = TextEditingController();
  final TextEditingController contactcontroler = TextEditingController();
  final TextEditingController catatancontroler = TextEditingController();
  final TextEditingController sosmed1controler = TextEditingController();
  final TextEditingController sosmed2controler = TextEditingController();

  final TextEditingController searchcontroler = TextEditingController();
  final ScrollController _scrollController = new ScrollController();
  final _formKey = GlobalKey<FormState>();
  bool focusname = false;
  bool focusalamat = false;
  bool focuscontact = false;
  bool focusemail = false;
  bool focuscatatan = false;
  bool focusSosmed1 = false;
  bool focusSosmed2 = false;

  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeAlamat = FocusNode();
  FocusNode _focusNodeContact = FocusNode();
  FocusNode _focusNodecatatan = FocusNode();
  FocusNode _focusNodeSosmed1 = FocusNode();
  FocusNode _focusNodeSosmed2 = FocusNode();

  String? selectSosmed1 = 'FB';
  String? selectSosmed2 = 'IG';
  List<String> sosmedOption = ['FB', 'IG', 'TW'];

  int length = 0;

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
      await _apistrucksetting.editlogoStruckSetting(File(croppedFile.path),
          struck!.data!.detailStrukLogo!.last.detailStrukLogoId ?? 0);
      return File(croppedFile.path);
    }
    return null;
  }

  void _previewStruck(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      scrollControlDisabledMaxHeightRatio: 300,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 30, right: 16, bottom: 30, left: 16),
          child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 26),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border:
                      Border.all(width: 1, color: const Color(0xFFAAAAAAAA))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          !logo
                              ? const SizedBox.shrink()
                              : _image == null
                                  ? const SizedBox.shrink()
                                  : Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      width: 84,
                                      height: 84,
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      alignment: Alignment.centerLeft,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            _image!,
                                            height: 84,
                                            width: 84,
                                          ))),
                          !namaToko
                              ? const SizedBox.shrink()
                              : Text(
                                  namecontroler.text,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF09090B),
                                      fontWeight: FontWeight.w600),
                                ),
                          !alamat
                              ? const SizedBox.shrink()
                              : Text(
                                  alamatcontroler.text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF09090B),
                                      fontWeight: FontWeight.w500),
                                ),
                          !kontak
                              ? const SizedBox.shrink()
                              : Text(
                                  'No. Telp ${contactcontroler.text}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF09090B),
                                      fontWeight: FontWeight.w500),
                                ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No. Order : #0899',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF09090B)),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Waktu : 12 Feb 2024, 08.30',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF09090B)),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Kasir : Nama Kasir',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF09090B)),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Pembayaran : -',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF09090B)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      width: double.infinity,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '1',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF09090B)),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Nama Barang',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF09090B)),
                                  ),
                                ],
                              ),
                              Text(
                                'Rp 10.000',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '1',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF09090B)),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Nama Barang',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF09090B)),
                                  ),
                                ],
                              ),
                              Text(
                                'Rp 10.000',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const DottedLine(
                      dashColor: Color(0xFFCBD5E1),
                      lineThickness: 1,
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Sub Total',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ),
                              Text(
                                'Rp 30.000',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Pajak 10%',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ),
                              Text(
                                'Rp 3.000',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Diskon 8.8',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ),
                              Text(
                                '-Rp 13.000',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF09090B)),
                              ),
                              Text(
                                'Rp 20.000',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF09090B)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Kembali',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF09090B)),
                              ),
                              Text(
                                'Rp 2.000',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF09090B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    !socialMedia
                        ? const SizedBox.shrink()
                        : Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '$selectSosmed1 : ${sosmed1controler.text}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF09090B)),
                                ),
                                Text(
                                  '$selectSosmed2 : ${sosmed2controler.text}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF09090B)),
                                ),
                              ],
                            ),
                          ),
                    !catatan
                        ? const SizedBox.shrink()
                        : Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Text(
                              catatancontroler.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xFF09090B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: const Text(
                        'Powered by Sirqu POS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF717179),
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }

  Future<void> _readAndPrintStruck() async {
    struck = await _apistrucksetting.getStruckSetting();
    print('Struk');
    if (struck != null &&
        struck!.data != null &&
        struck!.data!.struks != null &&
        struck!.data!.struks!.isNotEmpty) {
      print(struck!.data!.struks!.first.status);
      setState(() {
        logo = struck!.data!.struks![0].status == 'true';
        namaToko = struck!.data!.struks![1].status == 'true';
        alamat = struck!.data!.struks![2].status == 'true';
        kontak = struck!.data!.struks![3].status == 'true';
        socialMedia = struck!.data!.struks![4].status == 'true';
        catatan = struck!.data!.struks![5].status == 'true';

        selectSosmed1 = struck!.data!.detailStrukMedia![0].kategori;
        selectSosmed2 = struck!.data!.detailStrukMedia![1].kategori;

        // Check if detailStrukTeks is not null and has enough entries
        namecontroler.text = struck!.data!.detailStrukTeks?.isNotEmpty ?? false
            ? struck!.data!.detailStrukTeks![0].text ?? ''
            : '';
        alamatcontroler.text =
            struck!.data!.detailStrukTeks?.isNotEmpty ?? false
                ? struck!.data!.detailStrukTeks![1].text ?? ''
                : '';
        contactcontroler.text =
            struck!.data!.detailStrukTeks?.isNotEmpty ?? false
                ? struck!.data!.detailStrukTeks![2].text ?? ''
                : '';
        catatancontroler.text =
            struck!.data!.detailStrukTeks?.isNotEmpty ?? false
                ? struck!.data!.detailStrukTeks![3].text ?? ''
                : '';

        // Check if detailStrukMedia is not null and has enough entries
        sosmed1controler.text =
            struck!.data!.detailStrukMedia?.isNotEmpty ?? false
                ? struck!.data!.detailStrukMedia![0].nameMedia ?? ''
                : '';
        sosmed2controler.text =
            struck!.data!.detailStrukMedia?.isNotEmpty ?? false
                ? struck!.data!.detailStrukMedia![1].nameMedia ?? ''
                : '';
      });
    } else {
      print('Struck data is null or incomplete.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _requestPermission();

    _focusNodeName.addListener(() {
      setState(() {
        focusname = _focusNodeName.hasFocus;
      });
    });

    _focusNodeAlamat.addListener(() {
      setState(() {
        focusalamat = _focusNodeAlamat.hasFocus;
      });
    });
    _focusNodeContact.addListener(() {
      setState(() {
        focuscontact = _focusNodeContact.hasFocus;
      });
    });
    _focusNodecatatan.addListener(() {
      setState(() {
        focuscatatan = _focusNodecatatan.hasFocus;
      });
    });
    _focusNodeSosmed1.addListener(() {
      setState(() {
        focusSosmed1 = _focusNodeSosmed1.hasFocus;
      });
    });
    _focusNodeSosmed2.addListener(() {
      setState(() {
        focusSosmed2 = _focusNodeSosmed2.hasFocus;
      });
    });
    _readAndPrintStruck();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNodeName.dispose();
    _focusNodeAlamat.dispose();
    _focusNodeContact.dispose();
    _focusNodecatatan.dispose();
    _focusNodeSosmed1.dispose();
    _focusNodeSosmed2.dispose();
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
          'Struk',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customButtonPrimary(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Previewstruk(
                              image: _image,
                              logo: logo,
                              namaToko: namaToko,
                              alamat: alamat,
                              kontak: kontak,
                              socialMedia: socialMedia,
                              catatan: catatan,
                              name: namecontroler.text,
                              alamattext: alamatcontroler.text,
                              kontaktext: contactcontroler.text,
                              socialMedia1text:
                                  '$selectSosmed1 : ${sosmed1controler.text}',
                              socialMedia2text:
                                  '$selectSosmed2 : ${sosmed2controler.text}',
                              catatantext: catatancontroler.text,
                              imageUrl: _apistrucksetting.getImage(
                                struck!.data!.detailStrukLogo!.first.logo ?? '',
                              ),
                            ),
                          ));
                    },
                    height: 48,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('asset/struk/play.svg'),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Priview Struk',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SvgPicture.asset(
                        'asset/image/info-circle.svg',
                        color: const Color(0xFF0EA5E9),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Flexible(
                        child: Text(
                          'Aktifkan dan lengkapi item dibawah jika anda ingin informasi tersebut muncul pada struk',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xFF0EA5E9)),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Logo',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF09090B)),
                            ),
                            SizedBox(
                                width: 44,
                                height: 24,
                                child: CupertinoSwitch(
                                  activeColor: const Color(0xFF10B981),
                                  trackColor: const Color(0xFFE2E8F0),
                                  thumbColor: const Color(0xFFFFFFFF),
                                  value: logo,
                                  onChanged: (value) async {
                                    setState(() {
                                      logo = value;
                                    });
                                    await _apistrucksetting
                                        .editstatusStruckSetting(
                                            struck!.data!.struks![0].id ?? 0,
                                            logo);
                                  },
                                )),
                          ],
                        ),
                        !logo
                            ? const SizedBox.shrink()
                            : SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 18,
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
                                                : Container(
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Color(
                                                                0xFFF6F6F6)),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        width: 100,
                                                        height: 100,
                                                        imageUrl:
                                                            _apistrucksetting
                                                                .getImage(
                                                          struck!
                                                                  .data!
                                                                  .detailStrukLogo!
                                                                  .first
                                                                  .logo ??
                                                              '',
                                                        ),
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                progress) {
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
                                                                        (progress.totalSize ??
                                                                            1)
                                                                    : null,
                                                              ),
                                                              if (progress
                                                                      .totalSize !=
                                                                  null)
                                                                Text(
                                                                  '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                            ],
                                                          ));
                                                        },
                                                        errorWidget: (context,
                                                            url, error) {
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
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: const Color(
                                                                        0xFFA8A8A8)),
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
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
                                  ],
                                ),
                              ),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Nama Toko',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF09090B)),
                            ),
                            SizedBox(
                                width: 44,
                                height: 24,
                                child: CupertinoSwitch(
                                  activeColor: const Color(0xFF10B981),
                                  trackColor: const Color(0xFFE2E8F0),
                                  thumbColor: const Color(0xFFFFFFFF),
                                  value: namaToko,
                                  onChanged: (value) async {
                                    setState(() {
                                      namaToko = value;
                                    });
                                    await _apistrucksetting
                                        .editstatusStruckSetting(
                                            struck!.data!.struks![1].id ?? 0,
                                            namaToko);
                                  },
                                )),
                          ],
                        ),
                        !namaToko
                            ? const SizedBox.shrink()
                            : SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Inputtextfield(
                                      hintText: 'Masukkan Nama',
                                      keyboardType: TextInputType.text,
                                      controller: namecontroler,
                                      focus: _focusNodeName,
                                      onSubmit: () async {
                                        await _apistrucksetting
                                            .editdetailtextStruckSetting(
                                                struck!
                                                        .data!
                                                        .detailStrukTeks![0]
                                                        .detailStrukTeksId ??
                                                    0,
                                                namecontroler.text,
                                                struck!
                                                        .data!
                                                        .detailStrukTeks![0]
                                                        .struksId ??
                                                    0);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Alamat',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF09090B)),
                            ),
                            SizedBox(
                                width: 44,
                                height: 24,
                                child: CupertinoSwitch(
                                  activeColor: const Color(0xFF10B981),
                                  trackColor: const Color(0xFFE2E8F0),
                                  thumbColor: const Color(0xFFFFFFFF),
                                  value: alamat,
                                  onChanged: (value) async {
                                    setState(() {
                                      alamat = value;
                                    });
                                    await _apistrucksetting
                                        .editstatusStruckSetting(
                                            struck!.data!.struks![2].id ?? 0,
                                            alamat);
                                  },
                                )),
                          ],
                        ),
                        !alamat
                            ? const SizedBox.shrink()
                            : SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Inputtextfield(
                                      hintText: 'Masukkan Alamat',
                                      keyboardType: TextInputType.text,
                                      controller: alamatcontroler,
                                      focus: _focusNodeAlamat,
                                      onSubmit: () async {
                                        await _apistrucksetting
                                            .editdetailtextStruckSetting(
                                                struck!
                                                        .data!
                                                        .detailStrukTeks![1]
                                                        .detailStrukTeksId ??
                                                    0,
                                                alamatcontroler.text,
                                                struck!
                                                        .data!
                                                        .detailStrukTeks![1]
                                                        .struksId ??
                                                    0);
                                      },
                                    )
                                  ],
                                ),
                              ),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Kontak',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF09090B)),
                            ),
                            SizedBox(
                                width: 44,
                                height: 24,
                                child: CupertinoSwitch(
                                  activeColor: const Color(0xFF10B981),
                                  trackColor: const Color(0xFFE2E8F0),
                                  thumbColor: const Color(0xFFFFFFFF),
                                  value: kontak,
                                  onChanged: (value) async {
                                    setState(() {
                                      kontak = value;
                                    });
                                    await _apistrucksetting
                                        .editstatusStruckSetting(
                                            struck!.data!.struks![3].id ?? 0,
                                            kontak);
                                  },
                                )),
                          ],
                        ),
                        !kontak
                            ? const SizedBox.shrink()
                            : SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Inputtextfield(
                                      hintText: 'Masukkan Nomer Telpon',
                                      keyboardType: TextInputType.number,
                                      controller: contactcontroler,
                                      focus: _focusNodeContact,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      onSubmit: () async {
                                        await _apistrucksetting
                                            .editdetailtextStruckSetting(
                                                struck!
                                                        .data!
                                                        .detailStrukTeks![2]
                                                        .detailStrukTeksId ??
                                                    0,
                                                contactcontroler.text,
                                                struck!
                                                        .data!
                                                        .detailStrukTeks![2]
                                                        .struksId ??
                                                    0);
                                      },
                                    )
                                  ],
                                ),
                              ),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Social Media',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF09090B)),
                            ),
                            SizedBox(
                                width: 44,
                                height: 24,
                                child: CupertinoSwitch(
                                  activeColor: const Color(0xFF10B981),
                                  trackColor: const Color(0xFFE2E8F0),
                                  thumbColor: const Color(0xFFFFFFFF),
                                  value: socialMedia,
                                  onChanged: (value) async {
                                    setState(() {
                                      socialMedia = value;
                                    });
                                    await _apistrucksetting
                                        .editstatusStruckSetting(
                                            struck!.data!.struks![4].id ?? 0,
                                            socialMedia);
                                  },
                                )),
                          ],
                        ),
                        !socialMedia
                            ? const SizedBox.shrink()
                            : SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      width: double.infinity,
                                      height: 40,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Customdropdown(
                                              margin: const EdgeInsets.only(
                                                  right: 15),
                                              width: 87,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 11,
                                                      horizontal: 16),
                                              data: sosmedOption,
                                              selectValue: selectSosmed1,
                                              onChanged: (String? value) async {
                                                setState(() {
                                                  selectSosmed1 = value!;
                                                });
                                                await _apistrucksetting
                                                    .editdetailmediaStruckSetting(
                                                        struck!
                                                                .data!
                                                                .detailStrukTeks![
                                                                    0]
                                                                .detailStrukTeksId ??
                                                            0,
                                                        sosmed1controler.text,
                                                        struck!
                                                                .data!
                                                                .detailStrukTeks![
                                                                    0]
                                                                .struksId ??
                                                            0,
                                                        selectSosmed1 ?? '');
                                              },
                                              hintText: 'Pilih Sosial Media',
                                              heightItem: 40),
                                          Flexible(
                                            child: Inputtextfield(
                                              alignment: Alignment.centerLeft,
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 0),
                                              keyboardType: TextInputType.text,
                                              controller: sosmed1controler,
                                              focus: _focusNodeSosmed1,
                                              hintText: 'Cont : @sirqu_malang',
                                              onSubmit: () async {
                                                await _apistrucksetting
                                                    .editdetailmediaStruckSetting(
                                                        struck!
                                                                .data!
                                                                .detailStrukTeks![
                                                                    0]
                                                                .detailStrukTeksId ??
                                                            0,
                                                        sosmed1controler.text,
                                                        struck!
                                                                .data!
                                                                .detailStrukTeks![
                                                                    0]
                                                                .struksId ??
                                                            0,
                                                        selectSosmed1 ?? '');
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      width: double.infinity,
                                      height: 40,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Customdropdown(
                                              margin: const EdgeInsets.only(
                                                  right: 15),
                                              width: 87,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 11,
                                                      horizontal: 16),
                                              data: sosmedOption,
                                              selectValue: selectSosmed2,
                                              onChanged: (String? value) async {
                                                setState(() {
                                                  selectSosmed2 = value!;
                                                });
                                                await _apistrucksetting
                                                    .editdetailmediaStruckSetting(
                                                        struck!
                                                                .data!
                                                                .detailStrukTeks![
                                                                    1]
                                                                .detailStrukTeksId ??
                                                            0,
                                                        sosmed2controler.text,
                                                        struck!
                                                                .data!
                                                                .detailStrukTeks![
                                                                    1]
                                                                .struksId ??
                                                            0,
                                                        selectSosmed2 ?? '');
                                              },
                                              hintText: 'Pilih Sosial Media',
                                              heightItem: 40),
                                          Flexible(
                                            child: Inputtextfield(
                                              alignment: Alignment.centerLeft,
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 0),
                                              keyboardType: TextInputType.text,
                                              controller: sosmed2controler,
                                              focus: _focusNodeSosmed2,
                                              hintText: 'Cont : @sirqu_malang',
                                              onSubmit: () async {
                                                await _apistrucksetting
                                                    .editdetailmediaStruckSetting(
                                                        struck!
                                                                .data!
                                                                .detailStrukTeks![
                                                                    1]
                                                                .detailStrukTeksId ??
                                                            0,
                                                        sosmed2controler.text,
                                                        struck!
                                                                .data!
                                                                .detailStrukTeks![
                                                                    1]
                                                                .struksId ??
                                                            0,
                                                        selectSosmed2 ?? '');
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Catatan',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF09090B)),
                            ),
                            SizedBox(
                                width: 44,
                                height: 24,
                                child: CupertinoSwitch(
                                  activeColor: const Color(0xFF10B981),
                                  trackColor: const Color(0xFFE2E8F0),
                                  thumbColor: const Color(0xFFFFFFFF),
                                  value: catatan,
                                  onChanged: (value) async {
                                    setState(() {
                                      catatan = value;
                                    });
                                    await _apistrucksetting
                                        .editstatusStruckSetting(
                                            struck!.data!.struks![5].id ?? 0,
                                            catatan);
                                  },
                                )),
                          ],
                        ),
                        !catatan
                            ? const SizedBox.shrink()
                            : SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Inputtextfield(
                                      keyboardType: TextInputType.text,
                                      controller: catatancontroler,
                                      focus: _focusNodecatatan,
                                      minline: 3,
                                      maxline: 3,
                                      maxLength: 100,
                                      hintText: 'Masukkan Catatan',
                                      onChanged: (value) {
                                        setState(() {
                                          length = catatancontroler.text.length;
                                        });
                                      },
                                      onSubmit: () async {
                                        await _apistrucksetting
                                            .editdetailtextStruckSetting(
                                                struck!
                                                        .data!
                                                        .detailStrukTeks![3]
                                                        .detailStrukTeksId ??
                                                    0,
                                                catatancontroler.text,
                                                struck!
                                                        .data!
                                                        .detailStrukTeks![3]
                                                        .struksId ??
                                                    0);
                                      },
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '$length/100 char',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFAAAAAA)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ],
                    )),
              ],
            ),
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
