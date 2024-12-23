import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salescheck/page/Login/loginform.dart';
import 'package:salescheck/page/landingPage/landingPage.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.only(top: 56),
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            image:
                DecorationImage(image: Svg('asset/background/Bgsplash.svg'))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RichText(
                text: TextSpan(
              text: 'sales',
              style: GoogleFonts.montserrat(
                  fontSize: 22,
                  color: const Color(0xFF101010),
                  fontWeight: FontWeight.w700),
              children: <TextSpan>[
                TextSpan(
                    text: 'check.',
                    style: GoogleFonts.montserrat(
                        fontSize: 22,
                        color: const Color(0xFF2E6CE9),
                        fontWeight: FontWeight.w700))
              ],
            )),
            Container(
              padding: const EdgeInsets.only(top: 60),
              child: const Image(image: Svg('asset/image/Layer 2.svg')),
            ),
            Container(
              width: double.infinity,
              // color: Colors.amber,
              padding: const EdgeInsets.only(
                  top: 32, bottom: 52, left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih akun anda',
                    style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        color: const Color(0xFF101010)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Masukkan nomor telepon dan password untuk login',
                      style: GoogleFonts.openSans(
                          fontSize: 12, color: const Color(0xFF101010)),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Loginform()));
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          backgroundColor: const Color(0xFF2E6CE9),
                          minimumSize: const Size(double.infinity, 50)),
                      child: Text(
                        'Masuk sebagai klien',
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF)),
                      )),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Landingpage()));
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          backgroundColor: const Color(0xFFEEEEEE),
                          minimumSize: const Size(double.infinity, 50)),
                      child: Text(
                        'Masuk sebagai worker',
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF101010)),
                      )),
                  const SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: RichText(
                        text: TextSpan(
                            text: 'Anda sudah memiliki akun? ',
                            style: GoogleFonts.openSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: const Color(0xFF101010)),
                            children: <TextSpan>[
                          TextSpan(
                              text: 'Masuk',
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: const Color(0xFF2E6CE9),
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print("Teken");
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             const Register()));
                                })
                        ])),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
