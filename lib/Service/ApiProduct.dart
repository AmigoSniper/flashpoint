import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salescheck/Model/productCategory.dart';
import 'package:salescheck/Model/productOutlet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Model/UserData.dart';
import '../Model/outlets.dart';
import '../Model/product.dart';

class Apiproduct {
  final api = Uri.parse(dotenv.env['API_URL']!);
  final image = Uri.parse(dotenv.env['Image_URL']!);
  int? statusCode;
  String? message;
  Future<void> addProductApi({
    required String nama,
    required String description,
    required double price,
    required int idCategori,
    required int idOutlet,
    int? stock,
    required bool unlimitedStock,
    File? image,
  }) async {
    // Langkah 1: Membuat URL untuk POST endpoint /products
    final uri = Uri.parse('$api/products');

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

    // Langkah 4: Siapkan data request untuk membuat produk baru
    final Map<String, dynamic> requestData = {
      "name": nama,
      "description": description,
      "price": price,
      "stock": stock,
      "unlimited_stock": unlimitedStock
    };

    // Langkah 5: Kirim permintaan POST untuk membuat produk baru
    final response =
        await http.post(uri, headers: headers, body: jsonEncode(requestData));

    // Langkah 6: Cek respons dari server
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Produk berhasil dibuat (response 1)');

      // Ambil ID produk yang baru saja dibuat dari respons
      final responsedata = jsonDecode(response.body);
      int productId = responsedata['id'];

      // Langkah 7: Hubungkan produk dengan outlet
      final uri2 = Uri.parse('$api/products/outlets');
      final Map<String, dynamic> requestData2 = {
        "productsId": productId,
        "outletsId": idOutlet
      };
      final response2 = await http.post(uri2,
          headers: headers, body: jsonEncode(requestData2));

      if (response2.statusCode == 200 || response2.statusCode == 201) {
        print('Produk berhasil dikaitkan dengan outlet (response 2)');

        // Langkah 8: Upload gambar produk jika ada
        if (image != null) {
          final uri3 = Uri.parse('$api/products/productImage');
          final request = http.MultipartRequest('POST', uri3);
          request.headers.addAll(headers);
          request.fields['productsId'] = productId.toString();
          request.fields['categoriesId'] = idCategori.toString();
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            image.path,
            contentType: MediaType('image', 'jpg'),
          ));

          final response3 = await request.send();

          if (response3.statusCode == 200 || response3.statusCode == 201) {
            print('Gambar produk berhasil diunggah (response 3)');
          } else {
            print('Gagal mengunggah gambar produk');
            statusCode = response3.statusCode;
          }
        } // Langkah 9: Hubungkan produk dengan kategori
        final uri4 = Uri.parse('$api/product/categories');
        final Map<String, dynamic> requestData4 = {
          "productsId": productId,
          "categoriesId": idCategori,
        };
        final response4 = await http.post(uri4,
            headers: headers, body: jsonEncode(requestData4));

        if (response4.statusCode == 200 || response4.statusCode == 201) {
          print('Produk berhasil dikaitkan dengan kategori (response 4)');
          statusCode = response4.statusCode;
        } else {
          print('Gagal mengaitkan produk dengan kategori');
          statusCode = response4.statusCode;
        }
      } else {
        print('Gagal menghubungkan produk dengan outlet');
        statusCode = response2.statusCode;
      }
    } else {
      print('Gagal membuat produk. Status code: ${response.statusCode}');
      statusCode = response.statusCode;
    }
  }

  Future<void> editProductApi({
    required int productId,
    required String nama,
    required String description,
    required double price,
    required int idCategory,
    required int idRelasiCategory,
    required int idOutlet,
    int? stock,
    required bool unlimitedStock,
    File? image,
    int? idRelasiImage,
  }) async {
    try {
      // Langkah 1: Buat URL untuk endpoint PUT /products/{id}
      final uri = Uri.parse('$api/products/$productId');

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

      // Langkah 4: Siapkan data request untuk mengupdate produk
      final Map<String, dynamic> requestData = {
        "name": nama,
        "description": description,
        "price": price,
        "stock": stock,
        "unlimited_stock": unlimitedStock
      };

      // Langkah 5: Kirim permintaan PUT untuk mengupdate produk
      final response =
          await http.put(uri, headers: headers, body: jsonEncode(requestData));

      // Langkah 6: Cek respons dari server
      if (response.statusCode == 200 || response.statusCode == 201) {
        final uriImageProductID =
            Uri.parse('$api/products/productImage/$idRelasiImage');
        final responseImageProductID =
            await http.get(uriImageProductID, headers: headers);

        if (responseImageProductID.statusCode == 200 ||
            responseImageProductID.statusCode == 201) {
          final responsedata = jsonDecode(responseImageProductID.body);
          int imageProductID = responsedata['id'];
          if (image != null) {
            final uri3 =
                Uri.parse('$api/products/productImage/$imageProductID');
            final request = http.MultipartRequest('PUT', uri3);
            request.headers.addAll(headers);
            request.fields['product_id'] = productId.toString();
            request.files.add(await http.MultipartFile.fromPath(
              'image',
              image.path,
              contentType: MediaType('image', 'jpg'),
            ));

            final response3 = await request.send();

            if (response3.statusCode == 200 || response3.statusCode == 201) {
              print('Gambar produk berhasil diperbarui (response 3)');
            } else {
              print('Gagal memperbarui gambar produk');
              print('Status code = ${response3.statusCode}');
              final result3 = await response3.stream.bytesToString();
              final message3 = jsonDecode(result3);
              message = message3['message'];
            }
          }
        } else {
          print(responseImageProductID.statusCode);
          final resultImage = jsonDecode(responseImageProductID.body);
          message = resultImage['message'];
        }

        // Langkah 9: Perbarui hubungan produk dengan kategori
        final uri4 = Uri.parse('$api/product/categories/$idRelasiCategory');
        final Map<String, dynamic> requestData4 = {
          "productsId": productId,
          "categoriesId": idCategory,
        };
        final response4 = await http.put(uri4,
            headers: headers, body: jsonEncode(requestData4));

        if (response4.statusCode == 200 || response4.statusCode == 201) {
          print(
              'Produk berhasil dikaitkan dengan kategori yang baru (response 4)');
        } else {
          print('Gagal memperbarui hubungan produk dengan kategori');
          print(response4.body);
        }
      } else {
        print('Gagal memperbarui produk. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> quickeditProductApi({
    required int productId,
    required String nama,
    int? stock,
    required bool unlimitedStock,
    required bool status,
  }) async {
    try {
      // Langkah 1: Buat URL untuk endpoint PUT /products/{id}
      String aktif = status ? 'Produk%20Aktif' : 'Produk%20Tidak%20Aktif';
      String stats =
          "?stock=$stock&status=$aktif&unlimited_stock=${unlimitedStock.toString()}";
      // stock=5&status=Produk%20Tidak%20Aktif&unlimited_stock=true
      final uri = Uri.parse('$api/products/$productId/status$stats');
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
        'Content-Type': 'multipart/form-data', // Tipe konten untuk JSON
      };

      // Langkah 4: Siapkan data request untuk mengupdate produk
      final Map<String, dynamic> requestData = {
        "id": productId,
        "stock": unlimitedStock ? null : stock,
        "status": status ? 'Produk Aktif' : 'Produk Tidak Aktif',
        "unlimited_stock": unlimitedStock.toString()
      };

      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll(headers);
      request.fields['id'] = productId.toString();
      request.fields['stock'] = stock.toString();
      request.fields['status '] =
          status ? "Produk Aktif" : "Produk Tidak Aktif";
      request.fields['unlimited_stock  '] = unlimitedStock.toString();
      // Langkah 5: Kirim permintaan PUT untuk mengupdate produk
      print(request.fields);
      final response = await request.send();

      // Langkah 6: Cek respons dari server
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Produk berhasil diperbarui (response 1)');
      } else {
        print('Gagal memperbarui produk. Status code: ${response.statusCode}');

        statusCode = response.statusCode;
        final result3 = await response.stream.bytesToString();
        final message3 = jsonDecode(result3);
        message = message3['message'];
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<List<Product>> getProductsByOutletAndCategory({
    required int outletId,
    required int categoryId,
  }) async {
    final productUri = Uri.parse('$api/products');
    final outletUri = Uri.parse('$api/products/outlets/$outletId');
    final categoryUri = Uri.parse('$api/product/categories/$categoryId');

    try {
      // Ambil token dari SharedPreferences
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
      final productResponse = await http.get(productUri, headers: headers);
      if (productResponse.statusCode == 200 ||
          productResponse.statusCode == 201) {
        final productData = jsonDecode(productResponse.body);
        print(productData);
        final List<dynamic> jsonData = productData['data'];
        final List<Product> product = jsonData
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        print(product.length);
        statusCode = productResponse.statusCode;
        return product;
      }
      // Langkah 1: Ambil produk berdasarkan outlet
      final outletResponse = await http.get(outletUri, headers: headers);
      if (outletResponse.statusCode != 200 ||
          outletResponse.statusCode != 201) {
        print(
            'Failed to fetch products by outlet: ${outletResponse.statusCode} - ${outletResponse.reasonPhrase}');

        final message3 = jsonDecode(outletResponse.body);
        message = message3['message'];
        return [];
      }
      final outletResult = jsonDecode(outletResponse.body);
      print(outletResult);

      List<Productoutlet> productOutlet = [];
      productOutlet.add(Productoutlet.fromJson(outletResult['data']));

      // Langkah 2: Ambil produk berdasarkan kategori
      final categoryResponse = await http.get(categoryUri, headers: headers);
      if (categoryResponse.statusCode != 200) {
        print(
            'Failed to fetch products by category: ${categoryResponse.statusCode} - ${categoryResponse.reasonPhrase}');
        return [];
      }
      final categoryResult = jsonDecode(categoryResponse.body);
      print(categoryResult);
      final List<Productcategory> productCategory = [];
      productCategory.add(Productcategory.fromJson(categoryResult));

      // Langkah 3: Filter produk yang ada di kedua filter
      final filteredProducts = productOutlet.where((product) {
        return productCategory
            .any((catProduct) => catProduct.productId == product.productId);
      }).toList();

      // Konversi produk ke dalam model Product
      final products = filteredProducts.map((productJson) {
        return Product.fromJson(productJson as Map<String, dynamic>);
      }).toList();

      print('Products successfully fetched and filtered!');
      print(products.length);
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<void> deleteProduct(int productID) async {
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

    // Membuat URL untuk delete transaksi
    final url = Uri.parse(
        '$api/products/$productID'); // Endpoint untuk menghapus transaksi berdasarkan ID

    // Mengirimkan HTTP DELETE request
    final response = await http.delete(
      url,
      headers: headers,
    );

    // Debugging: Menampilkan respons body dan status code

    print('Status Code: ${response.statusCode}');

    // Mengecek apakah status code 200 atau 201 untuk sukses
    if (response.statusCode == 200 || response.statusCode == 204) {
      statusCode = response.statusCode;
      // Proses lainnya sesuai kebutuhan setelah delete berhasil
    } else {}
  }

  String getImage(String? imageUrl) {
    return '$image/$imageUrl';
  }

  Future<int> productHabis(int IdOutlet) async {
    final uri = Uri.parse('$api/products/stock-habis?outletId=$IdOutlet');
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('userData');

      if (data == null) {
        print('No user data found in SharedPreferences.');
        return 0;
      }

      final jsonData = jsonDecode(data) as Map<String, dynamic>;
      UserData userData = UserData.fromJson(jsonData);

      // Set headers
      final headers = {
        'Authorization': 'Bearer ${userData.token}',
        'Content-Type': 'application/json',
      };

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        statusCode = response.statusCode;
        return responseData['data']['stock_habis'];
      } else {}
    } catch (e) {
      print('Error : $e');
    }
    return 0;
  }
}
