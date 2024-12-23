// ignore: file_names
class kasirModel {
  int? id;
  int? outletsId;
  int? usersId;
  int? uangModal;
  String? waktuBuka;
  String? waktuTutup;
  int? itemTerjual;
  int? totalKotor;
  int? totalBersih;
  String? updatedAt;
  String? createdAt;

  kasirModel(
      {this.id,
      this.outletsId,
      this.usersId,
      this.uangModal,
      this.waktuBuka,
      this.waktuTutup,
      this.itemTerjual,
      this.totalKotor,
      this.totalBersih,
      this.updatedAt,
      this.createdAt});

  kasirModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    outletsId = json['outletsId'];
    usersId = json['usersId'];
    uangModal = json['uangModal'];
    waktuBuka = json['waktuBuka'];
    waktuTutup = json['waktuTutup'];
    itemTerjual = json['itemTerjual'];
    totalKotor = json['totalKotor'];
    totalBersih = json['totalBersih'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['outletsId'] = this.outletsId;
    data['usersId'] = this.usersId;
    data['uangModal'] = this.uangModal;
    data['waktuBuka'] = this.waktuBuka;
    data['waktuTutup'] = this.waktuTutup;
    data['itemTerjual'] = this.itemTerjual;
    data['totalKotor'] = this.totalKotor;
    data['totalBersih'] = this.totalBersih;
    data['updatedAt'] = this.updatedAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
