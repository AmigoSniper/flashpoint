class Productoutlet {
  int? productOutletId;
  int? productId;
  String? productName;
  int? outletId;
  String? outletName;

  Productoutlet(
      {this.productOutletId,
      this.productId,
      this.productName,
      this.outletId,
      this.outletName});

  Productoutlet.fromJson(Map<String, dynamic> json) {
    productOutletId = json['productOutletId'];
    productId = json['productId'];
    productName = json['productName'];
    outletId = json['outletId'];
    outletName = json['outletName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productOutletId'] = this.productOutletId;
    data['productId'] = this.productId;
    data['productName'] = this.productName;
    data['outletId'] = this.outletId;
    data['outletName'] = this.outletName;
    return data;
  }
}
