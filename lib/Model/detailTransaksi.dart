class Detailtransaksi {
  int? id;
  int? transaksiId;
  int? productId;
  String? productName;
  int? productPrice;
  int? stok;

  Detailtransaksi(
      {this.id,
      this.transaksiId,
      this.productId,
      this.productName,
      this.productPrice,
      this.stok});

  Detailtransaksi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transaksiId = json['transaksi_id'];
    productId = json['product_id'];
    productName = json['product_name'];
    productPrice = json['product_price'];
    stok = json['stok'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['transaksi_id'] = this.transaksiId;
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_price'] = this.productPrice;
    data['stok'] = this.stok;
    return data;
  }
}
