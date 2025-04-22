import 'package:flutter/material.dart';
import 'package:popup_app/main.dart';
import 'package:popup_app/providers/popup_provider.dart';
import 'package:popup_app/screens/popup_list_page.dart';
import 'package:popup_app/utils/date_helper.dart';
import 'package:popup_app/utils/like_helper.dart';
import 'package:popup_app/utils/translate_helper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:popup_app/l10n/app_localizations.dart';
import 'dart:io';

class LikeListPage extends StatefulWidget {
  @override
  _LikeListPageState createState() => _LikeListPageState();
}

class _LikeListPageState extends State<LikeListPage> {
  List<double> likedIds = [];

  @override
  void initState() {
    super.initState();
    _loadLikedPopups();
  }

  Future<void> _loadLikedPopups() async {
    final prefs = await LikeHelper.getLikedPopupIds();
    setState(() {
      likedIds = prefs.map((id) => double.tryParse(id) ?? -1).toList();
    });
  }

  void _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("링크를 열 수 없습니다.")));
    }
  }

  void _sharePopup(BuildContext shareContext, PopupStore popup) {
    final shareText = '''
${popup.localizedName(shareContext)}
📍 ${popup.address ?? '주소 정보 없음'}
🗓️ ${formatPopupDateFromString(popup.startDate)} - ${formatPopupDateFromString(popup.endDate)}
지금 이 팝업, 딱 내 취향...!
👉 Popup Finder에서 더 알아보기!
    ''';
    if (Platform.isIOS) {
      final box = shareContext.findRenderObject() as RenderBox?;
      Share.share(
        shareText,
        sharePositionOrigin: box != null 
            ? box.localToGlobal(Offset.zero) & box.size
            : Rect.zero,
      );
    } else {
      Share.share(shareText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final popupProvider = Provider.of<PopupProvider>(context);
    final likedPopups = popupProvider.popups
        .where((popup) => likedIds.contains(popup.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("좋아요")),
      body: likedPopups.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.no_like))
          : ListView.builder(
              itemCount: likedPopups.length,
              itemBuilder: (context, index) {
                final popup = likedPopups[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              popup.imageUrl ?? '',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: Image.asset('assets/no_image.png'),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: LikeButton(popupId: popup.id),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                translatePlace(context, popup.placeTag),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              popup.localizedName(context),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  '${formatPopupDateFromString(popup.startDate)} - ${formatPopupDateFromString(popup.endDate)}',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Icon(Icons.description, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    popup.localizedDescription(context) ?? '',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                    maxLines: 3,
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  ),
                                )
                              ]
                            ),
                            
                            SizedBox(height: 16),
                            Divider(),
                            SizedBox(height: 8),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () => _openLink(context, popup.naverMap),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/icons/naver_map.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '네이버지도',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _openLink(context, popup.kakaoMap),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/icons/kakao_map.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '카카오맵',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _openLink(context, popup.googleMap),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/icons/google_map.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '구글지도',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Builder(
                                  builder: (shareContext) {
                                    return InkWell(
                                      onTap: () => _sharePopup(shareContext, popup),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.share,
                                            size: 24,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '공유하기',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}


class LikeButton extends StatefulWidget {
  final double popupId;

  const LikeButton({Key? key, required this.popupId}) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    final liked = await LikeHelper.isLiked(widget.popupId);
    if (mounted) {
      setState(() {
        isLiked = liked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: () async {
        await LikeHelper.toggleLike(widget.popupId);
        await _checkLikeStatus();
      },
    );
  }
}
