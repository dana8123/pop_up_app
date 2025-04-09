import 'package:flutter/material.dart';
import 'package:popup_app/providers/popup_provider.dart';
import 'package:popup_app/utils/like_helper.dart';
import 'package:popup_app/utils/tag_color_helper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    final popupProvider = Provider.of<PopupProvider>(context);
    final likedPopups = popupProvider.popups
        .where((popup) => likedIds.contains(popup.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("좋아요한 팝업")),
      body: likedPopups.isEmpty
          ? Center(child: Text("좋아요한 팝업이 없어요."))
          : ListView.builder(
              itemCount: likedPopups.length,
              itemBuilder: (context, index) {
                final popup = likedPopups[index];

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.network(
                                popup.imageUrl ?? '',
                                width: 150,
                                height: 150,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, StackTrace) {
                                  return Image.asset('assets/no_image.png',
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.fill);
                                },
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color:getTagColor(popup.placeTag),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(popup.placeTag),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(popup.name),
                              subtitle: Text(popup.description),
                              trailing: IconButton(
                                icon: Icon(Icons.link, color: Colors.blue),
                                onPressed: () => _openLink(context, popup.link),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Image.asset('assets/icons/naver_map.png',width: 30,height: 30,),
                                  onPressed: () =>
                                      _openLink(context, popup.naverMap),
                                ),
                                IconButton(
                                  icon: Image.asset('assets/icons/kakao_map.png',width: 30,height: 30,),
                                  onPressed: () =>
                                      _openLink(context, popup.kakaoMap),
                                ),
                                IconButton(
                                  icon: Image.asset('assets/icons/google_map.png',width: 30,height: 30,),
                                  onPressed: () =>
                                      _openLink(context, popup.googleMap),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 좋아요 버튼 오른쪽 상단에 위치
                      Positioned(
                          top: 8,
                          right: 8,
                          child: FutureBuilder<bool>(
                              future: LikeHelper.isLiked(popup.id),
                              builder: (context, snapshot) {
                                final isLiked = snapshot.data ?? false;
                                return IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    await LikeHelper.toggleLike(popup.id);
                                    // (context as Element)
                                    //     .markNeedsBuild(); // 임시 리빌드
                                    setState(() {});
                                  },
                                );
                              })),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
