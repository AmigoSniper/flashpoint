import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/UserData.dart';

class Apikasir {
  final api = Uri.parse(dotenv.env['API_URL']!);
  int? statusCode;
  String? message;
  Future<void> addKasir() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    final int idOutlet = prefs.getInt('id_outlet') ?? 0;
    final jsonData = jsonDecode(data!) as Map<String, dynamic>;
    UserData userData = UserData.fromJson(jsonData);
    final Map<String, dynamic> requestData = {
      "outletsId": idOutlet,
      "usersId": userData.user.id,
      "uangModal": 50000
    };
    final headers = {
      'Authorization': 'Bearer ${userData.token}',
      'Content-Type': 'application/json',
    };

    try {
      final url = Uri.parse('$api/kasir');
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

        // Ambil data dari response (hanya bagian 'data')
        final data = responseData['data'];

        // Simpan hanya bagian 'data' ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('kasir', jsonEncode(data));

        print("Kasir data saved to SharedPreferences: $data");
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
