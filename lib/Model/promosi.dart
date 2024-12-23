class Promosi {
  int? idPromosi;
  String? namaPromosi;
  String? deskripsiPromosi;
  String? tipeAktivasi;
  int? minimalBeli;
  String? kategoriPromosi;
  int? nilaiKategori;
  String? status;
  String? bonus;
  String? durasi;
  List<DetailOutlet>? detailOutlet;
  String? jamMulai;
  String? jamBerakhir;
  List<String>? pilihanHari;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Promosi(
      {this.idPromosi,
      this.namaPromosi,
      this.deskripsiPromosi,
      this.tipeAktivasi,
      this.minimalBeli,
      this.kategoriPromosi,
      this.nilaiKategori,
      this.status,
      this.bonus,
      this.durasi,
      this.detailOutlet,
      this.jamMulai,
      this.jamBerakhir,
      this.pilihanHari,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Promosi.fromJson(Map<String, dynamic> json) {
    idPromosi = json['id_promosi'];
    namaPromosi = json['nama_promosi'];
    deskripsiPromosi = json['deskripsi_promosi'];
    tipeAktivasi = json['tipe_aktivasi'];
    minimalBeli = json['minimal_beli'];
    kategoriPromosi = json['kategori_promosi'];
    nilaiKategori = json['nilai_kategori'];
    status = json['status'];
    bonus = json['bonus'];
    durasi = json['durasi'];
    if (json['detailOutlet'] != null) {
      detailOutlet = <DetailOutlet>[];
      json['detailOutlet'].forEach((v) {
        detailOutlet!.add(new DetailOutlet.fromJson(v));
      });
    }
    jamMulai = json['jam_mulai'];
    jamBerakhir = json['jam_berakhir'];
    pilihanHari = json['pilihan_hari'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_promosi'] = this.idPromosi;
    data['nama_promosi'] = this.namaPromosi;
    data['deskripsi_promosi'] = this.deskripsiPromosi;
    data['tipe_aktivasi'] = this.tipeAktivasi;
    data['minimal_beli'] = this.minimalBeli;
    data['kategori_promosi'] = this.kategoriPromosi;
    data['nilai_kategori'] = this.nilaiKategori;
    data['status'] = this.status;
    data['bonus'] = this.bonus;
    data['durasi'] = this.durasi;
    if (this.detailOutlet != null) {
      data['detailOutlet'] = this.detailOutlet!.map((v) => v.toJson()).toList();
    }
    data['jam_mulai'] = this.jamMulai;
    data['jam_berakhir'] = this.jamBerakhir;
    data['pilihan_hari'] = this.pilihanHari;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    return data;
  }

  double hitungDiskon(double totalAmount) {
    // Pastikan minimalBeli terpenuhi
    if (minimalBeli != null && minimalBeli! <= totalAmount) {
      print(kategoriPromosi);

      // Jika kategori adalah 'Rp' maka diskon dalam bentuk nominal
      if (kategoriPromosi == 'Rp') {
        // Pastikan nilaiKategori adalah angka yang valid
        double diskon = nilaiKategori?.toDouble() ??
            0.0; // Convert to double for safe calculation
        print("Diskon Rp: $diskon");
        return diskon;
      } else if (kategoriPromosi == '%') {
        // Jika kategori adalah persen, hitung diskon persen
        double diskon = (nilaiKategori ?? 0) / 100 * totalAmount;
        print("Diskon %: $diskon");
        return diskon;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }
}

class DetailOutlet {
  int? id;
  String? nama;
  String? position;
  int? idPromosiOutlet;

  DetailOutlet({this.id, this.nama, this.position, this.idPromosiOutlet});

  DetailOutlet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    position = json['position'];
    idPromosiOutlet = json['id_promosi_outlet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama'] = this.nama;
    data['position'] = this.position;
    data['id_promosi_outlet'] = this.idPromosiOutlet;
    return data;
  }
}
