class SelectedProduct {
  final int id;
  final String name;
  final String imageUrl;
  int unlimitedStock;
  int? stock;
  int quantity;
  final int price;

  SelectedProduct(
      {required this.name,
      this.stock,
      required this.unlimitedStock,
      required this.id,
      required this.imageUrl,
      required this.quantity,
      required this.price});
}
