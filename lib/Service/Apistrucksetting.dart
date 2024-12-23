import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:salescheck/Model/struckModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/UserData.dart';

class Apistrucksetting {
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

  Future<struckModel?> getStruckSetting() async {
    final uri = Uri.parse('$api/setting-struk');
    userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      print(response.body);
      struckModel struck = struckModel.fromJson(jsonDecode(response.body));
      print("tahap");
      print(struck.data?.struks?.first.status ?? 'No status available');
      return struck;
    } else {
      print('Error fetching data: ${response.statusCode}');
      return null;
    }
  }

  Future<void> editlogoStruckSetting(File image, int id) async {
    final uri = Uri.parse('$api/setting-struk/detail-struk-logo/$id');
    userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
      'Content-Type': 'application/json',
    };
    final request = http.MultipartRequest('PUT', uri);
    request.headers.addAll(headers);

    request.fields['struksId'] = '1';
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', 'jpg'),
    ));
    final response = await request.send();
    if (response.statusCode == 200) {
      print('Berhasil');
    } else {
      print('Error fetching data: ${response.statusCode}');
    }
  }

  Future<void> editstatusStruckSetting(int id, bool status) async {
    final uri =
        Uri.parse('$api/setting-struk/status/$id?status=${status.toString()}');
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

  Future<void> editdetailtextStruckSetting(
      int id, String text, int struckId) async {
    final uri = Uri.parse('$api/setting-struk/detail-struk-text/$id');
    final Map<String, dynamic> requestData = {
      "struksId": struckId,
      "text": text
    };
    userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
      'Content-Type': 'application/json',
    };

    final response =
        await http.put(uri, headers: headers, body: jsonEncode(requestData));
    if (response.statusCode == 200) {
      print('Berhasil');
    } else {
      print('Error fetching data: ${response.statusCode}');
    }
  }

  Future<void> editdetailmediaStruckSetting(
      int id, String text, int struckId, String kategori) async {
    String encodedString = text.replaceAll(' ', '%20');
    final uri = Uri.parse(
        '$api/setting-struk/detail-struk-media/$id?struksId=$struckId&kategori=$kategori&nameMedia=$encodedString');
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

  String getImage(String? imageUrl) {
    return '$image/$imageUrl';
  }
}
