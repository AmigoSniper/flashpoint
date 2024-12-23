class Productcategory {
  int? productCategoryId;
  int? categoryId;
  String? categoryName;
  int? productId;
  String? productName;

  Productcategory(
      {this.productCategoryId,
      this.categoryId,
      this.categoryName,
      this.productId,
      this.productName});

  Productcategory.fromJson(Map<String, dynamic> json) {
    productCategoryId = json['productCategoryId'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    productId = json['productId'];
    productName = json['productName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productCategoryId'] = this.productCategoryId;
    data['categoryId'] = this.categoryId;
    data['categoryName'] = this.categoryName;
    data['productId'] = this.productId;
    data['productName'] = this.productName;
    return data;
  }
}
