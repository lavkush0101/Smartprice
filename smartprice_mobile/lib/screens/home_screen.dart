import 'package:flutter/material.dart';
import '../models/product_comparison.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../widgets/location_bar.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

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
    // Default to showing all products across all categories
    _executeSearch(query: "", category: "all");
    _restoreSavedLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestLocationOnStartup();
    });
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("📍 Doorstep address locked: ${result.areaName}"),
          backgroundColor: const Color(0xFF1E293B),
          duration: const Duration(seconds: 2),
        ),
      );
      _executeSearch(query: _searchController.text, category: _selectedCategory);
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? "Could not retrieve GPS. Please check permissions."),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _selectCity(CityPreset city) {
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
      pincode: city.pincode,
      eta: city.eta,
      displayName: city.name,
      lat: city.lat,
      lng: city.lng,
    ));

    _executeSearch(query: _searchController.text, category: _selectedCategory);
  }

  void _saveCustomAddress(LocationResult customLoc) {
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
    final effectiveQuery = (query ?? _searchController.text).trim();
    final effectiveCategory = category ?? _selectedCategory;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedCategory = effectiveCategory;
    });

    try {
      final results = await _apiService.compareProducts(
        query: effectiveQuery.isEmpty ? "all" : effectiveQuery,
        category: effectiveCategory,
        lat: _lat,
        lng: _lng,
      );
      if (!mounted) return;
      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  String _getCategoryTitle() {
    if (_searchController.text.trim().isNotEmpty) {
      return "Search: \"${_searchController.text.trim()}\"";
    }
    final catObj = _categories.firstWhere(
      (c) => c['id'] == _selectedCategory,
      orElse: () => {"name": "All Products", "icon": "🔥"},
    );
    return "${catObj['icon']} ${catObj['name']}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.compare_arrows, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              "SmartPrice",
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 18),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Text(
                "POC Beta",
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section (Location + Search + Categories)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  // Zepto/Blinkit Doorstep Location Header
                  LocationBar(
                    areaName: _areaName,
                    fullAddress: _fullAddress,
                    eta: _eta,
                    isDetectingGps: _isDetectingGps,
                    onDetectGps: _detectGpsLocation,
                    onSelectCity: _selectCity,
                    onSaveCustomAddress: _saveCustomAddress,
                  ),
                  const SizedBox(height: 12),

                  // Search Bar with Instant Clear & Submit
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

                  // Category Horizontal Selector
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
                          onTap: () {
                            _executeSearch(query: _searchController.text, category: cat['id']);
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

            // Products Header Counter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_getCategoryTitle()} (${_products.length})",
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

            // Results Section
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
    );
  }
}
