class Outlets {
  int? idOutlet;
  String? namaOutlet;
  String? alamat;
  String? posisi;
  String? image;
  int? syaratKetentuan;
  int? koordinator;
  int? idUser;
  String? nameUser;
  String? roleUser;

  Outlets(
      {this.idOutlet,
      this.namaOutlet,
      this.alamat,
      this.posisi,
      this.image,
      this.syaratKetentuan,
      this.koordinator,
      this.idUser,
      this.nameUser,
      this.roleUser});

  Outlets.fromJson(Map<String, dynamic> json) {
    idOutlet = json['id_outlet'];
    namaOutlet = json['nama_outlet'];
    alamat = json['alamat'];
    posisi = json['posisi'];
    image = json['image'];
    syaratKetentuan = json['syarat_ketentuan'];
    koordinator = json['koordinator'];
    idUser = json['id_user'];
    nameUser = json['name_user'];
    roleUser = json['role_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_outlet'] = this.idOutlet;
    data['nama_outlet'] = this.namaOutlet;
    data['alamat'] = this.alamat;
    data['posisi'] = this.posisi;
    data['image'] = this.image;
    data['syarat_ketentuan'] = this.syaratKetentuan;
    data['koordinator'] = this.koordinator;
    data['id_user'] = this.idUser;
    data['name_user'] = this.nameUser;
    data['role_user'] = this.roleUser;
    return data;
  }
}
