import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salescheck/component/notifError.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Model/UserData.dart';
import '../Model/outlets.dart';

class Apioutlet {
  final api = Uri.parse(dotenv.env['API_URL']!);
  final image = Uri.parse(dotenv.env['Image_URL']!);
  int? statusCode;
  String? message;
  Future<void> addOutletApi({
    required String nama,
    required String alamat,
    int? KoordinatorId,
    File? image,
    required bool syaratKetentuan,
  }) async {
    final uri = Uri.parse('$api/outlets');
    final request = http.MultipartRequest('POST', uri);
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    // Parse JSON ke model UserData
    UserData userData = UserData.fromJson(jsonData);
    // Tambahkan header Authorization dengan Bearer Token
    request.headers['Authorization'] = 'Bearer ${userData.token}';
    request.headers['Content-Type'] = 'multipart/form-data';

    // Tambahkan field teks
    request.fields['nama'] = nama;
    request.fields['alamat'] = alamat;
    request.fields['position'] = 'Toko Utama';
    request.fields['syaratKetentuan'] = syaratKetentuan.toString();
    print('image in api = ${image!.path}');
    // Tambahkan file
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', 'jpg'),
    ));

    // Kirim request
    final response = await request.send();

    // Cek status response
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Upload berhasil');
      final responseBody = await response.stream.bytesToString();
      if (KoordinatorId != null) {
        final requestdata = await jsonDecode(responseBody);
        final int? idOutlet = requestdata['outlet']['id'];
        print(idOutlet);
        final uri2 = Uri.parse('$api/outlets/$idOutlet/koordinator');
        final headers2 = {
          'Authorization': 'Bearer ${userData.token}', // Token pengguna
          'Content-Type': 'application/json', // Tipe konten untuk JSON
        };

        final Map<String, dynamic> requestData2 = {
          "koordinatorId": KoordinatorId
        };
        final response2 = await http.put(uri2,
            headers: headers2, body: jsonEncode(requestData2));

        if (response2.statusCode == 200 || response2.statusCode == 201) {
          print('Berhasil menaruh koordinator');
          print(response2.body);
        } else {
          print('Gagal Menaruh koordinator');
          print(response2.statusCode);
          print(response2.body);
        }
      }
      print('Response: $responseBody');
    } else {
      print('Upload gagal. Status code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('Error Response: $responseBody');
    }
  }

  Future<List<Outlets>> getAllOutletApi() async {
    final uri = Uri.parse('$api/outlets');

    try {
      // Ambil data user dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('userData');

      if (data == null) {
        print('No user data found in SharedPreferences.');
        return [];
      }

      final jsonData = jsonDecode(data) as Map<String, dynamic>;
      UserData userData = UserData.fromJson(jsonData);

      // Set headers
      final headers = {
        'Authorization': 'Bearer ${userData.token}',
        'Content-Type': 'application/json',
      };

      // Kirim request GET ke API
      final response = await http.get(uri, headers: headers);

      // Validasi response
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body); // Decode response body
        print('Outlets Data: $result');

        // Ambil daftar data dari response
        final List<dynamic> jsonData = result['data'];

        // Konversi setiap elemen menjadi model Outlets
        final List<Outlets> outlets = jsonData
            .map((item) => Outlets.fromJson(item as Map<String, dynamic>))
            .toList();

        // Simpan seluruh daftar ke SharedPreferences dalam bentuk JSON string
        final outletsJson = outlets.map((outlet) => outlet.toJson()).toList();
        await prefs.setString('outlets', jsonEncode(outletsJson));

        print('Outlets successfully fetched and saved!');
        statusCode = response.statusCode;
        return outlets; // Return daftar Outlets
      } else {
        print(
            'Failed to fetch outlets: ${response.statusCode} - ${response.reasonPhrase}');
        statusCode = response.statusCode;
        final result2 = jsonDecode(response.body);
        message = result2['message'];
        return [];
      }
    } catch (e) {
      statusCode = 401;
      print('Error fetching outlets: $e');
      return [];
    }
  }

  Future<void> editOutletApi({
    required int id,
    required String nama,
    required String alamat,
    int? KoordinatorId,
    File? image,
  }) async {
    final uri = Uri.parse('$api/outlets/$id');
    final request = http.MultipartRequest('PUT', uri);
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    // Parse JSON ke model UserData
    UserData userData = UserData.fromJson(jsonData);
    // Tambahkan header Authorization dengan Bearer Token
    request.headers['Authorization'] = 'Bearer ${userData.token}';
    request.headers['Content-Type'] = 'multipart/form-data';

    // Tambahkan field teks
    request.fields['nama'] = nama;
    request.fields['alamat'] = alamat;
    // request.fields['position'] = 'Toko Utama';
    request.fields['syaratKetentuan'] = true.toString();

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
      if (KoordinatorId != null) {
        final requestdata = await jsonDecode(responseBody);

        final uri2 = Uri.parse('$api/outlets/$id/koordinator');
        final headers2 = {
          'Authorization': 'Bearer ${userData.token}', // Token pengguna
          'Content-Type': 'application/json', // Tipe konten untuk JSON
        };

        final Map<String, dynamic> requestData2 = {
          "koordinatorId": KoordinatorId
        };
        final response2 = await http.put(uri2,
            headers: headers2, body: jsonEncode(requestData2));

        if (response2.statusCode == 200 || response2.statusCode == 201) {
          print('Berhasil menaruh koordinator');
          print(response2.body);
          statusCode = response2.statusCode;
        } else {
          print('Gagal Menaruh koordinator');
          print(response2.statusCode);
          print(response2.body);
          message = response2.body;
        }
      }
      print('Response: $responseBody');
    } else {
      print('Upload gagal. Status code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      message = responseBody;
      print('Error Response: $responseBody');
    }
  }

  String getImage(String? imageUrl) {
    return '$image/$imageUrl';
  }
}
