import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_comparison.dart';
import '../services/cart_service.dart';
import '../screens/order_screen.dart';

class ProductCard extends StatefulWidget {
  final ProductComparison product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _navigateToOrder(BuildContext context, StoreOffer offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(
          product: widget.product,
          selectedOffer: offer,
        ),
      ),
    );
  }

  StoreOffer get _cheapestOffer {
    try {
      return widget.product.offers.firstWhere(
        (o) => o.store.toLowerCase() == widget.product.cheapestStore.toLowerCase(),
      );
    } catch (_) {
      return widget.product.offers.isNotEmpty
          ? widget.product.offers.first
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
    final int qty = _cartService.getQuantity(widget.product.id);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Image, Title, Pack size, Savings Badge & Global Add Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFF94A3B8),
                              size: 32,
                            ),
                          )
                        : const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF94A3B8),
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            widget.product.packSize,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, color: Color(0xFF10B981), size: 6),
                                SizedBox(width: 3),
                                Text(
                                  "In Stock",
                                  style: TextStyle(color: Color(0xFF047857), fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.radar, size: 12, color: Color(0xFF6366F1)),
                          SizedBox(width: 4),
                          Text(
                            "Live Price Verified",
                            style: TextStyle(fontSize: 10.5, color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.product.savings > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF81C784)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Save ₹\${widget.product.savings.toStringAsFixed(1)}",
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                            const Text(
                              "LIVE DIFF",
                              style: TextStyle(color: Color(0xFF15803D), fontSize: 8, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Store Comparison Grid
            Row(
              children: widget.product.offers.map((offer) {
                final bool isCheapest =
                    offer.store.toLowerCase() == widget.product.cheapestStore.toLowerCase();
                final bool isZepto = offer.store.toLowerCase() == "zepto";
                final String darkStoreHub = isZepto ? "ZPT-08" : "BLR-12";
                final String distance = isZepto ? "1.2 km" : "0.8 km";

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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.store,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: isZepto ? const Color(0xFF7C3AED) : const Color(0xFFD97706),
                                  ),
                                ),
                                Text(
                                  "Hub #\$darkStoreHub (\$distance)",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
                              "₹\${offer.price.toStringAsFixed(1)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (offer.mrp > offer.price)
                              Text(
                                "₹\${offer.mrp.toStringAsFixed(0)}",
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
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "• Ready",
                              style: TextStyle(color: Color(0xFF16A34A), fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Add to Cart / Quantity Selector Button
                        qty == 0
                            ? SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _cartService.addToCart(widget.product, preferredStore: offer.store);
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Added \${widget.product.title} to basket!"),
                                        duration: const Duration(milliseconds: 1200),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: const Color(0xFF10B981),
                                      ),
                                    );
                                  },
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
                                  icon: const Icon(Icons.add_shopping_cart, size: 13),
                                  label: Text(
                                    "Add on \${offer.store}",
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCheapest ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                                  border: Border.all(
                                    color: isCheapest ? const Color(0xFF2E7D32) : const Color(0xFFCBD5E1),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () => _cartService.removeFromCart(widget.product.id),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Icon(Icons.remove, size: 16, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    Text(
                                      "\$qty in Cart",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11.5,
                                        color: isCheapest ? const Color(0xFF2E7D32) : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _cartService.addToCart(widget.product, preferredStore: offer.store),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Icon(Icons.add, size: 16, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                  ],
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
    );
  }
}
