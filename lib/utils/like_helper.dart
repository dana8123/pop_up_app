import 'package:shared_preferences/shared_preferences.dart';

class LikeHelper {
  static const _likedKey = 'liked_popups';

  static Future<List<String>> getLikedPopupIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_likedKey) ?? [];
  }

  static Future<bool> toggleLike(double id) async {
    final prefs = await SharedPreferences.getInstance();
    final likedIds = await getLikedPopupIds();
    final idStr = id.toString();

    if (likedIds.contains(idStr)) {
      likedIds.remove(idStr);
      await prefs.setStringList(_likedKey, likedIds);
      return false;
    } else {
      likedIds.add(idStr);
      await prefs.setStringList(_likedKey, likedIds);
      return true;
    }
  }

  static Future<bool> isLiked(double popupId) async {
    final likedIds = await getLikedPopupIds();
    return likedIds.contains(popupId.toString());
  }
}
