
import 'package:flutter/material.dart';

final Map<String, Color> tagColors = {
  '강남': Colors.pinkAccent,
  '홍대': Colors.deepPurple,
  '성수': Colors.teal.shade200,
  '잠실': Colors.orange.shade200,
  '을지로': Colors.blueGrey,
  '건대': Colors.amber.shade200,
};

Color getTagColor(String tag) {
  return tagColors[tag] ?? Colors.grey; // 기본값
}