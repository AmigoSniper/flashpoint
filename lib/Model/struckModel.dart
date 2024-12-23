class struckModel {
  bool? success;
  String? message;
  Data? data;

  struckModel({this.success, this.message, this.data});

  factory struckModel.fromJson(Map<String, dynamic> json) {
    return struckModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Struks>? struks;
  List<DetailStrukTeks>? detailStrukTeks;
  List<DetailStrukMedia>? detailStrukMedia;
  List<DetailStrukLogo>? detailStrukLogo;

  Data(
      {this.struks,
      this.detailStrukTeks,
      this.detailStrukMedia,
      this.detailStrukLogo});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      struks: json['struks'] != null
          ? (json['struks'] as List).map((i) => Struks.fromJson(i)).toList()
          : [],
      detailStrukTeks: json['detailStrukTeks'] != null
          ? (json['detailStrukTeks'] as List)
              .map((i) => DetailStrukTeks.fromJson(i))
              .toList()
          : [],
      detailStrukMedia: json['detailStrukMedia'] != null
          ? (json['detailStrukMedia'] as List)
              .map((i) => DetailStrukMedia.fromJson(i))
              .toList()
          : [],
      detailStrukLogo: json['detailStrukLogo'] != null
          ? (json['detailStrukLogo'] as List)
              .map((i) => DetailStrukLogo.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.struks != null) {
      data['struks'] = this.struks!.map((v) => v.toJson()).toList();
    }
    if (this.detailStrukTeks != null) {
      data['detailStrukTeks'] =
          this.detailStrukTeks!.map((v) => v.toJson()).toList();
    }
    if (this.detailStrukMedia != null) {
      data['detailStrukMedia'] =
          this.detailStrukMedia!.map((v) => v.toJson()).toList();
    }
    if (this.detailStrukLogo != null) {
      data['detailStrukLogo'] =
          this.detailStrukLogo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Struks {
  int? id;
  String? name;
  String? status;

  Struks({this.id, this.name, this.status});

  factory Struks.fromJson(Map<String, dynamic> json) {
    return Struks(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'status': this.status,
    };
  }
}

class DetailStrukTeks {
  int? detailStrukTeksId;
  int? struksId;
  String? name;
  String? text;

  DetailStrukTeks(
      {this.detailStrukTeksId, this.struksId, this.name, this.text});

  factory DetailStrukTeks.fromJson(Map<String, dynamic> json) {
    return DetailStrukTeks(
      detailStrukTeksId: json['detailStrukTeks_Id'],
      struksId: json['struks_Id'],
      name: json['name'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailStrukTeks_Id': this.detailStrukTeksId,
      'struks_Id': this.struksId,
      'name': this.name,
      'text': this.text,
    };
  }
}

class DetailStrukMedia {
  int? detailStrukMediaId;
  int? struksId;
  String? name;
  String? kategori;
  String? nameMedia;

  DetailStrukMedia(
      {this.detailStrukMediaId,
      this.struksId,
      this.name,
      this.kategori,
      this.nameMedia});

  factory DetailStrukMedia.fromJson(Map<String, dynamic> json) {
    return DetailStrukMedia(
      detailStrukMediaId: json['detailStrukMedia_Id'],
      struksId: json['struks_Id'],
      name: json['name'],
      kategori: json['kategori'],
      nameMedia: json['nameMedia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailStrukMedia_Id': this.detailStrukMediaId,
      'struks_Id': this.struksId,
      'name': this.name,
      'kategori': this.kategori,
      'nameMedia': this.nameMedia,
    };
  }
}

class DetailStrukLogo {
  int? detailStrukLogoId;
  int? struksId;
  String? name;
  String? logo;

  DetailStrukLogo(
      {this.detailStrukLogoId, this.struksId, this.name, this.logo});

  factory DetailStrukLogo.fromJson(Map<String, dynamic> json) {
    return DetailStrukLogo(
      detailStrukLogoId: json['detailStrukLogo_Id'],
      struksId: json['struks_Id'],
      name: json['name'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailStrukLogo_Id': this.detailStrukLogoId,
      'struks_Id': this.struksId,
      'name': this.name,
      'logo': this.logo,
    };
  }
}
