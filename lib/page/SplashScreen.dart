import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:http/http.dart';

import 'package:salescheck/Model/UserData.dart';
import 'package:salescheck/Model/outlets.dart';
import 'package:salescheck/Service/ApiOutlet.dart';
import 'package:salescheck/page/boardingPage.dart';
import 'package:salescheck/page/landingPage/landingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  UserData? userData;
  final Apioutlet _apioutlet = new Apioutlet();
  Future<void> getalloutletreturnoutlet() async {
    final prefs = await SharedPreferences.getInstance();
    List<Outlets> outletOption = await _apioutlet.getAllOutletApi();
    print(outletOption.first.namaOutlet);

    await prefs.setInt('id_outlet', outletOption.first.idOutlet ?? 0);
  }

  Future<void> _readAndPrintUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil data yang disimpan sebagai JSON string
    final data = prefs.getString('userData');

    if (data != null) {
      // Decode JSON string ke Map<String, dynamic>
      final jsonData = jsonDecode(data) as Map<String, dynamic>;

      // Parse JSON ke model UserData
      userData = UserData.fromJson(jsonData);

      // Cetak informasi user
      print('Token: ${userData?.token}');
      print('User Name: ${userData?.user.name}');
      print('User Email: ${userData?.user.email}');
      print('User Role: ${userData?.user.role}');
    } else {
      print('No data found');
    }
  }

  Future<void> _initializeSplashscreen() async {
    await _readAndPrintUserData();
    final response = await _apioutlet.getAllOutletApi();
    // int? idOutlab = response.first.idOutlet ?? 0;

    print(_apioutlet.statusCode);
    if (_apioutlet.statusCode != 401 && userData != null) {
      // Jika token ditemukan, masuk ke Homepage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => Landingpage(
                  boolpermis:
                      response.first.syaratKetentuan == 0 ? true : false,
                )),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Boardingpage()),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeSplashscreen();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF181818),
        resizeToAvoidBottomInset: true,
        body: Stack(clipBehavior: Clip.none, children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.zero,
            child: SvgPicture.asset(
              'asset/background/Splashscreen.svg',
              fit: BoxFit.fitWidth,
            ),
          ),
        ]));
  }
}
