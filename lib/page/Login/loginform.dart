import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salescheck/Service/Api.dart';
import 'package:salescheck/component/customButtonPrimary.dart';
import 'package:salescheck/component/inputTextField.dart';
import 'package:salescheck/component/notifError.dart';
import 'package:salescheck/component/notifSucces.dart';
import 'package:salescheck/page/Signup/signupform.dart';
import 'package:salescheck/page/landingPage/landingPage.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Loginform extends StatefulWidget {
  const Loginform({super.key});

  @override
  State<Loginform> createState() => _LoginformState();
}

class _LoginformState extends State<Loginform> {
  final Api _api = Api();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroler = TextEditingController();
  final TextEditingController tokencontroler = TextEditingController();
  String initialCountry = 'ID';
  String? countryCode;
  bool focusemail = false;
  bool focuspass = false;
  bool focustoken = false;
  bool passSecure = true;
  bool tokenSecure = true;
  bool rememberMe = false;
  FocusNode _focusNodeemail = FocusNode();
  FocusNode _focusNodePass = FocusNode();
  FocusNode _focusNodeToken = FocusNode();
  bool isSelectTab1 = true;
  bool isSelectTab2 = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNodeemail.addListener(() {
      setState(() {
        focusemail = _focusNodeemail.hasFocus;
      });
    });
    _focusNodePass.addListener(() {
      setState(() {
        focuspass = _focusNodePass.hasFocus;
      });
    });
    _focusNodeToken.addListener(() {
      setState(() {
        focustoken = _focusNodeToken.hasFocus;
      });
    });
  }

  Widget TabButton(BuildContext context, String textTitle, bool isSelected) {
    return Expanded(
      child: Container(
        height: 31,
        decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //     color: isSelected
            //         ? Colors.black.withOpacity(0.2)
            //         : Colors.transparent,
            //     spreadRadius: -1,
            //     blurRadius: 2.7,
            //     offset: const Offset(2, 2),
            //   ),
            // ],
            color: isSelected ? const Color(0xFFFFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        child: ElevatedButton(
            onPressed: isSelected
                ? null
                : () {
                    setState(() {
                      if (isSelectTab1 == true) {
                        isSelectTab1 = false;
                        isSelectTab2 = true;
                      } else if (isSelectTab1 == false) {
                        isSelectTab1 = true;
                        isSelectTab2 = false;
                      }
                    });
                  },
            style: ButtonStyle(
                backgroundColor: isSelected
                    ? WidgetStateProperty.all(const Color(0xFFFFFFFF))
                    : WidgetStateProperty.all(Colors.transparent),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                overlayColor: WidgetStateProperty.all(Colors.transparent)),
            child: Center(
              child: Text(textTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF333333))),
            )),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNodeemail.dispose();
    _focusNodePass.dispose();
    _focusNodeToken.dispose();
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
        body: Stack(fit: StackFit.expand, children: [
          SvgPicture.asset(
            'asset/background/BgformNew.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            top: false,
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
                              'Selamat Datang di Flashpoint',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Masukkan nomor telepon dan password untuk login',
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
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                height: 39,
                                width: 360,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF6F6F6),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    TabButton(context, 'Email', isSelectTab1),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    TabButton(context, 'ID-Token', isSelectTab2)
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            isSelectTab1 == true
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'Email',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF979899)),
                                        ),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF6F6F6),
                                              border: focusemail
                                                  ? Border.all(
                                                      width: 1,
                                                      color: const Color(
                                                          0xFF101010))
                                                  : Border.all(
                                                      width: 0,
                                                      color: const Color(
                                                          0xFFF6F6F6)),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Inputtextfield(
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            controller: emailcontroller,
                                            focus: _focusNodeemail,
                                            hintText: 'Nomor Email Anda',
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 16, bottom: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'kata Sandi',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF979899)),
                                            ),
                                            TextButton(
                                                onPressed: () {},
                                                style: ButtonStyle(
                                                    padding: WidgetStateProperty
                                                        .all<EdgeInsets>(
                                                            EdgeInsets.zero),
                                                    minimumSize:
                                                        WidgetStateProperty.all(
                                                            const Size(0, 0)),
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    overlayColor:
                                                        WidgetStateProperty.all(
                                                            Colors
                                                                .transparent)),
                                                child: const Text(
                                                  'Lupa Password ?',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color: Color(0xFF2E6CE9)),
                                                ))
                                          ],
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 0),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF6F6F6),
                                              border: focuspass
                                                  ? Border.all(
                                                      width: 1,
                                                      color: const Color(
                                                          0xFF101010))
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
                                                        const EdgeInsets.only(
                                                            right: 16),
                                                    child: Inputtextfield(
                                                      controller:
                                                          passwordcontroler,
                                                      focus: _focusNodePass,
                                                      password: passSecure,
                                                      keyboardType:
                                                          TextInputType.text,
                                                    )),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      passSecure = !passSecure;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    passSecure
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: passSecure
                                                        ? const Color(
                                                            0xFFACB5BB)
                                                        : const Color(
                                                            0xFF101010),
                                                    size: 16,
                                                  )),
                                            ],
                                          )),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(top: 8, bottom: 8),
                                        child: Text(
                                          'ID Token',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF979899)),
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 0),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF6F6F6),
                                              border: focustoken
                                                  ? Border.all(
                                                      width: 1,
                                                      color: const Color(
                                                          0xFF101010))
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
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16),
                                                    child: Inputtextfield(
                                                      controller:
                                                          tokencontroler,
                                                      focus: _focusNodeToken,
                                                      password: tokenSecure,
                                                      maxLength: 20,
                                                      hintText:
                                                          'Masukkan 16 digit token',
                                                      keyboardType:
                                                          TextInputType.text,
                                                    )),
                                              ),
                                              IconButton(
                                                  style: IconButton.styleFrom(
                                                    iconSize: 16,
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    setState(() {
                                                      tokenSecure =
                                                          !tokenSecure;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    tokenSecure
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: tokenSecure
                                                        ? const Color(
                                                            0xFFACB5BB)
                                                        : const Color(
                                                            0xFF101010),
                                                    size: 16,
                                                  )),
                                            ],
                                          )),
                                    ],
                                  ),
                            const SizedBox(
                              height: 16,
                            ),
                            customButtonPrimary(
                                height: 50,
                                width: double.infinity,
                                alignment: Alignment.center,
                                onPressed: () async {
                                  print(isSelectTab1);
                                  if (isSelectTab1 == true) {
                                    await _api.loginwithEmail(
                                        emailcontroller.text,
                                        passwordcontroler.text);
                                    print('Status Code = ${_api.statusCode}');
                                    if (_api.statusCode == 200) {
                                      Notifsucces.showNotif(
                                          context: context,
                                          description: _api.message);

                                      Future.delayed(const Duration(seconds: 3),
                                          () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Landingpage(),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                      });
                                    } else {
                                      Notiferror.showNotif(
                                          context: context,
                                          description: _api.message);
                                    }
                                  } else {
                                    print('Token login');
                                    await _api
                                        .loginwithToken(tokencontroler.text);
                                    print('Status Code = ${_api.statusCode}');
                                    if (_api.statusCode == 200) {
                                      Notifsucces.showNotif(
                                          context: context,
                                          description: _api.message);

                                      Future.delayed(const Duration(seconds: 3),
                                          () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Landingpage(),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                      });
                                    } else {
                                      Notiferror.showNotif(
                                          context: context,
                                          description: _api.message);
                                    }
                                  }
                                },
                                child: const Text(
                                  'Mulai',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFFFFFFFF)),
                                )),
                            const SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: RichText(
                                  text: TextSpan(
                                      text: 'Belum memiliki akun? ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Color(0xFF101010)),
                                      children: <TextSpan>[
                                    TextSpan(
                                        text: 'Daftar akun',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF2E6CE9),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            print("Teken");
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Signupform()));
                                          })
                                  ])),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ]));
  }
}
