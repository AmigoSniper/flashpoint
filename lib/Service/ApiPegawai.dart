import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Model/User.dart';
import '../Model/UserData.dart';

class Apipegawai {
  final api = Uri.parse(dotenv.env['API_URL']!);
  final image = Uri.parse(dotenv.env['Image_URL']!);
  int? statusCode;
  String? message;
  UserData? userdata;
  Future<UserData> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    // Parse JSON ke model UserData
    UserData userData = UserData.fromJson(jsonData);
    return userData;
  }

  Future<void> addPegawaiApi({
    required String nama,
    required String email,
    required String password,
    required String role,
    required String status,
    File? image,
  }) async {
    final uri = Uri.parse('$api/users');
    final request = http.MultipartRequest('POST', uri);
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    // Parse JSON ke model UserData
    userdata = await _getToken();
    // Tambahkan header Authorization dengan Bearer Token
    request.headers['Authorization'] = 'Bearer ${userdata!.token}';
    request.headers['Content-Type'] = 'multipart/form-data';

    // Tambahkan field teks
    request.fields['name'] = nama;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['role'] = role;
    request.fields['status'] = status.toString();

    // Tambahkan file
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpg'),
      ));
    }

    // Kirim request
    final response = await request.send();

    // Cek status response
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Upload berhasil');
      final responseBody = await response.stream.bytesToString();
      print('Response: $responseBody');
      statusCode = response.statusCode;
      message = responseBody;
    } else {
      print('Upload gagal. Status code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('Error Response: $responseBody');
    }
  }

  Future<List<User>> getPegawaiApi() async {
    final uri = Uri.parse('$api/users');
    userdata = await _getToken();
    // Set headers
    final headers = {
      'Authorization': 'Bearer ${userdata?.token}',
      'Content-Type': 'application/json',
    };

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      statusCode = response.statusCode;
      final result = jsonDecode(response.body); // Decode response body
      print('Pegawai Data: $result');

      // Ambil daftar data dari response
      final List<dynamic> jsonData = result;

      // Konversi setiap elemen menjadi model Outlets
      final List<User> users = jsonData
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();

      print('Pegawai successfully fetched and saved!');
      return users; // Return daftar pegawai
    } else {
      print(
          'Failed to fetch outlets: ${response.statusCode} - ${response.reasonPhrase}');
      statusCode = response.statusCode;

      final message3 = jsonDecode(response.body);
      message = message3['message'];
      return [];
    }
  }

  Future<void> editPegawaiApi({
    required int id,
    required String nama,
    required String email,
    String? password,
    required String role,
    required String status,
    File? image,
  }) async {
    final uri = Uri.parse('$api/users/$id');
    final request = http.MultipartRequest('PUT', uri);

    // Parse JSON ke model UserData
    userdata = await _getToken();

    // Tambahkan header Authorization dengan Bearer Token
    request.headers['Authorization'] = 'Bearer ${userdata!.token}';
    request.headers['Content-Type'] = 'multipart/form-data';

    // Tambahkan field teks
    request.fields['name'] = nama;
    request.fields['email'] = email;
    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
    }

    request.fields['role'] = role;
    request.fields['status'] = status;

    // Tambahkan file
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpg'),
      ));
    }

    // Kirim request
    final response = await request.send();

    // Cek status response
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Edit berhasil');
      final responseBody = await response.stream.bytesToString();
      print('Response: $responseBody');
      statusCode = response.statusCode;
      message = responseBody;
    } else {
      print('Edit gagal. Status code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('Error Response: $responseBody');
    }
  }

  Future<void> quickeditPegawaitApi({
    required int idPegawai,
    required bool status,
  }) async {
    try {
      // Langkah 1: Buat URL untuk endpoint PUT /products/{id}
      String aktif = status ? 'Active' : 'Inactive';
      String stats = "?status=$aktif";
      // stock=5&status=Produk%20Tidak%20Aktif&unlimited_stock=true
      final uri = Uri.parse('$api/users/$idPegawai/status$stats');

      UserData userData = await _getToken();

      // Langkah 3: Siapkan header untuk permintaan API
      final headers = {
        'Authorization': 'Bearer ${userData.token}', // Token pengguna
        'Content-Type': 'multipart/form-data', // Tipe konten untuk JSON
      };

      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll(headers);
      final response = await request.send();

      // Langkah 6: Cek respons dari server
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Status Pegawai berhasil diperbarui (response 1)');
      } else {
        print(
            'Gagal memperbarui status pegawai. Status code: ${response.statusCode}');

        statusCode = response.statusCode;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> deletePegawaitApi({
    required int idPegawai,
  }) async {
    try {
      final uri = Uri.parse('$api/users/$idPegawai');

      UserData userData = await _getToken();

      // Langkah 3: Siapkan header untuk permintaan API
      final headers = {
        'Authorization': 'Bearer ${userData.token}', // Token pengguna
        'Content-Type': 'application/json', // Tipe konten untuk JSON
      };

      final request = await http.delete(uri, headers: headers);
      statusCode = request.statusCode;

      // Langkah 6: Cek respons dari server
      if (request.statusCode == 200 || request.statusCode == 201) {
        print('Pegawai berhasil dihapus (response 1)');
      } else {
        print('idPegawao = $idPegawai');
        print(
            'Gagal menghapus status pegawai. Status code: ${request.statusCode}');

        statusCode = request.statusCode;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  String getImage(String imageUrl) {
    print('$image/$imageUrl');
    return '$image/$imageUrl';
  }

  Future<String?> generateToken(int id) async {
    try {
      UserData userData = await _getToken();

      // Langkah 3: Siapkan header untuk permintaan API
      final headers = {
        'Authorization': 'Bearer ${userData.token}', // Token pengguna
        'Content-Type': 'multipart/form-data', // Tipe konten untuk JSON
      };
      final url = Uri.parse('$api/users/$id/generate-token');

      final response = await http.put(
        url,
        headers: headers,
      );

      final responseData = jsonDecode(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        print('Success: ${responseData['message']}');
        print(responseData);
        statusCode = response.statusCode;
        return responseData['data']['tokenLogin'];
      } else {
        print('Failed: ${response.statusCode}');
        print('Failed: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }
}
