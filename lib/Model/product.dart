class Product {
  int? productId;
  String? productName;
  String? description;
  int? price;
  int? stock;
  int? unlimitedStock;
  String? status;
  String? productCreatedAt;
  String? categoryNames;
  String? outletNames;
  List<DetailCategories>? detailCategories;
  List<DetailOutlets>? detailOutlets;
  List<DetailImages>? detailImages;

  Product(
      {this.productId,
      this.productName,
      this.description,
      this.price,
      this.stock,
      this.unlimitedStock,
      this.status,
      this.productCreatedAt,
      this.categoryNames,
      this.outletNames,
      this.detailCategories,
      this.detailOutlets,
      this.detailImages});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    description = json['description'];
    price = json['price'];
    stock = json['stock'];
    unlimitedStock = json['unlimited_stock'];
    status = json['status'];
    productCreatedAt = json['product_created_at'];
    categoryNames = json['category_names'];
    outletNames = json['outlet_names'];
    if (json['detailCategories'] != null) {
      detailCategories = <DetailCategories>[];
      json['detailCategories'].forEach((v) {
        detailCategories!.add(new DetailCategories.fromJson(v));
      });
    }
    if (json['detailOutlets'] != null) {
      detailOutlets = <DetailOutlets>[];
      json['detailOutlets'].forEach((v) {
        detailOutlets!.add(new DetailOutlets.fromJson(v));
      });
    }
    if (json['detailImages'] != null) {
      detailImages = <DetailImages>[];
      json['detailImages'].forEach((v) {
        detailImages!.add(new DetailImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['description'] = this.description;
    data['price'] = this.price;
    data['stock'] = this.stock;
    data['unlimited_stock'] = this.unlimitedStock;
    data['status'] = this.status;
    data['product_created_at'] = this.productCreatedAt;
    data['category_names'] = this.categoryNames;
    data['outlet_names'] = this.outletNames;
    if (this.detailCategories != null) {
      data['detailCategories'] =
          this.detailCategories!.map((v) => v.toJson()).toList();
    }
    if (this.detailOutlets != null) {
      data['detailOutlets'] =
          this.detailOutlets!.map((v) => v.toJson()).toList();
    }
    if (this.detailImages != null) {
      data['detailImages'] = this.detailImages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DetailCategories {
  int? id;
  int? productsId;
  int? categoriesId;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;
  String? categoryName;

  DetailCategories(
      {this.id,
      this.productsId,
      this.categoriesId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.categoryName});

  DetailCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productsId = json['productsId'];
    categoriesId = json['categoriesId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productsId'] = this.productsId;
    data['categoriesId'] = this.categoriesId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    data['category_name'] = this.categoryName;
    return data;
  }
}

class DetailOutlets {
  int? id;
  int? productsId;
  int? outletsId;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;
  String? outletName;

  DetailOutlets(
      {this.id,
      this.productsId,
      this.outletsId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.outletName});

  DetailOutlets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productsId = json['productsId'];
    outletsId = json['outletsId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    outletName = json['outlet_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productsId'] = this.productsId;
    data['outletsId'] = this.outletsId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    data['outlet_name'] = this.outletName;
    return data;
  }
}

class DetailImages {
  int? id;
  int? productsId;
  String? image;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;

  DetailImages(
      {this.id,
      this.productsId,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  DetailImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productsId = json['productsId'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productsId'] = this.productsId;
    data['image'] = this.image;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    return data;
  }
}
