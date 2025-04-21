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
          
                    return PopupCard(popup: popup);
                  },
                ),)
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () => Provider.of<PopupProvider>(context, listen: false).fetchPopups(),
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

class PopupCard extends StatelessWidget {
  final PopupStore popup;

  const PopupCard({Key? key, required this.popup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      child: Icon(Icons.image_not_supported, size: 50),
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
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        popup.address ?? '',
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
