import 'dart:async';
import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationBar extends StatelessWidget {
  final String areaName;
  final String fullAddress;
  final String eta;
  final bool isDetectingGps;
  final VoidCallback onDetectGps;
  final Function(CityPreset) onSelectCity;
  final Function(LocationResult)? onSaveCustomAddress;

  const LocationBar({
    super.key,
    required this.areaName,
    required this.fullAddress,
    this.eta = "9-12 MINS",
    this.isDetectingGps = false,
    required this.onDetectGps,
    required this.onSelectCity,
    this.onSaveCustomAddress,
  });

  void _showChangeLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _ChangeDeliveryLocationSheet(
          currentAreaName: areaName,
          currentFullAddress: fullAddress,
          onDetectGps: () {
            Navigator.pop(ctx);
            onDetectGps();
          },
          onSelectCity: (city) {
            Navigator.pop(ctx);
            onSelectCity(city);
          },
          onSaveCustomAddress: (customLoc) {
            Navigator.pop(ctx);
            onSaveCustomAddress?.call(customLoc);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            "Your Location",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Purple/Blue Location Pin Icon (Matches Screenshot 2)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF4F46E5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Full Address Details
              Expanded(
                child: InkWell(
                  onTap: () => _showChangeLocationSheet(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        areaName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fullAddress,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // CHANGE Button (Matches Screenshot 2)
              TextButton(
                onPressed: () => _showChangeLocationSheet(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "CHANGE",
                  style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Combined Bottom Sheet Supporting:
// 1. "Change Delivery Location" (Shows ONLY Saved Addresses)
// 2. "Add New Address" (Adds to Saved Addresses List)
// ---------------------------------------------------------------------------
class _ChangeDeliveryLocationSheet extends StatefulWidget {
  final String currentAreaName;
  final String currentFullAddress;
  final VoidCallback onDetectGps;
  final Function(CityPreset) onSelectCity;
  final Function(LocationResult) onSaveCustomAddress;

  const _ChangeDeliveryLocationSheet({
    required this.currentAreaName,
    required this.currentFullAddress,
    required this.onDetectGps,
    required this.onSelectCity,
    required this.onSaveCustomAddress,
  });

  @override
  State<_ChangeDeliveryLocationSheet> createState() => _ChangeDeliveryLocationSheetState();
}

class _ChangeDeliveryLocationSheetState extends State<_ChangeDeliveryLocationSheet> {
  bool _isAddingNewAddress = false;

  // Search screen controllers
  final TextEditingController _searchController = TextEditingController();
  List<SavedAddressItem> _savedAddresses = [];
  List<CityPreset> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Add new address screen controllers
  final TextEditingController _searchAddressController = TextEditingController();
  final TextEditingController _completeAddressController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  String _selectedTag = "Other"; // Home, Office, Other
  bool _isSearchingNew = false;
  List<CityPreset> _onlineSuggestions = [];
  Timer? _debounceTimerNew;

  @override
  void initState() {
    super.initState();
    _completeAddressController.text = widget.currentFullAddress;
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final list = await LocationService.getSavedAddresses();
    if (mounted) {
      setState(() {
        _savedAddresses = list;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimerNew?.cancel();
    _searchController.dispose();
    _searchAddressController.dispose();
    _completeAddressController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().length >= 2) {
      setState(() => _isSearching = true);
      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        final results = await LocationService.searchOnlineLocations(value);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      });
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _onSearchAddressNew(String query) {
    _debounceTimerNew?.cancel();
    if (query.trim().length >= 2) {
      setState(() => _isSearchingNew = true);
      _debounceTimerNew = Timer(const Duration(milliseconds: 300), () async {
        final results = await LocationService.searchOnlineLocations(query);
        if (mounted) {
          setState(() {
            _onlineSuggestions = results;
            _isSearchingNew = false;
          });
        }
      });
    } else {
      setState(() {
        _onlineSuggestions = [];
        _isSearchingNew = false;
      });
    }
  }

  void _selectSuggestion(CityPreset preset) {
    setState(() {
      _completeAddressController.text = preset.fullAddress;
      _searchAddressController.text = preset.areaName;
      _onlineSuggestions = [];
    });
  }

  Future<void> _saveAddress() async {
    final completeAddr = _completeAddressController.text.trim();
    if (completeAddr.isEmpty) return;

    final label = _labelController.text.trim();
    String areaTitle = "";
    if (label.isNotEmpty) {
      areaTitle = label;
    } else if (_searchAddressController.text.trim().isNotEmpty) {
      areaTitle = _searchAddressController.text.trim();
    } else {
      areaTitle = _selectedTag == "Home"
          ? "Home"
          : (_selectedTag == "Office" ? "Office" : completeAddr.split(',').first.trim());
    }

    // Save to persistent Saved Addresses List
    final savedItem = SavedAddressItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: areaTitle,
      fullAddress: completeAddr,
      tag: _selectedTag,
      pincode: "560067",
      eta: "8-11 MINS",
      lat: 12.9922,
      lng: 77.7290,
    );
    await LocationService.addSavedAddress(savedItem);

    final locResult = LocationResult(
      success: true,
      areaName: areaTitle,
      fullAddress: completeAddr,
      pincode: "560067",
      eta: "8-11 MINS",
      displayName: areaTitle,
      lat: 12.9922,
      lng: 77.7290,
    );

    widget.onSaveCustomAddress(locResult);
  }

  Future<void> _deleteSavedAddress(String id) async {
    await LocationService.removeSavedAddress(id);
    _loadSavedAddresses();
  }

  void _selectSavedAddress(SavedAddressItem item) {
    final preset = CityPreset(
      name: item.title,
      areaName: item.title,
      buildingName: item.title,
      fullAddress: item.fullAddress,
      pincode: item.pincode,
      eta: item.eta,
      lat: item.lat,
      lng: item.lng,
    );
    widget.onSelectCity(preset);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.fromLTRB(18, 14, 18, 16 + bottomInset),
      child: _isAddingNewAddress ? _buildAddNewAddressView() : _buildChangeLocationView(),
    );
  }

  // -------------------------------------------------------------------------
  // View 1: "Change Delivery Location" (Shows ONLY Saved Addresses)
  // -------------------------------------------------------------------------
  Widget _buildChangeLocationView() {
    final bool isSearchingMode = _searchController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Back Button + Title
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Change Delivery Location",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Search Box: "Search by area, street name, pin code"
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search by area, street name, pin code",
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
                      ),
                    )
                  : (_searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged("");
                          },
                        )
                      : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Action Card 1: "Use Current Location" (Matches Screenshot 1)
        InkWell(
          onTap: widget.onDetectGps,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.my_location_rounded, color: Color(0xFF4F46E5), size: 20),
                SizedBox(width: 14),
                Text(
                  "Use Current Location",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Action Card 2: "Add a New Address" (Matches Screenshot 1)
        InkWell(
          onTap: () {
            setState(() {
              _completeAddressController.text = widget.currentFullAddress;
              _isAddingNewAddress = true;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.add_rounded, color: Color(0xFF4F46E5), size: 22),
                SizedBox(width: 14),
                Text(
                  "Add a New Address",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Section Header: "Saved Addresses" (or "Search Results")
        Text(
          isSearchingMode ? "Search Results (${_searchResults.length})" : "Saved Addresses (${_savedAddresses.length})",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),

        // List: Shows ONLY Saved Addresses when search is empty, or search results when searching
        Expanded(
          child: isSearchingMode
              ? _buildSearchResultsList()
              : _buildSavedAddressesList(),
        ),
      ],
    );
  }

  Widget _buildSavedAddressesList() {
    if (_savedAddresses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "No saved addresses yet.\nTap 'Add a New Address' to save one.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _savedAddresses.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final saved = _savedAddresses[index];
        IconData tagIcon = Icons.location_on_outlined;
        if (saved.tag.toLowerCase() == "home") tagIcon = Icons.home_outlined;
        if (saved.tag.toLowerCase() == "office") tagIcon = Icons.apartment_outlined;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: Icon(tagIcon, color: const Color(0xFF4F46E5), size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  saved.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  saved.tag,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              saved.fullAddress,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF94A3B8), size: 20),
            onPressed: () => _deleteSavedAddress(saved.id),
          ),
          onTap: () => _selectSavedAddress(saved),
        );
      },
    );
  }

  Widget _buildSearchResultsList() {
    if (_searchResults.isEmpty && !_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "No locations found. Try searching by street or landmark.",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_pin, color: Color(0xFF4F46E5), size: 18),
          ),
          title: Text(
            city.buildingName.isNotEmpty ? city.buildingName : city.areaName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              city.fullAddress,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 18),
          onTap: () => widget.onSelectCity(city),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // View 2: "Add New Address" (Matches Screenshot 3)
  // -------------------------------------------------------------------------
  Widget _buildAddNewAddressView() {
    final bool isSaveActive = _completeAddressController.text.trim().isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Close icon + "Add New Address"
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Color(0xFF0F172A)),
                onPressed: () {
                  setState(() => _isAddingNewAddress = false);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const Text(
                "Add New Address",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // "Use current location" Action Card (Matches Screenshot 3)
          InkWell(
            onTap: widget.onDetectGps,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.my_location_rounded, color: Color(0xFF4F46E5), size: 20),
                  SizedBox(width: 14),
                  Text(
                    "Use current location",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section: "Address Details"
          const Text(
            "Address Details",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Search Address Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchAddressController,
              onChanged: _onSearchAddressNew,
              decoration: InputDecoration(
                hintText: "Search address",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF4F46E5), size: 20),
                suffixIcon: _isSearchingNew
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          // Online Search Suggestions Dropdown
          if (_onlineSuggestions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: _onlineSuggestions.take(4).map((p) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.pin_drop_rounded, color: Color(0xFF4F46E5), size: 18),
                    title: Text(p.areaName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    subtitle: Text(p.fullAddress, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1),
                    onTap: () => _selectSuggestion(p),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Enter Complete Address Field (Multiline)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _completeAddressController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "Enter complete address",
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 35),
                  child: Icon(Icons.apartment_rounded, color: Color(0xFF4F46E5), size: 20),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Section: "Saved Address as"
          const Text(
            "Saved Address as",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 3 Segmented Tags: Home, Office, Other (Matches Screenshot 3)
          Row(
            children: [
              _buildTagChip("Home", Icons.home_outlined),
              const SizedBox(width: 10),
              _buildTagChip("Office", Icons.apartment_outlined),
              const SizedBox(width: 10),
              _buildTagChip("Other", Icons.location_on_outlined),
            ],
          ),
          const SizedBox(height: 10),

          // Add Label Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: "Add label",
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Full-Width "Save Address" Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSaveActive ? _saveAddress : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaveActive ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                foregroundColor: isSaveActive ? Colors.white : const Color(0xFF94A3B8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save Address",
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, IconData icon) {
    final isSelected = _selectedTag == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTag = label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
