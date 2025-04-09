String formatPopupDateFromString(String dateString) {
  final regex = RegExp(r'Date\((\d+),\s*(\d+),\s*(\d+)\)');
  final match = regex.firstMatch(dateString);

  if (match != null) {
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!) + 1;
    final day = int.parse(match.group(3)!);

    return '${year % 100}.$month.$day';
  }

  return dateString; // 파싱 안 되면 원본 리턴
}