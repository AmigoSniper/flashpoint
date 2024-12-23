class Transaksi {
  int? penjualanId;
  int? outletId;
  int? kasirId;
  int? userId;
  String? tipeOrder;
  String? transaksiName;
  String? catatan;
  String? tipeBayar;
  String? ketBayar;
  int? subTotal;
  int? total;
  int? bayar;
  int? kembalian;
  String? createdAt;
  String? outletName;
  String? kasirName;
  List<Detailtransaksi>? detailtransaksi;
  List<Detailpajaks>? detailpajaks;
  List<Detaildiskons>? detaildiskons;

  Transaksi(
      {this.penjualanId,
      this.outletId,
      this.kasirId,
      this.userId,
      this.tipeOrder,
      this.transaksiName,
      this.catatan,
      this.tipeBayar,
      this.ketBayar,
      this.subTotal,
      this.total,
      this.bayar,
      this.kembalian,
      this.createdAt,
      this.outletName,
      this.kasirName,
      this.detailtransaksi,
      this.detailpajaks,
      this.detaildiskons});

  Transaksi.fromJson(Map<String, dynamic> json) {
    penjualanId = json['penjualan_id'];
    outletId = json['outlet_id'];
    kasirId = json['kasir_id'];
    userId = json['user_id'];
    tipeOrder = json['tipe_order'];
    transaksiName = json['transaksi_name'];
    catatan = json['catatan'];
    tipeBayar = json['tipe_bayar'];
    ketBayar = json['ket_bayar'];
    subTotal = json['sub_total'];
    total = json['total'];
    bayar = json['bayar'];
    kembalian = json['kembalian'];
    createdAt = json['createdAt'];
    outletName = json['outlet_name'];
    kasirName = json['kasir_name'];
    if (json['detailtransaksi'] != null) {
      detailtransaksi = <Detailtransaksi>[];
      json['detailtransaksi'].forEach((v) {
        detailtransaksi!.add(new Detailtransaksi.fromJson(v));
      });
    }
    if (json['detailpajaks'] != null) {
      detailpajaks = <Detailpajaks>[];
      json['detailpajaks'].forEach((v) {
        detailpajaks!.add(new Detailpajaks.fromJson(v));
      });
    }
    if (json['detaildiskons'] != null) {
      detaildiskons = <Detaildiskons>[];
      json['detaildiskons'].forEach((v) {
        detaildiskons!.add(new Detaildiskons.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['penjualan_id'] = penjualanId;
    data['outlet_id'] = outletId;
    data['kasir_id'] = kasirId;
    data['user_id'] = userId;
    data['tipe_order'] = tipeOrder;
    data['transaksi_name'] = transaksiName;
    data['catatan'] = catatan;
    data['tipe_bayar'] = tipeBayar;
    data['ket_bayar'] = ketBayar;
    data['sub_total'] = subTotal;
    data['total'] = total;
    data['bayar'] = bayar;
    data['kembalian'] = kembalian;
    data['createdAt'] = createdAt;
    data['outlet_name'] = outletName;
    data['kasir_name'] = kasirName;
    if (detailtransaksi != null) {
      data['detailtransaksi'] =
          detailtransaksi!.map((v) => v.toJson()).toList();
    }
    if (detailpajaks != null) {
      data['detailpajaks'] = detailpajaks!.map((v) => v.toJson()).toList();
    }
    if (detaildiskons != null) {
      data['detaildiskons'] = detaildiskons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Detailtransaksi {
  int? id;
  int? transaksiId;
  int? productId;
  String? productName;
  int? productPrice;
  int? stok;
  String? foto;

  Detailtransaksi(
      {this.id,
      this.transaksiId,
      this.productId,
      this.productName,
      this.productPrice,
      this.stok,
      this.foto});

  Detailtransaksi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transaksiId = json['transaksi_id'];
    productId = json['product_id'];
    productName = json['product_name'];
    productPrice = json['product_price'];
    stok = json['stok'];
    foto = json['foto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['transaksi_id'] = transaksiId;
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_price'] = productPrice;
    data['stok'] = stok;
    data['foto'] = foto;
    return data;
  }
}

class Detailpajaks {
  int? id;
  int? transaksiId;
  int? pajakId;
  String? pajakName;
  int? harga;

  Detailpajaks(
      {this.id, this.transaksiId, this.pajakId, this.pajakName, this.harga});

  Detailpajaks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transaksiId = json['transaksi_id'];
    pajakId = json['pajak_id'];
    pajakName = json['pajak_name'];
    harga = json['harga'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['transaksi_id'] = transaksiId;
    data['pajak_id'] = pajakId;
    data['pajak_name'] = pajakName;
    data['harga'] = harga;
    return data;
  }
}

class Detaildiskons {
  int? id;
  int? transaksiId;
  int? diskonId;
  String? diskonName;
  int? harga;

  Detaildiskons(
      {this.id, this.transaksiId, this.diskonId, this.diskonName, this.harga});

  Detaildiskons.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transaksiId = json['transaksi_id'];
    diskonId = json['diskon_id'];
    diskonName = json['diskon_name'];
    harga = json['harga'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['transaksi_id'] = transaksiId;
    data['diskon_id'] = diskonId;
    data['diskon_name'] = diskonName;
    data['harga'] = harga;
    return data;
  }
}
