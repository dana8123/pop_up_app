
import 'package:flutter/material.dart';

final Map<String, Color> tagColors = {
  '강남': Colors.pinkAccent,
  '홍대': Colors.deepPurple,
  '성수': Colors.teal,
  '잠실': Colors.orange,
  '을지로': Colors.blueGrey,
  '건대': Colors.amber,
};

Color getTagColor(String tag) {
  return tagColors[tag] ?? Colors.grey; // 기본값
}