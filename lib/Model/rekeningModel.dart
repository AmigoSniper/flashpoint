class Rekeningmodel {
  int? id;
  String? namaPemilik;
  String? namaBank;
  String? nomerRekening;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Rekeningmodel(
      {this.id,
      this.namaPemilik,
      this.namaBank,
      this.nomerRekening,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Rekeningmodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaPemilik = json['namaPemilik'];
    namaBank = json['namaBank'];
    nomerRekening = json['nomerRekening'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['namaPemilik'] = this.namaPemilik;
    data['namaBank'] = this.namaBank;
    data['nomerRekening'] = this.nomerRekening;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    return data;
  }
}
