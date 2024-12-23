class Category {
  int? idKategori;
  String? namaKategori;
  int? jumlahProduct;
  List<DetailOutlet>? detailOutlet;
  List<DetailProduct>? detailProduct;
  List<ProductOutlet>? productOutlet;
  String? createdAt;

  Category(
      {this.idKategori,
      this.namaKategori,
      this.jumlahProduct,
      this.detailOutlet,
      this.detailProduct,
      this.productOutlet,
      this.createdAt});

  Category.fromJson(Map<String, dynamic> json) {
    idKategori = json['id_kategori'];
    namaKategori = json['nama_kategori'];
    jumlahProduct = json['jumlah_product'];
    if (json['detailOutlet'] != null) {
      detailOutlet = <DetailOutlet>[];
      json['detailOutlet'].forEach((v) {
        detailOutlet!.add(new DetailOutlet.fromJson(v));
      });
    }
    if (json['detailProduct'] != null) {
      detailProduct = <DetailProduct>[];
      json['detailProduct'].forEach((v) {
        detailProduct!.add(new DetailProduct.fromJson(v));
      });
    }
    if (json['productOutlet'] != null) {
      productOutlet = <ProductOutlet>[];
      json['productOutlet'].forEach((v) {
        productOutlet!.add(new ProductOutlet.fromJson(v));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_kategori'] = this.idKategori;
    data['nama_kategori'] = this.namaKategori;
    data['jumlah_product'] = this.jumlahProduct;
    if (this.detailOutlet != null) {
      data['detailOutlet'] = this.detailOutlet!.map((v) => v.toJson()).toList();
    }
    if (this.detailProduct != null) {
      data['detailProduct'] =
          this.detailProduct!.map((v) => v.toJson()).toList();
    }
    if (this.productOutlet != null) {
      data['productOutlet'] =
          this.productOutlet!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    return data;
  }
}

class DetailOutlet {
  int? id;
  String? nama;
  String? position;
  int? categoryOutletId;

  DetailOutlet({this.id, this.nama, this.position, this.categoryOutletId});

  DetailOutlet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    position = json['position'];
    categoryOutletId = json['categoryOutletId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama'] = this.nama;
    data['position'] = this.position;
    data['categoryOutletId'] = this.categoryOutletId;
    return data;
  }
}

class DetailProduct {
  int? id;
  String? nama;

  DetailProduct({this.id, this.nama});

  DetailProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama'] = this.nama;
    return data;
  }
}

class ProductOutlet {
  int? outletId;
  int? productId;
  String? outletName;
  String? productName;
  int? productOutletId;

  ProductOutlet(
      {this.outletId,
      this.productId,
      this.outletName,
      this.productName,
      this.productOutletId});

  ProductOutlet.fromJson(Map<String, dynamic> json) {
    outletId = json['outletId'];
    productId = json['productId'];
    outletName = json['outletName'];
    productName = json['productName'];
    productOutletId = json['productOutletId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['outletId'] = this.outletId;
    data['productId'] = this.productId;
    data['outletName'] = this.outletName;
    data['productName'] = this.productName;
    data['productOutletId'] = this.productOutletId;
    return data;
  }
}
