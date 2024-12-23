import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:salescheck/Model/outlets.dart';
import 'package:salescheck/Model/promosi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/UserData.dart';

class Apipromosi {
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

  Future<void> addPromosiApi({
    required String nama,
    required String description,
    required String tipeAktivasi,
    required int minimalBeli,
    required String kategori,
    required int nilaikategori,
    required String tanggalMulai,
    required String tanggalBerakhir,
    required String jamMulai,
    required String jamBerakhir,
    required List<String> hari,
    required List<Outlets> idOutlet,
  }) async {
    // Langkah 1: Membuat URL untuk POST endpoint /products
    final uri = Uri.parse('$api/promosi');
    DateTime tanggalMulaiParse =
        DateFormat('dd MMM yyyy', 'id').parse(tanggalMulai);
    DateTime tanggalBerakhirParse =
        DateFormat('dd MMM yyyy', 'id').parse(tanggalBerakhir);
    String tanggalMulaiformattedDate =
        DateFormat('yyyy-MM-d').format(tanggalMulaiParse);
    String tanggalBerakhirformattedDate =
        DateFormat('yyyy-MM-d').format(tanggalBerakhirParse);
    // Langkah 2: Ambil token pengguna dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    if (data == null) {
      throw Exception("User data not found in SharedPreferences.");
    }
    final jsonData = jsonDecode(data) as Map<String, dynamic>;
    UserData userData = UserData.fromJson(jsonData);

    // Langkah 3: Siapkan header untuk permintaan API
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };
    print(hari.join(','));
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields['namaPromosi'] = nama;
    request.fields['deskripsi'] = description;
    request.fields['tipeAktivasi'] = tipeAktivasi;
    request.fields['minimalBeli'] = minimalBeli.toString();
    request.fields['kategori'] = kategori;
    request.fields['nilaiKategori'] = nilaikategori.toString();
    request.fields['tanggalMulai'] = tanggalMulaiformattedDate;
    request.fields['tanggalBerakhir'] = tanggalBerakhirformattedDate;
    request.fields['jamMulai'] = jamMulai;
    request.fields['jamBerakhir'] = jamBerakhir;
    request.fields['pilihHari'] = hari.join(',');
    final response = await request.send();

    if (response.statusCode == 201) {
      print("Promosi berhasil ditambahkan");
      final responseBody = await response.stream.bytesToString();
      print(responseBody);
      final uri2 = Uri.parse('$api/promosi/outlets');
      statusCode = response.statusCode;
      final responseData = jsonDecode(responseBody);
      int id = responseData['id'];
      for (var element in idOutlet) {
        final Map<String, dynamic> requestData = {
          "promosisId": id,
          "outletsId": element.idOutlet
        };

        final response2 = await http.post(
          uri2,
          headers: headers,
          body: jsonEncode(requestData),
        );
        if (response2.statusCode == 200 || response2.statusCode == 201) {
          print(
              'Berhasil masukan outlet (${response2.statusCode}) = ${response2.body}');
          statusCode = response2.statusCode;
        } else {
          print(
              'Berhasil masukan outlet (${response2.statusCode}) = ${response2.body}');
        }
      }
    } else {
      print("Gagal menambahkan promosi. Status code: ${response.statusCode}");
      final responseBody = await response.stream.bytesToString();

      print("Gagal menambahkan promosi. Status code: ${response.statusCode}");
      print("Response Body: $responseBody");
      message = response.stream.bytesToString() as String?;
    }
  }

  Future<List<Promosi>> getPromosi() async {
    final uri = Uri.parse('$api/promosi?status=all');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final productData = jsonDecode(response.body);
      print(productData);
      final List<dynamic> jsonData = productData['data'];
      final List<Promosi> product = jsonData
          .map((item) => Promosi.fromJson(item as Map<String, dynamic>))
          .toList();
      print(product.length);
      statusCode = response.statusCode;
      return product;
    } else {
      print(response.statusCode);
      print(response.body);
      return [];
    }
  }

  Future<List<Promosi>> getPromosiAktif(int outletID) async {
    final uri = Uri.parse('$api/promosi?status=aktif');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final productData = jsonDecode(response.body);
      print(productData);
      final List<dynamic> jsonData = productData['data'];
      final List<Promosi> promosi = jsonData
          .map((item) => Promosi.fromJson(item as Map<String, dynamic>))
          .toList();
      List<Promosi> filteredPromosi = promosi;
      filteredPromosi = filteredPromosi.where((promosi) {
        return promosi.detailOutlet?.any((detail) => detail.id == outletID) ??
            false;
      }).toList();
      // Filter by duration using the current date
      filteredPromosi = filteredPromosi.where((promosi) {
        // Use DateFormat to parse the custom date format
        DateFormat dateFormat = DateFormat(
            "dd MMM yyyy"); // Update the format as per your date format
        DateTime promosiStartDate =
            dateFormat.parse(promosi.durasi?.split(" - ")[0] ?? "");
        DateTime promosiEndDate =
            dateFormat.parse(promosi.durasi?.split(" - ")[1] ?? "");
        DateTime now = DateTime.now();
        return now.isAfter(promosiStartDate) && now.isBefore(promosiEndDate);
      }).toList();
      // Filter by day
      filteredPromosi = filteredPromosi.where((promosi) {
        // Get current day of the week (1=Monday, 7=Sunday)
        int currentDayOfWeek = DateTime.now().weekday;

        // Map day of the week to the corresponding day name in bahasa
        Map<int, String> dayNames = {
          1: "Senin",
          2: "Selasa",
          3: "Rabu",
          4: "Kamis",
          5: "Jumat",
          6: "Sabtu",
          7: "Minggu",
        };

        String currentDayName = dayNames[currentDayOfWeek] ?? "";

        // Ensure the promotion's day is in the pilihanHari list
        return promosi.pilihanHari?.contains(currentDayName) ?? false;
      }).toList();

      // Filter by start and end time (jamMulai and jamBerakhir)
      filteredPromosi = filteredPromosi.where((promosi) {
        // Get the current time
        DateTime now = DateTime.now();

        // Ensure that jamMulai and jamBerakhir are in "HH:mm" format
        String jamMulai = promosi.jamMulai ?? "";
        String jamBerakhir = promosi.jamBerakhir ?? "";

        // Parse jamMulai and jamBerakhir to DateTime objects (current date with specific time)
        DateTime startTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(jamMulai.split(":")[0]),
            int.parse(jamMulai.split(":")[1]));
        DateTime endTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(jamBerakhir.split(":")[0]),
            int.parse(jamBerakhir.split(":")[1]));

        // Check if the current time is within the promotion time range
        return now.isAfter(startTime) && now.isBefore(endTime);
      }).toList();

      print('Jumlah promosi = ${promosi.length}');
      statusCode = response.statusCode;
      return filteredPromosi;
    } else {
      print(response.statusCode);
      print(response.body);
      return [];
    }
  }

  Future<void> updatePromosiApi(
      {required String nama,
      required String description,
      required String tipeAktivasi,
      required int minimalBeli,
      required String kategori,
      required int nilaikategori,
      required String tanggalMulai,
      required String tanggalBerakhir,
      required String jamMulai,
      required String jamBerakhir,
      required List<String> hari,
      required List<Outlets> idOutlet,
      required Promosi promosi}) async {
    // Langkah 1: Membuat URL untuk PUT endpoint /products
    final uri = Uri.parse('$api/promosi/${promosi.idPromosi}');
    DateTime tanggalMulaiParse =
        DateFormat('dd MMM yyyy', 'id').parse(tanggalMulai);
    DateTime tanggalBerakhirParse =
        DateFormat('dd MMM yyyy', 'id').parse(tanggalBerakhir);
    String tanggalMulaiformattedDate =
        DateFormat('yyyy-MM-d').format(tanggalMulaiParse);
    String tanggalBerakhirformattedDate =
        DateFormat('yyyy-MM-d').format(tanggalBerakhirParse);
    // Langkah 2: Ambil token pengguna dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    if (data == null) {
      throw Exception("User data not found in SharedPreferences.");
    }
    final jsonData = jsonDecode(data) as Map<String, dynamic>;
    UserData userData = UserData.fromJson(jsonData);

    // Langkah 3: Siapkan header untuk permintaan API
    final headers = {
      'Authorization': 'Bearer ${userData.token}', // Token pengguna
      'Content-Type': 'application/json', // Tipe konten untuk JSON
    };
    print(hari);
    final request = http.MultipartRequest('PUT', uri);
    request.headers.addAll(headers);
    request.fields['namaPromosi'] = nama;
    request.fields['deskripsi'] = description;
    request.fields['tipeAktivasi'] = tipeAktivasi;
    request.fields['minimalBeli'] = minimalBeli.toString();
    request.fields['kategori'] = kategori;
    request.fields['nilaiKategori'] = nilaikategori.toString();
    request.fields['tanggalMulai'] = tanggalMulaiformattedDate;
    request.fields['tanggalBerakhir'] = tanggalBerakhirformattedDate;
    request.fields['jamMulai'] = jamMulai;
    request.fields['jamBerakhir'] = jamBerakhir;
    request.fields['pilihHari'] = hari.join(',');
    final response = await request.send();
    print('Promosi diubah');
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Promosi berhasil diubah");
      final responseBody = await response.stream.bytesToString();
      print(responseBody);
      if (promosi.detailOutlet!.isNotEmpty) {
        for (var i = 0; i < promosi.detailOutlet!.length; i++) {
          final uri2 = Uri.parse(
              '$api/promosi/outlets/${promosi.detailOutlet![i].idPromosiOutlet}');

          ///api/promosi/outlets/{id}
          final response = await http.delete(uri2, headers: headers);

          if (response.statusCode == 200 || response.statusCode == 204) {
            print('Outlet telah dihapus');
            statusCode = response.statusCode;
          } else {
            print(response.statusCode);
            print(response.body);
          }
        }
      }

      final uri3 = Uri.parse('$api/promosi/outlets');
      statusCode = response.statusCode;
      print('Tambah outlet');
      for (var element in idOutlet) {
        final Map<String, dynamic> requestData = {
          "promosisId": promosi.idPromosi,
          "outletsId": element.idOutlet
        };

        final response2 = await http.post(
          uri3,
          headers: headers,
          body: jsonEncode(requestData),
        );
        if (response2.statusCode == 200 || response2.statusCode == 201) {
          print(
              'Berhasil masukan outlet (${response2.statusCode}) = ${response2.body}');
          statusCode = response2.statusCode;
        } else {
          print(
              'Berhasil masukan outlet (${response2.statusCode}) = ${response2.body}');
        }
      }
    } else {
      print("Gagal menambahkan promosi. Status code: ${response.statusCode}");
      final responseBody = await response.stream.bytesToString();

      print("Gagal menambahkan promosi. Status code: ${response.statusCode}");
      print("Response Body: $responseBody");
      message = response.stream.bytesToString() as String?;
    }
  }

  Future<void> deletePromosi(int id) async {
    final uri = Uri.parse('$api/promosi/$id');
    UserData userData = await _getToken();
    final headers = {
      'Authorization': 'Bearer ${userData.token}',
      'Content-Type': 'application/json',
    };
    final response = await http.delete(uri, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 204) {
      statusCode = response.statusCode;
    } else {
      print(response.statusCode);
      print(response.body);
    }
  }
}
