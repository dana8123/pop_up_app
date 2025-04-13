import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PopupStore {
  final String name;
  final String address;
  final String description;
  final String imageUrl;
  final String startDate;
  final String endDate;
  final String link;
  final String naverMap;
  final String kakaoMap;
  final String googleMap;
  final double id;
  final String placeTag;
  final double latitude;
  final double longitude;

  PopupStore({
    required this.name,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.link,
    required this.naverMap,
    required this.kakaoMap,
    required this.googleMap,
    required this.id,
    required this.placeTag,
    required this.latitude,
    required this.longitude,
  });

  factory PopupStore.fromMap(Map<String, dynamic> json) {
    return PopupStore(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      link: json['link'] ?? '',
      naverMap: json['naverMap'] ?? '',
      kakaoMap: json['kakaoMap'] ?? '',
      googleMap: json['googleMap'] ?? '',
      id: (json['id'] ?? 0).toDouble(),
      placeTag: json['place_tag'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

class PopupProvider with ChangeNotifier {
  List<PopupStore> _popups = [];
  bool isLoading = false;

  List<PopupStore> get popups => _popups;

  Future<void> fetchPopups() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('popup_store')
          .select('*')
          .order('startDate');

      _popups = response.map<PopupStore>((item) => PopupStore.fromMap(item)).toList();
    } catch (e) {
      print('🔥 Supabase fetch error: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
