class StoreOffer {
  final String store;
  final double price;
  final double mrp;
  final bool inStock;
  final String eta;
  final String deepLink;
  final String packageName;

  StoreOffer({
    required this.store,
    required this.price,
    required this.mrp,
    required this.inStock,
    required this.eta,
    required this.deepLink,
    required this.packageName,
  });

  factory StoreOffer.fromJson(Map<String, dynamic> json) {
    return StoreOffer(
      store: json['store'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      inStock: json['inStock'] ?? true,
      eta: json['eta'] ?? '10-15 mins',
      deepLink: json['deepLink'] ?? '',
      packageName: json['packageName'] ?? '',
    );
  }
}

class ProductComparison {
  final String id;
  final String title;
  final String packSize;
  final String imageUrl;
  final String cheapestStore;
  final double savings;
  final List<StoreOffer> offers;

  ProductComparison({
    required this.id,
    required this.title,
    required this.packSize,
    required this.imageUrl,
    required this.cheapestStore,
    required this.savings,
    required this.offers,
  });

  factory ProductComparison.fromJson(Map<String, dynamic> json) {
    var rawOffers = json['offers'] as List? ?? [];
    List<StoreOffer> offerList =
        rawOffers.map((o) => StoreOffer.fromJson(o)).toList();

    return ProductComparison(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      packSize: json['packSize'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      cheapestStore: json['cheapestStore'] ?? '',
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
      offers: offerList,
    );
  }
}
