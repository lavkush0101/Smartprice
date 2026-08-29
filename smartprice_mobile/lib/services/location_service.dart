import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SavedAddressItem {
  final String id;
  final String title;
  final String fullAddress;
  final String tag; // "Home", "Office", "Other", or custom label
  final String pincode;
  final String eta;
  final double lat;
  final double lng;

  const SavedAddressItem({
    required this.id,
    required this.title,
    required this.fullAddress,
    this.tag = "Home",
    this.pincode = "560067",
    this.eta = "8-11 MINS",
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'fullAddress': fullAddress,
        'tag': tag,
        'pincode': pincode,
        'eta': eta,
        'lat': lat,
        'lng': lng,
      };

  factory SavedAddressItem.fromJson(Map<String, dynamic> json) => SavedAddressItem(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? 'Saved Location',
        fullAddress: json['fullAddress'] ?? '',
        tag: json['tag'] ?? 'Home',
        pincode: json['pincode'] ?? '560067',
        eta: json['eta'] ?? '8-11 MINS',
        lat: (json['lat'] as num?)?.toDouble() ?? 12.9922,
        lng: (json['lng'] as num?)?.toDouble() ?? 77.7290,
      );
}

class CityPreset {
  final String name;
  final String areaName;
  final String buildingName;
  final String fullAddress;
  final String pincode;
  final String eta;
  final double lat;
  final double lng;

  const CityPreset({
    required this.name,
    required this.areaName,
    this.buildingName = "",
    required this.fullAddress,
    required this.pincode,
    this.eta = "9-12 MINS",
    required this.lat,
    required this.lng,
  });
}

class LocationResult {
  final bool success;
  final Position? position;
  final String? errorMessage;
  final String areaName;
  final String buildingName;
  final String flatNumber;
  final String landmark;
  final String fullAddress;
  final String pincode;
  final String eta;
  final String displayName;
  final double lat;
  final double lng;

  const LocationResult({
    required this.success,
    this.position,
    this.errorMessage,
    required this.areaName,
    this.buildingName = "",
    this.flatNumber = "",
    this.landmark = "",
    required this.fullAddress,
    this.pincode = "560038",
    this.eta = "9-12 MINS",
    required this.displayName,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
        'areaName': areaName,
        'buildingName': buildingName,
        'flatNumber': flatNumber,
        'landmark': landmark,
        'fullAddress': fullAddress,
        'pincode': pincode,
        'eta': eta,
        'displayName': displayName,
        'lat': lat,
        'lng': lng,
      };
}

class LocationService {
  static const String _prefKeyArea = "sp_saved_area";
  static const String _prefKeyBuilding = "sp_saved_building";
  static const String _prefKeyFlat = "sp_saved_flat";
  static const String _prefKeyLandmark = "sp_saved_landmark";
  static const String _prefKeyAddress = "sp_saved_address";
  static const String _prefKeyPincode = "sp_saved_pincode";
  static const String _prefKeyEta = "sp_saved_eta";
  static const String _prefKeyLat = "sp_saved_lat";
  static const String _prefKeyLng = "sp_saved_lng";

  static const List<CityPreset> popularCities = [
    // Bangalore
    CityPreset(
      name: "Bangalore (Indiranagar)",
      areaName: "Indiranagar 100ft Road",
      buildingName: "Prestige Meridian / HAL 2nd Stage",
      fullAddress: "Flat 402, Prestige Meridian, 100ft Road, HAL 2nd Stage, Indiranagar, Bengaluru, Karnataka 560038",
      pincode: "560038",
      eta: "8-11 MINS",
      lat: 12.9784,
      lng: 77.6408,
    ),
    CityPreset(
      name: "Bangalore (Koramangala)",
      areaName: "Koramangala 4th Block",
      buildingName: "Raheja Residency / 80 Feet Road",
      fullAddress: "Tower 2, Raheja Residency, 80 Feet Rd, 4th Block, Koramangala, Bengaluru, Karnataka 560034",
      pincode: "560034",
      eta: "9-12 MINS",
      lat: 12.9352,
      lng: 77.6245,
    ),
    CityPreset(
      name: "Bangalore (HSR Layout)",
      areaName: "HSR Layout Sector 2",
      buildingName: "Purva Vantage, Sector 2",
      fullAddress: "Flat 301, Purva Vantage, 27th Main Rd, Sector 2, HSR Layout, Bengaluru, Karnataka 560102",
      pincode: "560102",
      eta: "9-11 MINS",
      lat: 12.9121,
      lng: 77.6446,
    ),
    CityPreset(
      name: "Bangalore (Whitefield)",
      areaName: "Whitefield ITPL",
      buildingName: "Prestige Shantiniketan Tower 8",
      fullAddress: "Tower 8, Prestige Shantiniketan, ITPL Main Rd, Whitefield, Bengaluru 560066",
      pincode: "560066",
      eta: "10-14 MINS",
      lat: 12.9698,
      lng: 77.7499,
    ),
    CityPreset(
      name: "Bangalore (Jayanagar)",
      areaName: "Jayanagar 4th Block",
      buildingName: "Brigade Millennium Complex",
      fullAddress: "Block C, 11th Main Rd, 4th Block, Jayanagar, Bengaluru, Karnataka 560011",
      pincode: "560011",
      eta: "8-11 MINS",
      lat: 12.9308,
      lng: 77.5838,
    ),

    // Delhi NCR
    CityPreset(
      name: "Delhi NCR (Gurugram)",
      areaName: "DLF Cyber City",
      buildingName: "Building 10, DLF Cyber City",
      fullAddress: "Tower B, Building 10, DLF Cyber City, Phase 2, Gurugram, Haryana 122002",
      pincode: "122002",
      eta: "10-13 MINS",
      lat: 28.4595,
      lng: 77.0266,
    ),
    CityPreset(
      name: "Delhi (Connaught Place)",
      areaName: "Connaught Place",
      buildingName: "Statesman House / Inner Circle",
      fullAddress: "Block B, Statesman House, Inner Circle, Connaught Place, New Delhi 110001",
      pincode: "110001",
      eta: "9-12 MINS",
      lat: 28.6315,
      lng: 77.2167,
    ),
    CityPreset(
      name: "Delhi NCR (Noida)",
      areaName: "Noida Sector 18",
      buildingName: "Wave Silver Tower, Sector 18",
      fullAddress: "Atta Market, Wave Silver Tower, Sector 18, Noida, Uttar Pradesh 201301",
      pincode: "201301",
      eta: "10-13 MINS",
      lat: 28.5708,
      lng: 77.3271,
    ),

    // Mumbai
    CityPreset(
      name: "Mumbai (Bandra West)",
      areaName: "Bandra West",
      buildingName: "Galaxy Heights, Hill Road",
      fullAddress: "Flat 502, Galaxy Heights, Hill Road, Bandra West, Mumbai, Maharashtra 400050",
      pincode: "400050",
      eta: "8-11 MINS",
      lat: 19.0596,
      lng: 72.8295,
    ),
    CityPreset(
      name: "Mumbai (Powai)",
      areaName: "Powai Hiranandani",
      buildingName: "Somerset Heritage Tower, Hiranandani",
      fullAddress: "Tower 3, Central Avenue, Hiranandani Gardens, Powai, Mumbai 400076",
      pincode: "400076",
      eta: "9-12 MINS",
      lat: 19.1176,
      lng: 72.9060,
    ),
    CityPreset(
      name: "Mumbai (Andheri East)",
      areaName: "Andheri East",
      buildingName: "Solitaire Corporate Park",
      fullAddress: "Building 5, Chakala, Andheri-Kurla Rd, Andheri East, Mumbai 400093",
      pincode: "400093",
      eta: "9-12 MINS",
      lat: 19.1136,
      lng: 72.8697,
    ),

    // Hyderabad
    CityPreset(
      name: "Hyderabad (Hitec City)",
      areaName: "Hitec City Madhapur",
      buildingName: "Cyber Towers Building 3",
      fullAddress: "Floor 4, Cyber Towers, Hitec City, Madhapur, Hyderabad, Telangana 500081",
      pincode: "500081",
      eta: "9-12 MINS",
      lat: 17.4474,
      lng: 78.3762,
    ),
    CityPreset(
      name: "Hyderabad (Gachibowli)",
      areaName: "Gachibowli Financial Dist",
      buildingName: "WaveRock SEZ Tower 2",
      fullAddress: "Financial District, Nanakramguda, Gachibowli, Hyderabad 500032",
      pincode: "500032",
      eta: "10-13 MINS",
      lat: 17.4401,
      lng: 78.3489,
    ),

    // Pune
    CityPreset(
      name: "Pune (Kothrud)",
      areaName: "Kothrud Paud Road",
      buildingName: "Mayur Residency, Ideal Colony",
      fullAddress: "Flat 204, Mayur Residency, Paud Road, Ideal Colony, Kothrud, Pune 411038",
      pincode: "411038",
      eta: "9-12 MINS",
      lat: 18.5074,
      lng: 73.8077,
    ),
    CityPreset(
      name: "Pune (Viman Nagar)",
      areaName: "Viman Nagar",
      buildingName: "Sky Vista Complex",
      fullAddress: "Tower A, Symbiosis Rd, Viman Nagar, Pune, Maharashtra 411014",
      pincode: "411014",
      eta: "9-12 MINS",
      lat: 18.5679,
      lng: 73.9143,
    ),

    // Chennai
    CityPreset(
      name: "Chennai (T. Nagar)",
      areaName: "T. Nagar Usman Road",
      buildingName: "Ramee Mall / Usman Road",
      fullAddress: "Shop 12, Usman Road, T. Nagar, Chennai, Tamil Nadu 600017",
      pincode: "600017",
      eta: "9-12 MINS",
      lat: 13.0418,
      lng: 80.2341,
    ),

    // Kolkata
    CityPreset(
      name: "Kolkata (Salt Lake)",
      areaName: "Salt Lake Sector V",
      buildingName: "Godrej Genesis Tower, Sector V",
      fullAddress: "Tower 1, Sector V, Bidhannagar, Salt Lake City, Kolkata, West Bengal 700091",
      pincode: "700091",
      eta: "10-13 MINS",
      lat: 22.5804,
      lng: 88.4378,
    ),
  ];

  static const String _prefKeySavedAddressesList = "sp_saved_addresses_list";

  /// Returns user's saved addresses list
  static Future<List<SavedAddressItem>> getSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_prefKeySavedAddressesList);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> list = json.decode(jsonString);
        return list.map((item) => SavedAddressItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint("Error reading saved addresses: $e");
    }

    // Default seeded saved location if none exists
    return [
      const SavedAddressItem(
        id: "1",
        title: "18 1st main road 3rd cross",
        fullAddress: "18 1st main road 3rd cross, Sapthagiri Layout Rd, phase 2, Chansandra, Bengaluru 560067",
        tag: "Home",
        pincode: "560067",
        eta: "8-11 MINS",
        lat: 12.9922,
        lng: 77.7290,
      ),
    ];
  }

  /// Adds or updates a saved address in local storage
  static Future<void> addSavedAddress(SavedAddressItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getSavedAddresses();
      
      // Filter out duplicate if same fullAddress or ID
      final updatedList = currentList.where((a) => a.id != item.id && a.fullAddress != item.fullAddress).toList();
      updatedList.insert(0, item); // Insert at top

      final encoded = json.encode(updatedList.map((a) => a.toJson()).toList());
      await prefs.setString(_prefKeySavedAddressesList, encoded);
    } catch (e) {
      debugPrint("Error saving address to list: $e");
    }
  }

  /// Removes a saved address by ID
  static Future<void> removeSavedAddress(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getSavedAddresses();
      final updatedList = currentList.where((a) => a.id != id).toList();
      final encoded = json.encode(updatedList.map((a) => a.toJson()).toList());
      await prefs.setString(_prefKeySavedAddressesList, encoded);
    } catch (e) {
      debugPrint("Error removing saved address: $e");
    }
  }

  /// Persists the active location and building-level details locally
  static Future<void> saveLocation(LocationResult location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyArea, location.areaName);
      await prefs.setString(_prefKeyBuilding, location.buildingName);
      await prefs.setString(_prefKeyFlat, location.flatNumber);
      await prefs.setString(_prefKeyLandmark, location.landmark);
      await prefs.setString(_prefKeyAddress, location.fullAddress);
      await prefs.setString(_prefKeyPincode, location.pincode);
      await prefs.setString(_prefKeyEta, location.eta);
      await prefs.setDouble(_prefKeyLat, location.lat);
      await prefs.setDouble(_prefKeyLng, location.lng);
    } catch (e) {
      debugPrint("Failed to save location in SharedPreferences: $e");
    }
  }

  /// Retrieves previously saved location in 0 milliseconds
  static Future<LocationResult?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final area = prefs.getString(_prefKeyArea);
      final address = prefs.getString(_prefKeyAddress);
      final lat = prefs.getDouble(_prefKeyLat);
      final lng = prefs.getDouble(_prefKeyLng);

      if (area != null && address != null && lat != null && lng != null) {
        final building = prefs.getString(_prefKeyBuilding) ?? "";
        final flat = prefs.getString(_prefKeyFlat) ?? "";
        final landmark = prefs.getString(_prefKeyLandmark) ?? "";
        final pincode = prefs.getString(_prefKeyPincode) ?? "560038";
        final eta = prefs.getString(_prefKeyEta) ?? "9-12 MINS";
        return LocationResult(
          success: true,
          areaName: area,
          buildingName: building,
          flatNumber: flat,
          landmark: landmark,
          fullAddress: address,
          pincode: pincode,
          eta: eta,
          displayName: area,
          lat: lat,
          lng: lng,
        );
      }
    } catch (e) {
      debugPrint("Failed to read saved location: $e");
    }
    return null;
  }

  /// Fetches real-time pinpoint location using OpenStreetMap + GPS + IP Failover
  static Future<LocationResult> fetchCurrentLocation() async {
    Position? position;

    if (!kIsWeb) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          try {
            position = await Geolocator.getLastKnownPosition();
          } catch (_) {}
          try {
            final livePos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 4),
            );
            position = livePos;
          } catch (_) {}
        }
      } catch (e) {
        debugPrint("Device GPS check exception: $e");
      }
    } else {
      // Flutter Web: safely query browser geolocation without getLastKnownPosition
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final livePos = await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 4),
          );
          position = livePos;
        }
      } catch (e) {
        debugPrint("Web GPS check exception: $e");
      }
    }

    // 1. High-precision Reverse Geocoding down to building/apartment level
    if (position != null &&
        position.latitude >= 8.0 &&
        position.latitude <= 37.5 &&
        position.longitude >= 68.0 &&
        position.longitude <= 97.5) {
      final result = await reverseGeocodeCoordinates(position.latitude, position.longitude);
      if (result != null) {
        await saveLocation(result);
        return result;
      }
    }

    // 2. IP Geolocation failover for emulator / web / indoor without GPS lock
    final ipLocation = await ApiService().detectLiveLocation();
    if (ipLocation != null && ipLocation["status"] == "success") {
      final double lat = (ipLocation["lat"] as num).toDouble();
      final double lng = (ipLocation["lng"] as num).toDouble();
      final String areaName = ipLocation["areaName"] ?? "${ipLocation['city']} Central";
      final String buildingName = ipLocation["buildingName"] ?? "";
      final String fullAddress = ipLocation["fullAddress"] ?? "${ipLocation['city']}, ${ipLocation['region']}";
      final String eta = ipLocation["eta"] ?? "9-12 MINS";
      final String pincode = ipLocation["pincode"] ?? "560001";

      final result = LocationResult(
        success: true,
        areaName: areaName,
        buildingName: buildingName,
        fullAddress: fullAddress,
        pincode: pincode,
        eta: eta,
        displayName: "$areaName (Live Location)",
        lat: lat,
        lng: lng,
      );
      await saveLocation(result);
      return result;
    }

    // 3. Saved or Default Fallback
    final saved = await getSavedLocation();
    if (saved != null) return saved;

    final defaultPreset = popularCities.first;
    return LocationResult(
      success: true,
      areaName: defaultPreset.areaName,
      buildingName: defaultPreset.buildingName,
      fullAddress: defaultPreset.fullAddress,
      pincode: defaultPreset.pincode,
      eta: defaultPreset.eta,
      displayName: defaultPreset.name,
      lat: defaultPreset.lat,
      lng: defaultPreset.lng,
    );
  }

  /// High-precision reverse geocoding down to building/apartment level via OpenStreetMap Nominatim
  static Future<LocationResult?> reverseGeocodeCoordinates(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'SmartPriceQuickCommerce/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Extract specific building/complex/house details ("building tak")
          final String building = address['building'] ??
              address['apartments'] ??
              address['residential'] ??
              address['commercial'] ??
              address['office'] ??
              address['amenity'] ??
              address['house_name'] ??
              '';
          final String houseNumber = address['house_number'] ?? '';
          final String road = address['road'] ?? address['pedestrian'] ?? address['footway'] ?? '';
          final String neighbourhood = address['neighbourhood'] ?? address['suburb'] ?? address['residential'] ?? '';
          final String city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? 'Bengaluru';
          final String state = address['state'] ?? 'Karnataka';
          final String postcode = address['postcode'] ?? '560038';

          String areaTitle = '';
          if (building.isNotEmpty) {
            areaTitle = building;
          } else if (road.isNotEmpty && neighbourhood.isNotEmpty) {
            areaTitle = '$road, $neighbourhood';
          } else if (neighbourhood.isNotEmpty) {
            areaTitle = '$neighbourhood, $city';
          } else if (road.isNotEmpty) {
            areaTitle = '$road, $city';
          } else {
            areaTitle = city;
          }

          final addressParts = [
            if (houseNumber.isNotEmpty) 'House No. $houseNumber',
            if (building.isNotEmpty) building,
            if (road.isNotEmpty) road,
            if (neighbourhood.isNotEmpty && neighbourhood != road) neighbourhood,
            if (city.isNotEmpty) city,
            if (state.isNotEmpty) state,
            if (postcode.isNotEmpty) postcode,
          ];
          final String fullAddress = addressParts.join(', ');

          return LocationResult(
            success: true,
            areaName: areaTitle,
            buildingName: building,
            flatNumber: houseNumber,
            fullAddress: fullAddress,
            pincode: postcode,
            eta: '8-11 MINS',
            displayName: '$areaTitle (Live GPS)',
            lat: lat,
            lng: lng,
          );
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e, falling back to closest dark store hub');
    }

    // Fallback: Check against closest dark store hub
    final closest = _findClosestPreset(lat, lng);
    if (closest != null) {
      return LocationResult(
        success: true,
        areaName: closest.areaName,
        buildingName: closest.buildingName,
        fullAddress: closest.fullAddress,
        pincode: closest.pincode,
        eta: closest.eta,
        displayName: "${closest.areaName} (Live GPS)",
        lat: lat,
        lng: lng,
      );
    }

    return LocationResult(
      success: true,
      areaName: "Live GPS Pinpoint",
      buildingName: "Doorstep Delivery Point",
      fullAddress: "Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)} (Live GPS)",
      pincode: "Local Area",
      eta: "9-12 MINS",
      displayName: "Live GPS (${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})",
      lat: lat,
      lng: lng,
    );
  }

  static CityPreset? _findClosestPreset(double lat, double lng) {
    double minDistance = double.infinity;
    CityPreset? closest;

    for (final city in popularCities) {
      final distance = Geolocator.distanceBetween(lat, lng, city.lat, city.lng);
      if (distance < minDistance) {
        minDistance = distance;
        closest = city;
      }
    }

    if (closest != null && minDistance <= 30000) {
      return closest;
    }
    return null;
  }

  static List<CityPreset> searchLocations(String query) {
    if (query.trim().isEmpty) return popularCities;
    final q = query.toLowerCase().trim();
    return popularCities.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.areaName.toLowerCase().contains(q) ||
          c.buildingName.toLowerCase().contains(q) ||
          c.fullAddress.toLowerCase().contains(q) ||
          c.pincode.contains(q);
    }).toList();
  }

  /// Live ultra-high precision search across OpenStreetMap / Photon for ANY building, society, or street in India
  static Future<List<CityPreset>> searchOnlineLocations(String query, {double? userLat, double? userLng}) async {
    final localMatches = searchLocations(query);
    if (query.trim().length < 2) return localMatches;

    try {
      final encoded = Uri.encodeComponent(query.trim());
      final double searchLat = userLat ?? 12.9784;
      final double searchLng = userLng ?? 77.6408;
      final String url = 'https://photon.komoot.io/api/?q=$encoded&limit=12&lat=$searchLat&lon=$searchLng&bbox=68.0,8.0,97.5,37.5';

      final resp = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'SmartPriceQuickCommerce/1.0'},
      ).timeout(const Duration(seconds: 3));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final features = data['features'] as List<dynamic>?;
        if (features != null && features.isNotEmpty) {
          final List<CityPreset> onlineResults = [];

          for (final f in features) {
            final props = f['properties'] as Map<String, dynamic>? ?? {};
            final geom = f['geometry'] as Map<String, dynamic>? ?? {};
            final coords = geom['coordinates'] as List<dynamic>? ?? [77.6408, 12.9784];

            final double lng = (coords[0] as num).toDouble();
            final double lat = (coords[1] as num).toDouble();

            // Filter only valid Indian territory coordinates
            final String countryCode = (props['countrycode'] ?? '').toString().toUpperCase();
            final bool isInsideIndia = lat >= 8.0 && lat <= 37.5 && lng >= 68.0 && lng <= 97.5;
            if (countryCode != 'IN' && !isInsideIndia) continue;

            final String name = props['name'] ?? props['street'] ?? props['locality'] ?? query;
            final String street = props['street'] ?? '';
            final String locality = props['locality'] ?? props['district'] ?? '';
            final String city = props['city'] ?? props['county'] ?? props['state'] ?? 'India';
            final String state = props['state'] ?? '';
            final String postcode = props['postcode'] ?? '';

            final addrParts = [
              name,
              if (street.isNotEmpty && street != name) street,
              if (locality.isNotEmpty && locality != name) locality,
              if (city.isNotEmpty && city != locality) city,
              if (state.isNotEmpty) state,
              if (postcode.isNotEmpty) postcode,
            ];

            onlineResults.add(
              CityPreset(
                name: "$name, $city",
                areaName: name,
                buildingName: name,
                fullAddress: addrParts.join(", "),
                pincode: postcode.isNotEmpty ? postcode : "560001",
                eta: "8-11 MINS",
                lat: lat,
                lng: lng,
              ),
            );
          }

          // Merge: unique by fullAddress
          final Map<String, CityPreset> unique = {};
          for (final c in onlineResults) {
            unique[c.fullAddress] = c;
          }
          for (final c in localMatches) {
            unique[c.fullAddress] = c;
          }
          return unique.values.toList();
        }
      }
    } catch (e) {
      debugPrint("Online location search error: $e");
    }

    return localMatches;
  }
}

