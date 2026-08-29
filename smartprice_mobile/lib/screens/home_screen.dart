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

  String _areaName = "Indiranagar 100ft Road";
  String _fullAddress = "100ft Road, HAL 2nd Stage, Indiranagar, Bengaluru 560038";
  String _eta = "8-11 MINS";
  double _lat = 12.9784;
  double _lng = 77.6408;

  bool _isDetectingGps = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<ProductComparison> _products = [];

  @override
  void initState() {
    super.initState();
    _searchController.text = "milk";
    _executeSearch("milk");
    // Instant restore from local SharedPreferences cache + prompt/detect live GPS
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
      _executeSearch(_searchController.text);
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
      if (_searchController.text.isNotEmpty) {
        _executeSearch(_searchController.text);
      }
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
          content: Text("📍 Pinpoint locked: ${result.areaName}"),
          backgroundColor: const Color(0xFF1E293B),
          duration: const Duration(seconds: 2),
        ),
      );
      if (_searchController.text.isNotEmpty) {
        _executeSearch(_searchController.text);
      }
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("📍 Delivery area set to ${city.areaName}"),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
      ),
    );

    if (_searchController.text.isNotEmpty) {
      _executeSearch(_searchController.text);
    }
  }

  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.compareProducts(
        query: query.trim(),
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

  void _saveCustomAddress(LocationResult customLoc) {
    setState(() {
      _areaName = customLoc.areaName;
      _fullAddress = customLoc.fullAddress;
      _eta = customLoc.eta;
      _lat = customLoc.lat;
      _lng = customLoc.lng;
    });

    LocationService.saveLocation(customLoc);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("📍 Doorstep address set: ${customLoc.areaName}"),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
      ),
    );

    if (_searchController.text.isNotEmpty) {
      _executeSearch(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
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
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "POC Beta",
                style: TextStyle(
                  color: Color(0xFF3730A3),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Zepto-Style Location Bar with ETA, Area, and Complete Full Address
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

              // Search Bar
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _executeSearch,
                decoration: InputDecoration(
                  hintText: "Search item (e.g. Milk, Egg, Coke, Bread)...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF2563EB)),
                    onPressed: () => _executeSearch(_searchController.text),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Quick Tag Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["Milk", "Eggs", "Coke", "Butter", "Bread", "Atta"].map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(tag),
                        labelStyle: const TextStyle(fontSize: 12),
                        backgroundColor: Colors.grey.shade100,
                        onPressed: () {
                          _searchController.text = tag;
                          _executeSearch(tag);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // Results Section
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text("Comparing prices on Blinkit & Zepto..."),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => _executeSearch(_searchController.text),
                                    child: const Text("Retry"),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _products.isEmpty
                            ? const Center(child: Text("No items found. Try searching another product."))
                            : ListView.builder(
                                itemCount: _products.length,
                                itemBuilder: (ctx, idx) {
                                  return ProductCard(product: _products[idx]);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
