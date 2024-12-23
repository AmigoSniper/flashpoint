import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:salescheck/component/customButtonPrimary.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/category.dart';
import '../../Service/ApiCategory.dart';
import '../../Service/ApiProduct.dart';
import '../../component/customButtonColor.dart';
import '../../component/customDropDown.dart';
import '../../component/inputTextField.dart';

class Editbarang extends StatefulWidget {
  final int idProduct;
  final String name;
  final String deskripis;
  final int categoryRelasi;
  final int harga;
  final String category;
  final int imageRelasi;
  final String imageUrl;
  final int idOutlet;
  final int stock;
  final bool unlimitedStock;

  const Editbarang(
      {super.key,
      required this.name,
      required this.deskripis,
      required this.harga,
      required this.imageUrl,
      required this.category,
      required this.unlimitedStock,
      required this.idOutlet,
      required this.idProduct,
      required this.stock,
      required this.categoryRelasi,
      required this.imageRelasi});

  @override
  State<Editbarang> createState() => _EditbarangState();
}

class _EditbarangState extends State<Editbarang> {
  int? idCategory;
  final Apicategory _api = Apicategory();
  final Apiproduct _apiproduct = Apiproduct();
  List<Category> categoryOption = [Category()];
  final numberFormat = NumberFormat('#,##0', 'id');
  File? _image;
  bool permissionGalery = false;
  final TextEditingController namecontroler = TextEditingController();
  final TextEditingController deskripsicontroler = TextEditingController();
  final TextEditingController hargacontroler = TextEditingController();
  final TextEditingController stockcontroler = TextEditingController();
  final TextEditingController searchcontroler = TextEditingController();
  final ScrollController _scrollController = new ScrollController();
  final _formKey = GlobalKey<FormState>();
  bool focusname = false;
  bool focusDeskripsi = false;
  bool focusHarga = false;
  bool focusStock = false;
  bool stokcTakTerbatas = false;
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeDeskripsi = FocusNode();
  FocusNode _focusNodeharga = FocusNode();
  FocusNode _focusNodestock = FocusNode();
  String? selectedKategori;
  List<String> kategoriOptions = [];

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
      BuildContext context,
      int productId,
      String nama,
      String description,
      double price,
      int idCategory,
      int idoutlet,
      bool unlimitedStock) {
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
                'Apakah anda yakin ingin menyimpan produk $nama?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000)),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await _apiproduct.editProductApi(
                        image: _image,
                        productId: productId,
                        nama: nama,
                        description: description,
                        price: price,
                        idCategory: idCategory,
                        idOutlet: idoutlet,
                        unlimitedStock: unlimitedStock,
                        idRelasiImage: widget.imageRelasi,
                        idRelasiCategory: widget.categoryRelasi);
                    Navigator.pop(context);
                    Navigator.pop(
                      context,
                      {
                        'message': 'Barang $nama berhasil disimpan!',
                        'isDeleted': false,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(48))),
                      backgroundColor: const Color(0xFF0D50D7),
                      minimumSize: const Size(double.infinity, 50)),
                  child: const Text(
                    'Ya, saya yakin',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF)),
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
                  child: const Text(
                    'Tidak, batal',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF3E1D)),
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _readAndPrintCategoryData() async {
    print('Get api category');
    final prefs = await SharedPreferences.getInstance();
    categoryOption = await _api.getCategory();
    if (_api.statusCode == 200) {
      setState(() {
        for (var element in categoryOption) {
          kategoriOptions.add(element.namaKategori!);
          print(element.idKategori);
          print(element.namaKategori);
        }
      });
    } else {
      print(_api.message);
    }
  }

  Future<void> selectCategory() async {
    print(selectedKategori);
    final category = categoryOption.firstWhere(
      (category) => category.namaKategori == selectedKategori,
      orElse: () => Category(),
    );

    // Ambil id_outlet
    setState(() {
      idCategory = category.idKategori;
    });

    print(idCategory);
    print(category.namaKategori);
  }

  void _deleteForm(BuildContext context, String namaBarang) {
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
                'Apakah anda yakin ingin menghapus produk $namaBarang?',
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
                            await _apiproduct.deleteProduct(widget.idProduct);
                            if (_apiproduct.statusCode == 204 ||
                                _apiproduct.statusCode == 201) {
                              Navigator.pop(context);
                              Navigator.pop(
                                context,
                                {
                                  'message': '$namaBarang berhasil dihapus!',
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

  bool validForm() {
    final form = _formKey.currentState;
    if (form != null &&
        form.validate() &&
        (_image != null || widget.imageUrl.isNotEmpty)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readAndPrintCategoryData();
    namecontroler.text = widget.name;
    deskripsicontroler.text = widget.deskripis;
    selectedKategori = widget.category;
    hargacontroler.text = numberFormat.format(widget.harga);
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
        title: const Text(
          'Edit Barang',
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
                                    const Text(
                                      'Detail Barang',
                                      style: TextStyle(
                                          color: Color(0xFF09090B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    const Text(
                                      'Foto Barang',
                                      style: TextStyle(
                                        color: Color(0xFF8D8D8D),
                                        fontSize: 12,
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
                                                              color: Colors
                                                                  .transparent,
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
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          0.2),
                                                                  BlendMode
                                                                      .darken,
                                                                ),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: 105,
                                                                  height: 105,
                                                                  imageUrl: _apiproduct
                                                                      .getImage(
                                                                          widget
                                                                              .imageUrl),
                                                                  progressIndicatorBuilder:
                                                                      (context,
                                                                          url,
                                                                          progress) {
                                                                    return Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        value: progress.totalSize !=
                                                                                null
                                                                            ? progress.downloaded /
                                                                                (progress.totalSize ?? 1)
                                                                            : null,
                                                                      ),
                                                                    );
                                                                  },
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Icon(
                                                                          Icons
                                                                              .error),
                                                                ),
                                                              ))),
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
                                    labelForm('Nama Barang'),
                                    Inputtextfield(
                                        hintText: 'Masukkan nama barang',
                                        controller: namecontroler,
                                        onChanged: (p0) {},
                                        focus: _focusNodeName,
                                        keyboardType: TextInputType.text),
                                    labelForm('Deskripsi'),
                                    Inputtextfield(
                                      hintText: 'Masukkan deskripsi barang',
                                      keyboardType: TextInputType.text,
                                      controller: deskripsicontroler,
                                      focus: _focusNodeDeskripsi,
                                      maxline: 3,
                                      minline: 3,
                                    ),
                                    labelForm('Kategori'),
                                    Customdropdown(
                                        data: kategoriOptions,
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedKategori = value;
                                            selectCategory();
                                          });
                                        },
                                        hintText: 'Pilih kategori',
                                        selectValue: selectedKategori,
                                        heightItem: 50),
                                    labelForm('Harga'),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 0),
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                            color: Color(0XFFF6F6F6)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Rp',
                                              style: TextStyle(
                                                  color: Color(0xFFA8A8A8),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Flexible(
                                                child: Inputtextfield(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: hargacontroler,
                                              focus: _focusNodeharga,
                                              maxLength: 10,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              hintText: 'Masukkan harga barang',
                                            ))
                                          ],
                                        )),
                                  ],
                                ),
                              )),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            decoration:
                                const BoxDecoration(color: Color(0xFFF6F8FA)),
                            child: ElevatedButton(
                                onPressed: () {
                                  if (validForm()) {
                                    String harganya = hargacontroler.text
                                        .replaceAll(RegExp(r'[^\d]'), '');
                                    print(harganya);
                                    int hargatotal = int.parse(harganya);
                                    print(hargatotal + 10000);
                                    _deleteForm(context, namecontroler.text);
                                  } else {
                                    AnimatedSnackBar.material(
                                      'Pastikan data sudaht terisi!',
                                      type: AnimatedSnackBarType.error,
                                    ).show(context);
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
                                  'Hapus Produk',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF3E1D)),
                                )),
                          ),
                          const SizedBox(
                            height: 70,
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
                  decoration: const BoxDecoration(color: Color(0xFFF6F8FA)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: customButtonPrimary(
                      height: 50,
                      alignment: Alignment.center,
                      onPressed: () {
                        if (validForm()) {
                          String harganya = hargacontroler.text
                              .replaceAll(RegExp(r'[^\d]'), '');
                          print(harganya);
                          double hargatotal = double.parse(harganya);
                          print(hargatotal + 10000);

                          _showForm(
                              context,
                              widget.idProduct,
                              namecontroler.text,
                              deskripsicontroler.text,
                              hargatotal,
                              idCategory ?? 0,
                              widget.idOutlet,
                              widget.unlimitedStock);
                        } else {
                          AnimatedSnackBar.material(
                            'Pastikan data sudaht terisi!',
                            type: AnimatedSnackBarType.error,
                          ).show(context);
                        }
                      },
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: validForm()
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF717179)),
                      ))))
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8D8D8D)),
      ),
    );
  }
}
