import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:salescheck/Model/biayaTambahanModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/UserData.dart';

class Apibiayatambahan {
  final api = Uri.parse(dotenv.env['API_URL']!);
  final image = Uri.parse(dotenv.env['Image_URL']!);
  int? statusCode;
  String? message;
  UserData? userData;
  Future<UserData> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    // Parse JSON ke model UserData
    UserData userData = UserData.fromJson(jsonData);

    return userData;
  }

  Future<List<biayaTambahanModel>> getBiayaTambahan() async {
    final uri = Uri.parse('$api/pajaks');
    userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(response.body);
      final List<dynamic> jsonData = result['data'];
      List<biayaTambahanModel> biaya =
          jsonData.map((item) => biayaTambahanModel.fromJson(item)).toList();
      statusCode = response.statusCode;
      return biaya;
    } else {
      print('Error fetching data: ${response.statusCode}');
      return [];
    }
  }

  Future<void> editstatusbiayaTambahan(int id, bool status) async {
    final uri = Uri.parse('$api/pajaks/status/$id?status=${status.toString()}');
    userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
      'Content-Type': 'application/json',
    };

    final response = await http.put(uri, headers: headers);
    if (response.statusCode == 200) {
      print('Berhasil');
    } else {
      print('Error fetching data: ${response.statusCode}');
    }
  }

  Future<void> editnilaibiayaTambahan(int id, String nilai) async {
    final uri = Uri.parse('$api/pajaks/nilai-pajak/$id?nilaiPajak=${nilai}25');
    userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
      'Content-Type': 'application/json',
    };

    final response = await http.put(uri, headers: headers);
    if (response.statusCode == 200) {
      print('Berhasil');
    } else {
      print('Error fetching data: ${response.statusCode}');
    }
  }
}
