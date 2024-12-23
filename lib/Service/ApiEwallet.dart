import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:salescheck/Model/eWalletModel.dart';
import '../Model/UserData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Apiewallet {
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

  Future<void> addEwallet({required String name, File? image}) async {
    final uri = Uri.parse('$api/ewallet');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields['namaEwallet'] = name;
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image!.path,
      contentType: MediaType('image', 'jpg'),
    ));

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Ewallet berhasil diunggah (response 3)');
      statusCode = response.statusCode;
    } else {
      print('Gagal mengunggah gambar produk');
      statusCode = response.statusCode;
    }
  }

  Future<List<Ewalletmodel>> getEwallet() async {
    final uri = Uri.parse('$api/ewallet');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      final List<dynamic> jsonData = result['ewallets'];
      print('Ewallet berhasil diambil (response 3)');
      final List<Ewalletmodel> ewallet = jsonData
          .map((item) => Ewalletmodel.fromJson(item as Map<String, dynamic>))
          .toList();
      print(ewallet.length);
      statusCode = response.statusCode;
      return ewallet;
    } else {
      print('Gagal mengambil data Ewallet');
      statusCode = response.statusCode;
      print(statusCode);
      return [];
    }
  }

  Future<void> deleteEwallet(int id) async {
    final uri = Uri.parse('$api/ewallet/$id');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      statusCode = response.statusCode;
    } else {
      print('Gagal mengambil data Ewallet');
      final result = jsonDecode(response.body);
      statusCode = response.statusCode;
      message = result['message'];
    }
  }

  Future<void> editEwallet(
      {required int id, required String name, File? image}) async {
    final uri = Uri.parse('$api/ewallet/$id');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };
    final request = http.MultipartRequest('PUT', uri);
    request.headers.addAll(headers);
    request.fields['namaEwallet'] = name;
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpg'),
      ));
    }

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Ewallet berhasil diubah (response 3)');
      statusCode = response.statusCode;
    } else {
      print('Gagal mengubah ewaalet produk');
      statusCode = response.statusCode;
    }
  }

  String getImage(String? imageUrl) {
    return '$image/$imageUrl';
  }
}
