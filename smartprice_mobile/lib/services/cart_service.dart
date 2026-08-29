import 'package:flutter/foundation.dart';
import '../models/product_comparison.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.itemTotal);

  double get totalSavings => _items.fold(0.0, (sum, item) => sum + item.itemSavings);

  int getQuantity(String productId) {
    try {
      final item = _items.firstWhere((i) => i.product.id == productId);
      return item.quantity;
    } catch (_) {
      return 0;
    }
  }

  void addToCart(ProductComparison product, {String preferredStore = 'cheapest'}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += 1;
      _items[index].preferredStore = preferredStore;
    } else {
      _items.add(CartItem(product: product, quantity: 1, preferredStore: preferredStore));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void deleteItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Split basket helpers
  List<CartItem> get zeptoItems => _items.where((i) => i.selectedOffer.store.toLowerCase() == 'zepto').toList();
  List<CartItem> get blinkitItems => _items.where((i) => i.selectedOffer.store.toLowerCase() == 'blinkit').toList();

  double get zeptoSubtotal => zeptoItems.fold(0.0, (sum, item) => sum + item.itemTotal);
  double get blinkitSubtotal => blinkitItems.fold(0.0, (sum, item) => sum + item.itemTotal);

  // Single store subtotal calculations
  double get allOnZeptoTotal {
    double total = 0.0;
    for (final item in _items) {
      try {
        final zOffer = item.product.offers.firstWhere((o) => o.store.toLowerCase() == 'zepto');
        total += zOffer.price * item.quantity;
      } catch (_) {
        total += item.itemTotal;
      }
    }
    return total;
  }

  double get allOnBlinkitTotal {
    double total = 0.0;
    for (final item in _items) {
      try {
        final bOffer = item.product.offers.firstWhere((o) => o.store.toLowerCase() == 'blinkit');
        total += bOffer.price * item.quantity;
      } catch (_) {
        total += item.itemTotal;
      }
    }
    return total;
  }
}
