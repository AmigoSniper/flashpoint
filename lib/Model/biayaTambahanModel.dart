class biayaTambahanModel {
  int? id;
  String? name;
  String? nilaiPajak;
  bool? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  biayaTambahanModel(
      {this.id,
      this.name,
      this.nilaiPajak,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  biayaTambahanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nilaiPajak = json['nilaiPajak'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['nilaiPajak'] = this.nilaiPajak;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    return data;
  }
}
