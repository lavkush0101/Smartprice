import 'package:flutter/material.dart';
import '../models/product_comparison.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/cart_service.dart';
import '../widgets/location_bar.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final CartService _cartService = CartService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRefreshing = false;

  String _areaName = "18 1st main road 3rd cross";
  String _fullAddress = "18 1st main road 3rd cross, Sapthagiri Layout Rd, phase 2, Chansandra, Bengaluru 560067";
  String _eta = "8-11 MINS";
  double _lat = 12.9922;
  double _lng = 77.7290;

  bool _isDetectingGps = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<ProductComparison> _products = [];
  String _selectedCategory = "all";

  final List<Map<String, String>> _categories = [
    {"id": "all", "name": "All Products", "icon": "🔥"},
    {"id": "dairy", "name": "Dairy & Milk", "icon": "🥛"},
    {"id": "fruits_veg", "name": "Fruits & Veg", "icon": "🍎"},
    {"id": "bakery", "name": "Bakery & Eggs", "icon": "🍞"},
    {"id": "snacks", "name": "Snacks & Munchies", "icon": "🍿"},
    {"id": "drinks", "name": "Cold Drinks", "icon": "🥤"},
    {"id": "staples", "name": "Atta, Rice & Oil", "icon": "🍚"},
    {"id": "sweets", "name": "Chocolates", "icon": "🍫"},
    {"id": "tea_coffee", "name": "Tea & Coffee", "icon": "☕"},
    {"id": "cleaning", "name": "Cleaning", "icon": "🧹"},
    {"id": "personal_care", "name": "Personal Care", "icon": "✨"},
  ];

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _executeSearch(query: "", category: "all");
    _restoreSavedLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestLocationOnStartup();
    });
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _openCartScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  Future<void> _handleManualLiveRefresh() async {
    setState(() => _isRefreshing = true);
    await _executeSearch(query: _searchController.text, category: _selectedCategory);
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text("Real-time prices verified across Dark Stores!"),
            ],
          ),
          backgroundColor: const Color(0xFF15803D),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _restoreSavedLocation() async {
    final saved = await LocationService.getSavedLocation();
    if (saved != null && mounted) {
      setState(() {
        _areaName = saved.areaName;
        _fullAddress = saved.fullAddress;
        _eta = saved.eta;
        _lat = saved.lat;
        _lng = saved.lng;
      });
      _executeSearch(query: _searchController.text, category: _selectedCategory);
    }
  }

  Future<void> _checkAndRequestLocationOnStartup() async {
    setState(() => _isDetectingGps = true);
    final result = await LocationService.fetchCurrentLocation();
    if (!mounted) return;
    setState(() => _isDetectingGps = false);

    if (result.success) {
      setState(() {
        _lat = result.lat;
        _lng = result.lng;
        _areaName = result.areaName;
        _fullAddress = result.fullAddress;
        _eta = result.eta;
      });
      _executeSearch(query: _searchController.text, category: _selectedCategory);
    }
  }

  Future<void> _detectGpsLocation() async {
    setState(() => _isDetectingGps = true);
    final result = await LocationService.fetchCurrentLocation();
    if (!mounted) return;
    setState(() => _isDetectingGps = false);

    if (result.success) {
      setState(() {
        _lat = result.lat;
        _lng = result.lng;
        _areaName = result.areaName;
        _fullAddress = result.fullAddress;
        _eta = result.eta;
      });
      _executeSearch(query: _searchController.text, category: _selectedCategory);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location updated to: \${result.areaName}"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? "Could not get current location"),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _onCitySelected(CityPreset city) {
    setState(() {
      _areaName = city.areaName;
      _fullAddress = city.fullAddress;
      _eta = city.eta;
      _lat = city.lat;
      _lng = city.lng;
    });
    LocationService.saveLocation(LocationResult(
      success: true,
      areaName: city.areaName,
      fullAddress: city.fullAddress,
      displayName: city.name,
      pincode: city.pincode,
      eta: city.eta,
      lat: city.lat,
      lng: city.lng,
    ));
    _executeSearch(query: _searchController.text, category: _selectedCategory);
  }

  void _onCustomLocationSaved(LocationResult customLoc) {
    setState(() {
      _areaName = customLoc.areaName;
      _fullAddress = customLoc.fullAddress;
      _eta = customLoc.eta;
      _lat = customLoc.lat;
      _lng = customLoc.lng;
    });
    LocationService.saveLocation(customLoc);
    _executeSearch(query: _searchController.text, category: _selectedCategory);
  }

  Future<void> _executeSearch({String? query, String? category}) async {
    final activeQuery = query ?? _searchController.text;
    final activeCat = category ?? _selectedCategory;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (category != null) _selectedCategory = category;
    });

    try {
      final results = await _apiService.compareProducts(
        query: activeQuery.isEmpty ? "all" : activeQuery,
        category: activeCat,
        lat: _lat,
        lng: _lng,
      );
      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  String _getCategoryTitle() {
    if (_searchController.text.isNotEmpty) {
      return "Search: '\${_searchController.text}'";
    }
    final match = _categories.firstWhere(
      (c) => c['id'] == _selectedCategory,
      orElse: () => {"name": "Products"},
    );
    return match['name'] ?? "Products";
  }

  @override
  Widget build(BuildContext context) {
    final int cartCount = _cartService.totalItemCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sync_alt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SmartPrice",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Blinkit vs Zepto Real-time Comparison",
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF0F172A), size: 26),
                onPressed: _openCartScreen,
              ),
              if (cartCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      "\$cartCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  LocationBar(
                    areaName: _areaName,
                    fullAddress: _fullAddress,
                    eta: _eta,
                    isDetectingGps: _isDetectingGps,
                    onDetectGps: _detectGpsLocation,
                    onSelectCity: _onCitySelected,
                    onSaveCustomAddress: _onCustomLocationSaved,
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x6616A34A),
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "LIVE RADAR: Blinkit #BLR-12 • Zepto #ZPT-08",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF166534),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _isRefreshing ? null : _handleManualLiveRefresh,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              children: [
                                _isRefreshing
                                    ? const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: Color(0xFF15803D),
                                        ),
                                      )
                                    : const Icon(Icons.refresh, size: 13, color: Color(0xFF15803D)),
                                const SizedBox(width: 3),
                                const Text(
                                  "Live Refresh",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) => _executeSearch(query: val),
                    onChanged: (val) {
                      setState(() {});
                      if (val.isEmpty) {
                        _executeSearch(query: "", category: _selectedCategory);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Search milk, chips, atta, oil, coke, paneer...",
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF94A3B8), size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _executeSearch(query: "", category: _selectedCategory);
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_forward, color: Color(0xFF4F46E5)),
                              onPressed: () => _executeSearch(),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat['id'];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _searchController.clear();
                            _executeSearch(query: "", category: cat['id']);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: isSelected
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x404F46E5),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat['icon'] ?? '', style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  cat['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\${_getCategoryTitle()} (\${_products.length})",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("⚡", style: TextStyle(fontSize: 11)),
                        SizedBox(width: 4),
                        Text(
                          "Live Price Check",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF4F46E5)),
                          SizedBox(height: 12),
                          Text(
                            "Comparing prices across Blinkit & Zepto...",
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _executeSearch(),
                                  child: const Text("Retry", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "No products found",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Try selecting '🔥 All Products' or another category.",
                                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _executeSearch(query: "", category: "all");
                                    },
                                    child: const Text("Show All Products", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: _products[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cartCount > 0
          ? InkWell(
              onTap: _openCartScreen,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  boxShadow: [
                    BoxShadow(color: Color(0x3310B981), blurRadius: 10, offset: Offset(0, -3)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_basket, color: Color(0xFF047857), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "\$cartCount Item(s) • ₹\${_cartService.totalAmount.toStringAsFixed(1)}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          Text(
                            "Save ₹\${_cartService.totalSavings.toStringAsFixed(1)} with Split Basket",
                            style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _openCartScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF047857),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        children: [
                          Text("View Basket", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF4F46E5), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SmartPrice Live Optimizer",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          "Comparing 124+ live items across Dark Stores",
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Text(
                      "Save up to ₹180",
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
