// ignore: file_names
import 'package:flutter/material.dart';
import 'package:salescheck/Service/ApiCategory.dart';
import 'package:salescheck/component/customButtonColor.dart';

import '../../component/inputTextField.dart';

class Editcategory extends StatefulWidget {
  final String category;
  final int idCategory;
  final int jumlahBarang;
  const Editcategory(
      {super.key,
      required this.category,
      required this.idCategory,
      required this.jumlahBarang});

  @override
  State<Editcategory> createState() => _EditcategoryState();
}

class _EditcategoryState extends State<Editcategory> {
  final Apicategory _apicategory = new Apicategory();
  final TextEditingController namecontroler = TextEditingController();
  FocusNode _focusNodeName = FocusNode();
  bool focusname = false;
  int length = 0;
  void _showForm(
    BuildContext context,
    int categoryID,
    String nama,
  ) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                color: const Color(0xFFE9E9E9),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Text(
                'Barang dalam kategori $nama akan ikut terhapus, Apakah anda yakin untuk menghapus kategori?',
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
                        margin: const EdgeInsets.only(top: 10),
                        height: 48,
                        alignment: Alignment.center,
                        color: const Color(0xFFFFFFFF),
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child: const Text(
                          'Tidak, Batal',
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
                    child: CustombuttonColor(
                        margin: const EdgeInsets.only(top: 10),
                        height: 48,
                        alignment: Alignment.center,
                        color: const Color(0xFFFF3E1D),
                        onPressed: () async {
                          await _apicategory.deleteCategory(categoryID);
                          if (_apicategory.statusCode == 201 ||
                              _apicategory.statusCode == 200) {
                            Navigator.pop(
                              context,
                            );
                            Navigator.pop(context,
                                'Kategori ${namecontroler.text} berhasil dihapus!');
                          } else {}
                        },
                        child: const Text(
                          'Ya, Hapus',
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
  void initState() {
    // TODO: implement initState
    super.initState();
    namecontroler.text = widget.category;
    length = namecontroler.text.length;
    _focusNodeName.addListener(() {
      setState(() {
        focusname = _focusNodeName.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNodeName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Edit Kategori',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 15),
                        // height: 120,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius:
                                BorderRadius.all(const Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nama Kategori',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF979899)),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Inputtextfield(
                                controller: namecontroler,
                                hintText: 'Masukkan Nama Kategori',
                                onChanged: (p0) {
                                  setState(() {
                                    length = namecontroler.text.length;
                                  });
                                },
                                keyboardType: TextInputType.text),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              '$length/20 char',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF979899)),
                            ),
                          ],
                        ),
                      ),
                      CustombuttonColor(
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 48,
                          alignment: Alignment.center,
                          color: const Color(0xFFFFFFFF),
                          onPressed: () async {
                            if (widget.jumlahBarang >= 2) {
                              _showForm(
                                  context, widget.idCategory, widget.category);
                            } else {
                              await _apicategory
                                  .deleteCategory(widget.idCategory);
                              if (_apicategory.statusCode == 201 ||
                                  _apicategory.statusCode == 200) {
                                Navigator.pop(context,
                                    'Kategori ${namecontroler.text} berhasil dihapus!');
                              }
                            }
                          },
                          child: const Text(
                            'Hapus Kategori',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF3E1D)),
                          ))
                    ],
                  ),
                  Container(
                    height: 68,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: const BoxDecoration(color: Color(0xFFF6F8FA)),
                    child: ElevatedButton(
                        onPressed: () async {
                          if (namecontroler.text.isNotEmpty) {
                            await _apicategory.editCategory(
                                namecontroler.text, widget.idCategory);
                            if (_apicategory.statusCode == 201 ||
                                _apicategory.statusCode == 200) {
                              Navigator.pop(context,
                                  'Kategori ${namecontroler.text} berhasil dirubah!');
                            } else {}
                          } else {
                            null;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            backgroundColor: namecontroler.text.isNotEmpty
                                ? const Color(0xFF0747CB)
                                : const Color(0xFFDEDEDE),
                            minimumSize: const Size(double.infinity, 50)),
                        child: Text(
                          'Simpan Kategori',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: namecontroler.text.isNotEmpty
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF717179)),
                        )),
                  )
                ],
              ))),
    );
  }
}
