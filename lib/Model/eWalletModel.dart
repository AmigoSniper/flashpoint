class Ewalletmodel {
  int? id;
  String? namaEwallet;
  String? image;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Ewalletmodel(
      {this.id,
      this.namaEwallet,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Ewalletmodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaEwallet = json['namaEwallet'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['namaEwallet'] = this.namaEwallet;
    data['image'] = this.image;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    return data;
  }
}
