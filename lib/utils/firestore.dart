import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart'; // Firebase 초기화 옵션
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await uploadDataToFirestore();
}

Future<void> uploadDataToFirestore() async {
  final String spreadsheetId = 'YOUR_SPREADSHEET_ID'; // Replace with your actual ID
  final response = await http.get(
    Uri.parse("https://docs.google.com/spreadsheets/d/$spreadsheetId/gviz/tq?tqx=out:json"),
  );

  if (response.statusCode == 200) {
    // 응답에서 함수 껍데기 제거
    final jsonString = response.body
        .replaceFirst('/*O_o*/', '')
        .replaceFirst('google.visualization.Query.setResponse(', '')
        .replaceFirst(RegExp(r'\);\s*$'), '');

    final jsonData = json.decode(jsonString);
    final rows = jsonData['table']['rows'];

    for (var row in rows) {
      final cells = row['c'];
      try {
        await FirebaseFirestore.instance.collection('popups').add({
          'name': cells[0]?['v'] ?? '',
          'address': cells[1]?['v'] ?? '',
          'description': cells[2]?['v'] ?? '',
          'img': cells[3]?['v'] ?? '',
          'start_at': cells[4]?['v'] ?? '',
          'end_at': cells[5]?['v'] ?? '',
          'link': cells[6]?['v'] ?? '',
          'naver': cells[7]?['v'] ?? '',
          'kakao': cells[8]?['v'] ?? '',
          'google': cells[9]?['v'] ?? '',
          'place_tag': cells[10]?['v'] ?? '',
          'lat': double.tryParse(cells[11]?['v']?.toString() ?? '0') ?? 0,
          'lng': double.tryParse(cells[12]?['v']?.toString() ?? '0') ?? 0,
        });
      } catch (e) {
        print('❌ Firestore 업로드 중 오류 발생: $e');
      }
    }

    print('✅ 업로드 완료!');
  } else {
    print('❌ 데이터 로드 실패: ${response.statusCode}');
  }
}
