import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:salescheck/Model/RekeningModel.dart';
import 'package:salescheck/Model/eWalletModel.dart';
import '../Model/UserData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Apirekening {
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

  Future<void> addRekening(
      {required String name,
      required String namabank,
      required String nomerRekening}) async {
    final uri = Uri.parse('$api/rekening');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };
    final Map<String, dynamic> requestData = {
      "namaPemilik": name,
      "namaBank": namabank,
      "nomerRekening": nomerRekening
    };

    final response =
        await http.post(uri, headers: headers, body: jsonEncode(requestData));

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Rekening berhasil diunggah (response 3)');
      statusCode = response.statusCode;
    } else {
      print('Gagal mengunggah gambar produk');
      statusCode = response.statusCode;
    }
  }

  Future<List<Rekeningmodel>> getRekening() async {
    final uri = Uri.parse('$api/rekening');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      final List<dynamic> jsonData = result['data'];
      print('Rekening berhasil diambil (response 3)');
      final List<Rekeningmodel> rekening = jsonData
          .map((item) => Rekeningmodel.fromJson(item as Map<String, dynamic>))
          .toList();
      print(rekening.length);
      statusCode = response.statusCode;
      return rekening;
    } else {
      print('Gagal mengambil data Ewallet');
      statusCode = response.statusCode;
      return [];
    }
  }

  Future<void> deleteRekening(int id) async {
    final uri = Uri.parse('$api/rekening/$id');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      statusCode = response.statusCode;
    } else {
      print('Gagal mengambil data Rekening');
      final result = jsonDecode(response.body);
      statusCode = response.statusCode;
      message = result['message'];
    }
  }

  Future<void> editRekening(
      {required int id,
      required String name,
      required String namabank,
      required String nomerRekening}) async {
    final uri = Uri.parse('$api/rekening/$id');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };
    final Map<String, dynamic> requestData = {
      "namaPemilik": name,
      "namaBank": namabank,
      "nomerRekening": nomerRekening
    };

    final response =
        await http.put(uri, headers: headers, body: jsonEncode(requestData));

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Rekening berhasil merubah rekening (response 3)');
      statusCode = response.statusCode;
    } else {
      print('Gagal mengubah rekening produk');
      statusCode = response.statusCode;
    }
  }
}
