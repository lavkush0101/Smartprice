import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_comparison.dart';
import '../screens/order_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductComparison product;

  const ProductCard({super.key, required this.product});

  void _navigateToOrder(BuildContext context, StoreOffer offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(
          product: product,
          selectedOffer: offer,
        ),
      ),
    );
  }

  StoreOffer get _cheapestOffer {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToOrder(context, _cheapestOffer),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Top Row: Image, Title, Pack size and Savings Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey,
                              size: 28,
                            ),
                          )
                        : const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.grey,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.packSize,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (product.savings > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF81C784)),
                    ),
                    child: Text(
                      "Save ₹${product.savings.toStringAsFixed(1)}",
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Store Comparison Grid
            Row(
              children: product.offers.map((offer) {
                final bool isCheapest =
                    offer.store.toLowerCase() == product.cheapestStore.toLowerCase();
                final bool isZepto = offer.store.toLowerCase() == "zepto";

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCheapest ? const Color(0xFFF1F8E9) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCheapest ? const Color(0xFF81C784) : Colors.grey.shade300,
                        width: isCheapest ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Name & Cheapest Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              offer.store,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isZepto ? const Color(0xFF7C3AED) : const Color(0xFFD97706),
                              ),
                            ),
                            if (isCheapest)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "CHEAPEST",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Price & MRP
                        Row(
                          children: [
                            Text(
                              "₹${offer.price.toStringAsFixed(1)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (offer.mrp > offer.price)
                              Text(
                                "₹${offer.mrp.toStringAsFixed(0)}",
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // ETA
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange, size: 14),
                            Text(
                              offer.eta,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Buy Button
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => _navigateToOrder(context, offer),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCheapest
                                  ? const Color(0xFF2E7D32)
                                  : (isZepto ? const Color(0xFF7C3AED) : const Color(0xFFD97706)),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Buy on ${offer.store}",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}
}
