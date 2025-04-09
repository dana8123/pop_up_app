import 'package:flutter/material.dart';
import 'package:popup_app/utils/like_helper.dart';
import 'package:popup_app/utils/tag_color_helper.dart';
import 'package:provider/provider.dart';
import '../providers/popup_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PopupListPage extends StatefulWidget {
  @override
  State<PopupListPage> createState() => _PopupListPageState();
}

class _PopupListPageState extends State<PopupListPage> {
  Map<double, bool> likedStatus = {};

  @override
  void initState() {
    super.initState();
    _loadLikedStatus();
  }

  Future<void> _loadLikedStatus() async {
    final provider = Provider.of<PopupProvider>(context, listen: false);
    for (var popup in provider.popups) {
      final liked = await LikeHelper.isLiked(popup.id);
      likedStatus[popup.id] = liked;
    }
    setState(() {});
  }

  void _toggleLike(double id) async {
    final newValue = await LikeHelper.toggleLike(id);
    setState(() {
      likedStatus[id] = newValue;
    });
  }

  Widget build(BuildContext context) {
    final popupProvider = Provider.of<PopupProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Popup Stores')),
      body: popupProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: popupProvider.popups.length,
              itemBuilder: (context, index) {
                final popup = popupProvider.popups[index];

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
                                color: getTagColor(popup.placeTag),
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
                                IconButton(
                                  icon: Icon(Icons.map, color: Colors.grey),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () => popupProvider.fetchPopups(),
      ),
    );
  }

  void _openLink(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open link")),
      );
    }
  }
}
