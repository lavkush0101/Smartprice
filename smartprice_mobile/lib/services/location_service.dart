import 'package:geolocator/geolocator.dart';

class CityPreset {
  final String name;
  final String locality;
  final double lat;
  final double lng;

  const CityPreset({
    required this.name,
    required this.locality,
    required this.lat,
    required this.lng,
  });
}

class LocationService {
  static const List<CityPreset> popularCities = [
    // Bangalore
    CityPreset(name: "Bangalore (Indiranagar)", locality: "100ft Road, Indiranagar, Bangalore", lat: 12.9784, lng: 77.6408),
    CityPreset(name: "Bangalore (Koramangala)", locality: "80 Feet Rd, 4th Block, Koramangala, Bangalore", lat: 12.9352, lng: 77.6245),
    CityPreset(name: "Bangalore (HSR Layout)", locality: "Sector 2, HSR Layout, Bangalore", lat: 12.9121, lng: 77.6446),
    CityPreset(name: "Bangalore (Whitefield)", locality: "ITPL Main Rd, Whitefield, Bangalore", lat: 12.9698, lng: 77.7499),
    CityPreset(name: "Bangalore (Jayanagar)", locality: "4th Block, Jayanagar, Bangalore", lat: 12.9308, lng: 77.5838),

    // Delhi NCR
    CityPreset(name: "Delhi NCR (Gurugram)", locality: "DLF Cyber City, Phase 2, Gurugram", lat: 28.4595, lng: 77.0266),
    CityPreset(name: "Delhi (Connaught Place)", locality: "Inner Circle, CP, New Delhi", lat: 28.6315, lng: 77.2167),
    CityPreset(name: "Delhi NCR (Noida)", locality: "Sector 18, Noida, Uttar Pradesh", lat: 28.5708, lng: 77.3271),
    CityPreset(name: "Delhi (South Extension)", locality: "South Extension I, New Delhi", lat: 28.5727, lng: 77.2215),

    // Mumbai
    CityPreset(name: "Mumbai (Bandra West)", locality: "Hill Road, Bandra West, Mumbai", lat: 19.0596, lng: 72.8295),
    CityPreset(name: "Mumbai (Andheri East)", locality: "Chakala, Andheri East, Mumbai", lat: 19.1136, lng: 72.8697),
    CityPreset(name: "Mumbai (Powai)", locality: "Hiranandani Gardens, Powai, Mumbai", lat: 19.1176, lng: 72.9060),
    CityPreset(name: "Mumbai (Lower Parel)", locality: "Senapati Bapat Marg, Lower Parel, Mumbai", lat: 18.9953, lng: 72.8292),

    // Hyderabad
    CityPreset(name: "Hyderabad (Hitec City)", locality: "Madhapur, Hitec City, Hyderabad", lat: 17.4474, lng: 78.3762),
    CityPreset(name: "Hyderabad (Gachibowli)", locality: "Financial District, Gachibowli, Hyderabad", lat: 17.4401, lng: 78.3489),
    CityPreset(name: "Hyderabad (Banjara Hills)", locality: "Road No. 12, Banjara Hills, Hyderabad", lat: 17.4156, lng: 78.4357),

    // Pune
    CityPreset(name: "Pune (Kothrud)", locality: "Paud Road, Kothrud, Pune", lat: 18.5074, lng: 73.8077),
    CityPreset(name: "Pune (Viman Nagar)", locality: "Symbiosis Rd, Viman Nagar, Pune", lat: 18.5679, lng: 73.9143),
    CityPreset(name: "Pune (Hinjewadi)", locality: "Phase 1, Hinjewadi Rajiv Gandhi Infotech Park, Pune", lat: 18.5913, lng: 73.7389),

    // Chennai
    CityPreset(name: "Chennai (T. Nagar)", locality: "Usman Road, T. Nagar, Chennai", lat: 13.0418, lng: 80.2341),
    CityPreset(name: "Chennai (Adyar)", locality: "LB Road, Adyar, Chennai", lat: 13.0012, lng: 80.2565),

    // Kolkata
    CityPreset(name: "Kolkata (Salt Lake)", locality: "Sector V, Salt Lake City, Kolkata", lat: 22.5804, lng: 88.4378),
    CityPreset(name: "Kolkata (Park Street)", locality: "Mother Teresa Sarani, Park Street, Kolkata", lat: 22.5513, lng: 88.3526),
  ];

  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }

  static List<CityPreset> searchLocations(String query) {
    if (query.trim().isEmpty) return popularCities;
    final q = query.toLowerCase().trim();
    return popularCities.where((c) {
      return c.name.toLowerCase().contains(q) || c.locality.toLowerCase().contains(q);
    }).toList();
  }
}
