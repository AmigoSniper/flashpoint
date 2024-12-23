import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:salescheck/Model/Transaksi.dart';
import 'package:salescheck/Model/kasirModel.dart';
import 'package:salescheck/Model/promosi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/UserData.dart';
import '../Model/biayaTambahanModel.dart';
import '../Model/selectedProduct.dart';

class Apitransaksi {
  final api = Uri.parse(dotenv.env['API_URL']!);
  final apiImage = Uri.parse(dotenv.env['Image_URL']!);
  int? statusCode;
  String? message;
  UserData? userdata;
  kasirModel? kasir;
  int? idTransaksi;
  Future<UserData> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    // Parse JSON ke model UserData
    UserData userData = UserData.fromJson(jsonData);

    return userData;
  }

  Future<kasirModel> _getKasir() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('kasir');
    final jsonData = jsonDecode(data!);
    // Parse JSON ke model UserData
    print(jsonData);
    kasirModel kasirku = kasirModel.fromJson(jsonData);
    print('Kasir ID = ${kasirku.id}');
    return kasirku;
  }

  Future<void> addTransaksi(
      int idoutlet,
      String name,
      String tipeBayar,
      double subTotal,
      double total,
      double bayar,
      double kembalian,
      double totalPajak,
      double totalOperasional,
      List<SelectedProduct> selectedProducts,
      List<Promosi> selectPromosi,
      List<biayaTambahanModel> biaya) async {
    userdata = await _getToken();
    kasir = await _getKasir();

    final Map<String, dynamic> requestDataTransaksi = {
      "outlet_id": idoutlet,
      "kasir_id": kasir!.id,
      "user_id": userdata!.user.id,
      "tipe_order": "Langsung Bayar",
      "name": name,
      "catatan": "",
      "tipe_bayar": tipeBayar,
      "ket_bayar": "Sudah Bayar",
      "sub_total": subTotal,
      "total": total,
      "bayar": bayar,
      "kembalian": kembalian
    };

    final headers = {
      'Authorization': 'Bearer ${userdata!.token}',
      'Content-Type': 'application/json',
    };

    try {
      final url = Uri.parse('$api/transaksi');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestDataTransaksi),
      );

      final responseData = jsonDecode(response.body);

      // Periksa status code
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Success: ${responseData['message']}');
        print(responseData);
        int id = responseData['data']['id'];
        print('ID Transaksi = $id');
        for (var element in selectedProducts) {
          print(element.quantity);
          final Map<String, dynamic> requestDataDetailTransaksi = {
            "transaksi_id": id,
            "product_id": element.id,
            "stok": element.quantity
          };
          final url2 = Uri.parse('$api/transaksi/detail');
          final response2 = await http.post(
            url2,
            headers: headers,
            body: jsonEncode(requestDataDetailTransaksi),
          );

          final responseData2 = jsonDecode(response2.body);
          if (response2.statusCode == 200 || response2.statusCode == 201) {
            print('Berhasil ditambahkan product');
          } else {
            print('Failed: ${response2.statusCode}');
            print(responseData2);
          }
        }
        for (var element in selectPromosi) {
          print(element);
          final Map<String, dynamic> requestDetailDiskon = {
            "transaksi_id": id,
            "diskon_id": element.idPromosi,
            "harga": element.hitungDiskon(subTotal)
          };
          final url2 = Uri.parse('$api/transaksi/detail-diskon');
          final response2 = await http.post(
            url2,
            headers: headers,
            body: jsonEncode(requestDetailDiskon),
          );

          final responseData2 = jsonDecode(response2.body);
          if (response2.statusCode == 200 || response2.statusCode == 201) {
            print('Berhasil ditambahkan diskon');
          } else {
            print('Failed: ${response2.statusCode}');
            print(responseData2);
          }
        }

        final Map<String, dynamic> requestPajak = {
          "transaksi_id": id,
          "pajak_id": biaya.first.id,
          "harga": totalPajak
        };
        final url3 = Uri.parse('$api/transaksi/detail-pajak');
        final response3 = await http.post(
          url3,
          headers: headers,
          body: jsonEncode(requestPajak),
        );

        final responseData3 = jsonDecode(response3.body);
        if (response3.statusCode == 200 || response3.statusCode == 201) {
          print('Berhasil ditambahkan pajak');
        } else {
          print('Failed: ${response3.statusCode}');
          print(responseData3);
        }
        final Map<String, dynamic> requsetOperasional = {
          "transaksi_id": id,
          "pajak_id": biaya.last.id,
          "harga": totalOperasional
        };
        final url4 = Uri.parse('$api/transaksi/detail-pajak');
        final response4 = await http.post(
          url4,
          headers: headers,
          body: jsonEncode(requsetOperasional),
        );

        final responseData4 = jsonDecode(response3.body);
        if (response4.statusCode == 200 || response4.statusCode == 201) {
          print('Berhasil ditambahkan operasional');
        } else {
          print('Failed: ${response4.statusCode}');
          print(responseData4);
        }

        statusCode = response4.statusCode;
        idTransaksi = id;
      } else {
        print('Failed: ${response.statusCode}');
        message = response.body;
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> addBuktiTransaksi(File buktiTransaksi, int idTransaksi) async {
    userdata = await _getToken();
    final url5 = Uri.parse('$api/transaksi/upload-invoice');
    final request = http.MultipartRequest('POST', url5);
    request.headers['Authorization'] = 'Bearer ${userdata!.token}';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['transaksisId'] = idTransaksi.toString();
    request.files.add(await http.MultipartFile.fromPath(
      'imageInvoice',
      buktiTransaksi.path,
      contentType: MediaType('image', 'jpg'),
    ));
    final response5 = await request.send(); // Cek status response
    if (response5.statusCode == 200 || response5.statusCode == 201) {
      print('Upload berhasil');
      final responseBody = await response5.stream.bytesToString();
      print('Response: $responseBody');
      statusCode = response5.statusCode;
      message = responseBody;
    } else {
      print('Upload gagal. Status code: ${response5.statusCode}');
      final responseBody = await response5.stream.bytesToString();
      print('Error Response: $responseBody');
    }
  }

  Future<List<Transaksi>> getTransaksi(int IdOutlet) async {
    userdata = await _getToken();
    // Mendapatkan tahun saat ini atau tahun tertentu
    int year = DateTime.now()
        .year; // Atau ganti dengan tahun yang kamu inginkan (misal: 2024)

    // Membuat startDate dan endDate berdasarkan tahun
    DateTime startDate = DateTime(year, 1, 1); // 1 Januari
    DateTime endDate = DateTime(year, 12, 31); // 31 Desember

    // Mengubah DateTime menjadi string dalam format yang diinginkan (misal: "yyyy-MM-dd")
    String startDateString =
        startDate.toIso8601String().split('T')[0]; // "2024-01-01"
    String endDateString =
        endDate.toIso8601String().split('T')[0]; // "2024-12-31"

    // Menyiapkan URL dengan startDate dan endDate
    final url = Uri.parse(
        '$api/penjualan?id_outlet=$IdOutlet&start_date=$startDateString&end_date=$endDateString');
    //Header
    final headers = {
      'Authorization': 'Bearer ${userdata!.token}',
      'Content-Type': 'application/json',
    };
    // Mengambil data sesuai dengan URL
    final response = await http.get(url, headers: headers);

    // Menangani response dari API
    if (response.statusCode == 200) {
      // Proses data response di sini
      print('Data berhasil diambil');
      final transakiData = jsonDecode(response.body);

      final List<dynamic> jsonData = transakiData['data'];
      final List<Transaksi> transaksi = jsonData
          .map((item) => Transaksi.fromJson(item as Map<String, dynamic>))
          .toList();
      print(transaksi.length);
      print(transaksi.last.transaksiName);
      statusCode = response.statusCode;
      return transaksi;
    } else {
      print('Gagal mengambil data: ${response.statusCode}');
      message = response.body;
      return [];
    }
  }

  Future<List<Transaksi>> getTransaksibyMonth(
      int IdOutlet, int indexBulan) async {
    userdata = await _getToken();
    // Mendapatkan tahun saat ini atau tahun tertentu
    int year = DateTime.now()
        .year; // Atau ganti dengan tahun yang kamu inginkan (misal: 2024)

    // Membuat startDate dan endDate berdasarkan tahun
    DateTime startDate = DateTime(year, indexBulan + 1, 1); // 1 Januari
    DateTime endDate = DateTime(year, indexBulan + 1, 31); // 31 Desember

    // Mengubah DateTime menjadi string dalam format yang diinginkan (misal: "yyyy-MM-dd")
    String startDateString =
        startDate.toIso8601String().split('T')[0]; // "2024-01-01"
    String endDateString =
        endDate.toIso8601String().split('T')[0]; // "2024-12-31"

    // Menyiapkan URL dengan startDate dan endDate
    final url = Uri.parse(
        '$api/penjualan?id_outlet=$IdOutlet&start_date=$startDateString&end_date=$endDateString');
    //Header
    final headers = {
      'Authorization': 'Bearer ${userdata!.token}',
      'Content-Type': 'application/json',
    };
    // Mengambil data sesuai dengan URL
    final response = await http.get(url, headers: headers);

    // Menangani response dari API
    if (response.statusCode == 200) {
      // Proses data response di sini
      print('Data berhasil diambil');
      final transakiData = jsonDecode(response.body);

      final List<dynamic> jsonData = transakiData['data'];
      if (jsonData.isNotEmpty) {
        final List<Transaksi> transaksi = jsonData
            .map((item) => Transaksi.fromJson(item as Map<String, dynamic>))
            .toList();
        print(transaksi.length);
        print(transaksi.last.transaksiName);
        statusCode = response.statusCode;
        return transaksi;
      } else {
        return [];
      }
    } else {
      print('Gagal mengambil data: ${response.statusCode}');
      message = response.body;
      return [];
    }
  }

  Future<String> getTransaksiStruck(int idTransaksi) async {
    userdata = await _getToken();

    // Menyiapkan URL dengan startDate dan endDate
    final url = Uri.parse('$api/transaksi/view-struk/$idTransaksi');
    //Header
    final headers = {
      'Authorization': 'Bearer ${userdata!.token}',
      'Content-Type': 'application/json',
    };
    // Mengambil data sesuai dengan URL
    final response = await http.get(url, headers: headers);

    // Menangani response dari API
    if (response.statusCode == 200) {
      // Proses data response di sini
      print('Data berhasil diambil');
      // final transakiData = jsonDecode(response.body);
      print('$api/transaksi/view-struk/$idTransaksi');
      return '$api/transaksi/view-struk/$idTransaksi';
    } else {
      print('Gagal mengambil data: ${response.statusCode}');
      print(response.body);
      message = response.body;
      return '''''';
    }
  }

  Future<String> getbuktiTransaksi(int idTransaksi) async {
    userdata = await _getToken();

    // Menyiapkan URL dengan startDate dan endDate
    final url = Uri.parse('$api/transaksi/upload-invoice/$idTransaksi');
    //Header
    final headers = {
      'Authorization': 'Bearer ${userdata!.token}',
      'Content-Type': 'application/json',
    };
    // Mengambil data sesuai dengan URL
    final response = await http.get(url, headers: headers);
    final result = jsonDecode(response.body);
    // Menangani response dari API
    if (response.statusCode == 200) {
      // Proses data response di sini
      print('Data berhasil diambil');
      // final transakiData = jsonDecode(response.body);
      print(result['uploadInvoice']['imageInvoice']);
      String apiImageResult = result['uploadInvoice']['imageInvoice'];
      return '$apiImage/$apiImageResult';
    } else {
      print('Gagal mengambil data: ${response.statusCode}');
      print(response.body);
      message = response.body;
      return '''''';
    }
  }
}
