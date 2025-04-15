import 'package:flutter/material.dart';
import 'package:popup_app/utils/date_helper.dart';
import 'package:popup_app/utils/like_helper.dart';
import 'package:popup_app/utils/tag_color_helper.dart';
import 'package:popup_app/utils/translate_helper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/popup_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PopupListPage extends StatefulWidget {
  @override
  State<PopupListPage> createState() => _PopupListPageState();
}

class _PopupListPageState extends State<PopupListPage> {
  Map<double, bool> likedStatus = {};
  final List<String> locationList = ['전체', '성수', '잠실', '을지로', '강남', '홍대', '기타' ];
  String selectedLocation = '전체';

  @override
  void initState() {
    super.initState();
    _loadLikedStatus();

    Future.microtask(() {
    Provider.of<PopupProvider>(context, listen: false).fetchPopups();
  });
  }

  Future<void> _loadLikedStatus() async {
    final provider = Provider.of<PopupProvider>(context, listen: false);
    for (var popup in provider.popups) {
      final liked = await LikeHelper.isLiked(popup.id);
      likedStatus[popup.id] = liked;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final popupProvider = Provider.of<PopupProvider>(context);
    final filteredList = selectedLocation == '전체'
    ? popupProvider.popups
    : popupProvider.popups
        .where((p) => p.placeTag == selectedLocation)
        .toList();
        
    return Scaffold(
      appBar: AppBar(title: Text('Popup Finder')),
      body: Column(
        children: [
          // 👇 필터 (고정 영역)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButton<String>(
            value: selectedLocation,
            onChanged: (value) {
              setState(() {
                selectedLocation = value!;
              });
            },
            items: locationList.map((location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(translatePlace(context, location)),
              );
            }).toList(),
          ),
        ),
        // 카드리스트
        Expanded(child: popupProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : filteredList.isEmpty 
                ?Center(child: Text("팝업 정보가 없습니다")) 
              : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final popup = filteredList[index];
          
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
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, StackTrace) {
                                      return Image.asset('assets/no_image.png',
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.fill);
                                    },
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getTagColor(popup.placeTag),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(translatePlace(context, popup.placeTag)),
                                    ),
                                    SizedBox(width: 8.0),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text("${formatPopupDateFromString(popup.startDate)} ~ ${formatPopupDateFromString(popup.endDate)}"),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(popup.localizedName(context)),
                                  subtitle: Text(popup.localizedDescription(context)),
                                  trailing: IconButton(
                                    icon: Icon(Icons.link, color: Colors.blue),
                                    onPressed: () => _openLink(context, popup.link),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Image.asset(
                                        'assets/icons/naver_map.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      onPressed: () =>
                                          _openLink(context, popup.naverMap),
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'assets/icons/kakao_map.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      onPressed: () =>
                                          _openLink(context, popup.kakaoMap),
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'assets/icons/google_map.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      onPressed: () =>
                                          _openLink(context, popup.googleMap),
                                    ),
                                    // 👉 왼쪽 아이콘들 끝나고 공간 밀어냄
                                    Spacer(),
                                    Builder(
                                      builder: (shareContext) {
                                        return IconButton(
                                          icon: Icon(Icons.share),
                                          onPressed: () {
                                            final box = shareContext.findRenderObject() as RenderBox?;
                                            final shareText = 
                                        '''Popup Finder\n📍 ${popup.name}\n📌 ${popup.address ?? '주소 정보 없음'}\n🗓️ ${formatPopupDateFromString(popup.startDate)} ~ ${formatPopupDateFromString(popup.endDate)}\n지금 이 팝업, 딱 내 취향...!  
                                        👉 Popup Finder에서 더 알아보기!''';
                                        
                                              if (box != null) {
                                                Share.share(
                                                  shareText,
                                                  sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                                                );
                                              } else {
                                                Share.share(shareText);
                                              }
                                          },
                                        );
                                      }
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
                ),)
          
        ],
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
