import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as Svg;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:intl/intl.dart';
import 'package:salescheck/component/customDropDown.dart';
import 'package:salescheck/page/Login/loginform.dart';

import '../../Service/Api.dart';
import '../../component/customButtonPrimary.dart';
import '../landingPage/landingPage.dart';

class Signupformklien extends StatefulWidget {
  final String email;
  final String password;
  final String role;
  const Signupformklien(
      {super.key,
      required this.email,
      required this.password,
      required this.role});

  @override
  State<Signupformklien> createState() => _SignupformklienState();
}

class _SignupformklienState extends State<Signupformklien> {
  final Api _api = Api();
  final TextEditingController namecontroler = TextEditingController();
  final TextEditingController tanggalcontroler = TextEditingController();
  final TextEditingController kelamincontroler = TextEditingController();
  bool focusname = false;
  FocusNode _focusNodeName = FocusNode();
  List<String> genderOptions = ['Pria', 'Wanita'];
  String? selectedValue;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
    super.dispose();
  }

  Widget labelForm(String judul) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        judul,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF979899)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
            centerTitle: true,
            titleSpacing: 0,
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'asset/image/celocelo.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'Flashpoint',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xFFFFFFFF)),
                  )
                ],
              ),
            )),
        body: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              'asset/background/BgformNew.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            SafeArea(
              bottom: true,
              child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lengkapi Profile Anda',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Lengkapi form dibawah untuk membuat akun',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Color(0xFFCBD5E1)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    labelForm('Nama Lengkap'),
                                    Container(
                                        // height: 72,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF6F6F6),
                                            border: focusname
                                                ? Border.all(
                                                    width: 1,
                                                    color:
                                                        const Color(0xFF101010))
                                                : Border.all(
                                                    width: 0,
                                                    color: const Color(
                                                        0xFFF6F6F6)),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  controller: namecontroler,
                                                  focusNode: _focusNodeName,
                                                  obscuringCharacter: '*',
                                                  style: const TextStyle(
                                                      color: Color(0xFF101010),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14),
                                                  decoration:
                                                      const InputDecoration(
                                                          hintStyle: TextStyle(
                                                              color: Color(
                                                                  0xFFA8A8A8)),
                                                          hintText:
                                                              'Tulis nama lengkap',
                                                          border:
                                                              InputBorder.none),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                    labelForm('Tanggal Lahir'),
                                    Container(
                                        // height: 72,
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF6F6F6),
                                            border: Border.all(
                                                width: 0,
                                                color: const Color(0xFFF6F6F6)),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child:
                                                      FormBuilderDateTimePicker(
                                                    onChanged: (value) {
                                                      print(value);
                                                      setState(() {});
                                                    },
                                                    format: DateFormat(
                                                        'dd MMMM yyyy'),
                                                    name: 'Tanggal',
                                                    lastDate: DateTime.now(),
                                                    controller:
                                                        tanggalcontroler,
                                                    initialEntryMode:
                                                        DatePickerEntryMode
                                                            .calendar,
                                                    inputType: InputType.date,
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF101010),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14),
                                                    decoration:
                                                        const InputDecoration(
                                                            hintStyle: TextStyle(
                                                                color: Color(
                                                                    0xFFA8A8A8)),
                                                            hintText:
                                                                'dd/mm/yyyy',
                                                            border: InputBorder
                                                                .none),
                                                  )),
                                            ),
                                            Center(
                                              child: tanggalcontroler
                                                      .text.isEmpty
                                                  ? const Icon(
                                                      Icons.calendar_month,
                                                      size: 16,
                                                      color: Color(0xff6C7278),
                                                    )
                                                  : IconButton(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        setState(() {
                                                          tanggalcontroler
                                                              .clear();
                                                        });
                                                      },
                                                      icon: const Icon(
                                                        Icons.clear,
                                                        size: 16,
                                                        color:
                                                            Color(0xff6C7278),
                                                      )),
                                            ),
                                          ],
                                        )),
                                    labelForm('Jenis Kelamin'),
                                    Customdropdown(
                                        selectValue: selectedValue,
                                        data: genderOptions,
                                        onChanged: (p0) {
                                          setState(() {
                                            selectedValue = p0;
                                          });
                                        },
                                        hintText: 'Pilih jenis kelamin',
                                        heightItem: 50),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    customButtonPrimary(
                                        height: 50,
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        onPressed: () async {
                                          await _api.signup(
                                              namecontroler.text,
                                              widget.email,
                                              widget.password,
                                              widget.role);
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const Loginform()),
                                          );
                                        },
                                        child: const Text(
                                          'Buat akun',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Color(0xFFFFFFFF)),
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ));
  }
}
