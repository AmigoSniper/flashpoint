import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Model/UserData.dart';
import '../Model/category.dart';

class Apicategory {
  final api = Uri.parse(dotenv.env['API_URL']!);
  int? statusCode;
  String? message;
  Future<void> addCategory(
    String namaCategory,
    int idoutlet,
  ) async {
    final Map<String, dynamic> requestData = {
      "name": namaCategory,
    };
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    UserData userData = UserData.fromJson(jsonData);
    final headers = {
      'Authorization': 'Bearer ${userData.token}',
      'Content-Type': 'application/json',
    };

    try {
      final url = Uri.parse('$api/categories');
      print(requestData);

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );

      final responseData = jsonDecode(response.body);
      print(response.statusCode);
      // Periksa status code
      if (response.statusCode == 201) {
        print('Success: ${responseData['message']}');
        print(responseData);
        int id = responseData['id'];
        final Map<String, dynamic> requestData2 = {
          "categoriesId": id,
          "outletsId": idoutlet
        };
        final url2 = Uri.parse('$api/categories/outlets');
        final response2 = await http.post(
          url2,
          headers: headers,
          body: jsonEncode(requestData2),
        );

        final responseData2 = jsonDecode(response2.body);
        if (response2.statusCode == 200 || response2.statusCode == 201) {
          print('Berhasil ditambahkan kategori');
        } else {
          print('Failed: ${response.statusCode}');
          print(responseData2);
        }
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> editCategory(String namaCategory, int idcategory) async {
    final Map<String, dynamic> requestData = {
      "name": namaCategory,
    };
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    UserData userData = UserData.fromJson(jsonData);
    final headers = {
      'Authorization': 'Bearer ${userData.token}',
      'Content-Type': 'application/json',
    };

    try {
      final url = Uri.parse('$api/categories/$idcategory');
      print(requestData);

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );

      final responseData = jsonDecode(response.body);
      print(response.statusCode);
      // Periksa status code
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Success: ${responseData['message']}');
        print(responseData);
        statusCode = response.statusCode;
      } else {
        print('Failed: ${response.statusCode}');
        print('Failed: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<List<Category>> getCategory() async {
    final uri = Uri.parse('$api/categories');

    try {
      // Ambil data user dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('userData');
      final idoutlet = prefs.getInt('id_outlet');

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
      statusCode = response.statusCode;
      message = response.body;
      // Validasi response
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body); // Decode response body
        print('Category Data: $result');

        // Ambil daftar data dari response
        final List<dynamic> jsonData = result['data'];

        // Konversi setiap elemen menjadi model Outlets
        final List<Category> category = jsonData
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();

        // Simpan seluruh daftar ke SharedPreferences dalam bentuk JSON string

        print('Outlets successfully fetched and saved!');
        return category;
      } else {
        print(
            'Failed to fetch outlets: ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('Error fetching outlets: $e');
      return [];
    }
  }

  Future<void> deleteCategory(int idcategory) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    UserData userData = UserData.fromJson(jsonData);
    final headers = {
      'Authorization': 'Bearer ${userData.token}',
      'Content-Type': 'application/json',
    };

    try {
      final url = Uri.parse('$api/categories/$idcategory');

      final response = await http.delete(
        url,
        headers: headers,
      );

      final responseData = jsonDecode(response.body);
      print(response.statusCode);
      // Periksa status code
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Success: ${responseData['message']}');
        print(responseData);
        statusCode = response.statusCode;
      } else {
        print('Failed: ${response.statusCode}');
        print('Failed: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
