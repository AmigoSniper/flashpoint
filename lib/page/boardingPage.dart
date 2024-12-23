import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salescheck/component/customButtonPrimary.dart';

import 'Login/loginform.dart';

class Boardingpage extends StatefulWidget {
  const Boardingpage({super.key});

  @override
  State<Boardingpage> createState() => _BoardingpageState();
}

class _BoardingpageState extends State<Boardingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
            left: false,
            right: false,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          alignment: Alignment.topCenter,
                          fit: BoxFit.fitWidth,
                          image:
                              AssetImage('asset/background/BgBoarding.png'))),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [SizedBox.shrink()],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 450,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 40, bottom: 36),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aplikasi Penjualan & Pelaporan Sahabat UMKM',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                color: Color(0xFF101010)),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text(
                            'Mulai perjalanan bisnis anda bersama Flashpoint',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xFF101010)),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          customButtonPrimary(
                              alignment: Alignment.center,
                              height: 50,
                              width: double.infinity,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Loginform()));
                              },
                              child: const Text(
                                'Mulai',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFFFFFFFF)),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}
