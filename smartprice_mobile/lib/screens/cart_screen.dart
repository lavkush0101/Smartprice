import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  final CartService _cartService = CartService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _launchStoreApp(String store, List<CartItem> storeItems) async {
    final isZepto = store.toLowerCase() == 'zepto';
    final packageName = isZepto ? 'com.zepto.customer' : 'com.grofers.customerapp';
    final fallbackWebUrl = isZepto ? 'https://www.zeptonow.com/cart' : 'https://blinkit.com/cart';
    final firstItemLink = storeItems.isNotEmpty ? storeItems.first.selectedOffer.deepLink : fallbackWebUrl;

    // Construct deep link URI
    final Uri appUri = Uri.parse(firstItemLink.isNotEmpty ? firstItemLink : fallbackWebUrl);

    try {
      final launched = await launchUrl(
        appUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        await launchUrl(Uri.parse(fallbackWebUrl), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(Uri.parse(fallbackWebUrl), mode: LaunchMode.externalApplication);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.open_in_new, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text("Opening \$store with \${storeItems.length} selected item(s)..."),
              ),
            ],
          ),
          backgroundColor: isZepto ? const Color(0xFF7C3AED) : const Color(0xFFD97706),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Smart Basket",
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 18),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => _cartService.clearCart(),
              child: const Text("Clear", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
        ],
        bottom: items.isNotEmpty
            ? TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF4F46E5),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFF4F46E5),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "🏆 Split Basket (Max Savings)"),
                  Tab(text: "🏪 Single Store (1 Order)"),
                ],
              )
            : null,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_basket_outlined, size: 72, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  const Text(
                    "Your basket is empty",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add items from different stores to compare & save!",
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Start Shopping", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSplitBasketTab(),
                _buildSingleStoreTab(),
              ],
            ),
    );
  }

  Widget _buildSplitBasketTab() {
    final zeptoItems = _cartService.zeptoItems;
    final blinkitItems = _cartService.blinkitItems;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Savings Callout Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                child: const Icon(Icons.savings_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You Save ₹\${_cartService.totalSavings.toStringAsFixed(1)} on this order!",
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF047857), fontSize: 13),
                    ),
                    const Text(
                      "Items split across Blinkit & Zepto for lowest total bill",
                      style: TextStyle(color: Color(0xFF065F46), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Zepto Cart Section
        if (zeptoItems.isNotEmpty)
          _buildStoreSection(
            store: "Zepto",
            items: zeptoItems,
            subtotal: _cartService.zeptoSubtotal,
            color: const Color(0xFF7C3AED),
            badgeColor: const Color(0xFFEDE9FE),
            eta: "8-11 mins",
          ),

        if (zeptoItems.isNotEmpty && blinkitItems.isNotEmpty)
          const SizedBox(height: 20),

        // Blinkit Cart Section
        if (blinkitItems.isNotEmpty)
          _buildStoreSection(
            store: "Blinkit",
            items: blinkitItems,
            subtotal: _cartService.blinkitSubtotal,
            color: const Color(0xFFD97706),
            badgeColor: const Color(0xFFFEF3C7),
            eta: "10-14 mins",
          ),

        const SizedBox(height: 24),
        _buildBillSummary(),
      ],
    );
  }

  Widget _buildStoreSection({
    required String store,
    required List<CartItem> items,
    required double subtotal,
    required Color color,
    required Color badgeColor,
    required String eta,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Store Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  store,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    "\${items.length} item(s)",
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.orange, size: 14),
                    Text(eta, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  ],
                ),
              ],
            ),
          ),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: const Color(0xFFF1F5F9),
                      child: item.product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(imageUrl: item.product.imageUrl, fit: BoxFit.cover)
                          : const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.product.packSize,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                        Text(
                          "₹\${item.selectedOffer.price.toStringAsFixed(1)} each",
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: color),
                        ),
                      ],
                    ),
                  ),

                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _cartService.removeFromCart(item.product.id),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Icon(Icons.remove, size: 14, color: Color(0xFF64748B)),
                          ),
                        ),
                        Text(
                          "\${item.quantity}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        InkWell(
                          onTap: () => _cartService.addToCart(item.product),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Icon(Icons.add, size: 14, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Store Action & Subtotal
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Store Total", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text(
                      "₹\${subtotal.toStringAsFixed(1)}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.launch, size: 16),
                  label: Text(
                    "Order \${items.length} on \$store",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: () => _launchStoreApp(store, items),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleStoreTab() {
    final zeptoTotal = _cartService.allOnZeptoTotal;
    final blinkitTotal = _cartService.allOnBlinkitTotal;
    final bool isZeptoCheaper = zeptoTotal <= blinkitTotal;
    final double diff = (zeptoTotal - blinkitTotal).abs();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF4F46E5), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isZeptoCheaper
                      ? "Zepto is ₹\${diff.toStringAsFixed(1)} cheaper if ordering everything together!"
                      : "Blinkit is ₹\${diff.toStringAsFixed(1)} cheaper if ordering everything together!",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3730A3), fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Order All on Zepto Card
        _buildSingleStoreCard(
          store: "Zepto",
          total: zeptoTotal,
          color: const Color(0xFF7C3AED),
          isCheapest: isZeptoCheaper,
          items: _cartService.items,
        ),
        const SizedBox(height: 16),

        // Order All on Blinkit Card
        _buildSingleStoreCard(
          store: "Blinkit",
          total: blinkitTotal,
          color: const Color(0xFFD97706),
          isCheapest: !isZeptoCheaper,
          items: _cartService.items,
        ),
      ],
    );
  }

  Widget _buildSingleStoreCard({
    required String store,
    required double total,
    required Color color,
    required bool isCheapest,
    required List<CartItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCheapest ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: isCheapest ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Everything on \$store",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color),
              ),
              if (isCheapest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "BEST SINGLE STORE",
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "All \${items.length} item(s) delivered in 1 shipment",
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹\${total.toStringAsFixed(1)}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                label: Text("Open \$store App", style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _launchStoreApp(store, items),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bill Details", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Items Total", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              Text("₹\${(_cartService.totalAmount + _cartService.totalSavings).toStringAsFixed(1)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SmartPrice Split Savings", style: TextStyle(color: Color(0xFF15803D), fontSize: 13, fontWeight: FontWeight.bold)),
              Text("- ₹\${_cartService.totalSavings.toStringAsFixed(1)}", style: const TextStyle(color: Color(0xFF15803D), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("To Pay", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
              Text("₹\${_cartService.totalAmount.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }
}
