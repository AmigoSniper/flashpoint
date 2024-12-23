class Diskon {
  int id;
  String name;
  double percentage;
  double nominal;
  String tipeDiskon;
  String tipeAktivation;
  int? maxDiskon;
  List<String> outlet;
  bool semuaOutlet;
  String deskripsi;
  double? minimalPembelian;
  DateTime tanggalMulai;
  DateTime tanggalBerakhir;
  String jamMulai;
  String jamBerakhir;
  List<String> hariPromo;
  String status;

  Diskon({
    required this.id,
    required this.name,
    required this.tipeDiskon,
    required this.tipeAktivation,
    required this.deskripsi,
    this.percentage = 0,
    this.nominal = 0,
    this.outlet = const [],
    this.semuaOutlet = false, // default false
    this.minimalPembelian,
    this.maxDiskon,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.jamMulai,
    required this.jamBerakhir,
    required this.hariPromo,
    required this.status,
  }) {
    if (tipeDiskon == "percentage" && (percentage < 0 || percentage > 100)) {
      throw ArgumentError("Percentage must be between 0 and 100");
    }
    if (tipeDiskon == "nominal" && nominal < 0) {
      throw ArgumentError("Nominal discount cannot be negative");
    }
  }

  double hitungDiskon(double harga) {
    if (tipeDiskon == "percentage") {
      return harga * (percentage / 100);
    } else if (tipeDiskon == "nominal") {
      return nominal;
    }
    return 0;
  }

  double hargaSetelahDiskon(double harga) {
    double diskon = hitungDiskon(harga);
    return harga -
        (maxDiskon != null && diskon > maxDiskon! ? maxDiskon! : diskon);
  }

  @override
  String toString() =>
      '$name - ${tipeDiskon == "percentage" ? "$percentage% off" : "Rp$nominal off"}';
}
