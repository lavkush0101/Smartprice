import '../models/product_comparison.dart';

class CartItem {
  final ProductComparison product;
  int quantity;
  String preferredStore; // 'cheapest', 'blinkit', 'zepto'

  CartItem({
    required this.product,
    this.quantity = 1,
    this.preferredStore = 'cheapest',
  });

  StoreOffer get selectedOffer {
    if (preferredStore.toLowerCase() == 'blinkit') {
      try {
        return product.offers.firstWhere((o) => o.store.toLowerCase() == 'blinkit');
      } catch (_) {}
    } else if (preferredStore.toLowerCase() == 'zepto') {
      try {
        return product.offers.firstWhere((o) => o.store.toLowerCase() == 'zepto');
      } catch (_) {}
    }

    // Default to cheapest store
    try {
      return product.offers.firstWhere(
        (o) => o.store.toLowerCase() == product.cheapestStore.toLowerCase(),
      );
    } catch (_) {
      return product.offers.isNotEmpty
          ? product.offers.first
          : StoreOffer(
              store: 'Store',
              price: 0,
              mrp: 0,
              inStock: true,
              eta: '10 mins',
              deepLink: '',
              packageName: '',
            );
    }
  }

  double get itemTotal => selectedOffer.price * quantity;
  double get itemSavings => product.savings * quantity;
}
