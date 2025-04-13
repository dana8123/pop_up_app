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
      startDate: json['start_at'] ?? '',
      endDate: json['end_at'] ?? '',
      link: json['link'] ?? '',
      naverMap: json['naver'] ?? '',
      kakaoMap: json['kakao'] ?? '',
      googleMap: json['google'] ?? '',
      id: (json['id'] ?? 0).toDouble(),
      placeTag: json['place_tag'] ?? '',
      latitude: (json['lat'] ?? 0).toDouble(),
      longitude: (json['lnt'] ?? 0).toDouble(),
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
          .from('popups')
          .select()
          .order('start_at');

      print("응답!");
      print(response);
      _popups =
          response.map<PopupStore>((item) => PopupStore.fromMap(item)).toList();
    } catch (e) {
      print('🔥 Supabase fetch error: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
