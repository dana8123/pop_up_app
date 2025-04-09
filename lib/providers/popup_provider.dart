import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final String place_tag;

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
    required this.place_tag,
  });

  factory PopupStore.fromJson(Map<String, dynamic> json) {
    return PopupStore(
        name: json['name'],
        address: json['address'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        startDate: json['startDate'],
        endDate: json['endDate'],
        link: json['link'],
        naverMap: json['naverMap'],
        kakaoMap: json['kakaoMap'],
        googleMap: json['googleMap'],
        id: json['id'],
        place_tag: json['place_tag']);
  }
}

class PopupProvider with ChangeNotifier {
  List<PopupStore> _popups = [];
  bool isLoading = false;

  List<PopupStore> get popups => _popups;

  Future<void> fetchPopups() async {
    isLoading = true;
    notifyListeners();

    final String spreadsheetId = dotenv.env['SPREADSHEETID'] ?? 'default_key';
    final String url =
        "https://docs.google.com/spreadsheets/d/$spreadsheetId/gviz/tq?tqx=out:json";

    try {
      final response = await http.get(Uri.parse(url));
      print("response.body>>> ${response.body}");
      if (response.statusCode == 200) {
        String jsonStr = response.body;
        jsonStr = jsonStr.substring(
            jsonStr.indexOf('{'), jsonStr.lastIndexOf('}') + 1);
        Map<String, dynamic> jsonData = json.decode(jsonStr);

        List<PopupStore> loadedPopups = [];
        var rows = jsonData['table']['rows'];
        for (var row in rows) {
          var values = row['c'];
          loadedPopups.add(PopupStore(
            name: values.length > 0 && values[0] != null
                ? values[0]['v'] ?? ''
                : '',
            address: values.length > 1 && values[1] != null
                ? values[1]['v'] ?? ''
                : '',
            description: values.length > 2 && values[2] != null
                ? values[2]['v'] ?? ''
                : '',
            imageUrl: values.length > 3 && values[3] != null
                ? values[3]['v'] ?? ''
                : '',
            startDate: values.length > 4 && values[4] != null
                ? values[4]['v'] ?? ''
                : '',
            endDate: values.length > 5 && values[5] != null
                ? values[5]['v'] ?? ''
                : '',
            link: values.length > 6 && values[6] != null
                ? values[6]['v'] ?? ''
                : '',
            naverMap: values.length > 7 && values[7] != null
                ? values[7]['v'] ?? ''
                : '',
            kakaoMap: values.length > 8 && values[8] != null
                ? values[8]['v'] ?? ''
                : '',
            googleMap: values.length > 9 && values[9] != null
                ? values[9]['v'] ?? ''
                : '',
            id: values.length > 10 && values[10] != null
                ? values[10]['v'] ?? ''
                : '',
            place_tag: values.length > 11 && values[11] != null
                ? values[11]['v'] ?? ''
                : '',
          ));
        }

        _popups = loadedPopups;
      }
    } catch (e) {
      print("스프레드시트 패치에러: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
