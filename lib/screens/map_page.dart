import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/popup_provider.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final popupList = context.watch<PopupProvider>().popups;

    return Scaffold(
      body: Stack(
        children: [
          AppleMap(
            initialCameraPosition: CameraPosition(
              target: popupList.isNotEmpty
                  ? LatLng(popupList.first.latitude, popupList.first.longitude)
                  : LatLng(37.5665, 126.9780), // 서울 중심
              zoom: 12,
            ),
            annotations: popupList.map((popup) {
              return Annotation(
                annotationId: AnnotationId(popup.id.toString()),
                position: LatLng(popup.latitude, popup.longitude),
                infoWindow: InfoWindow(
                  title: popup.localizedName(context),
                  snippet: popup.address,
                ),
              );
            }).toSet(),
          ),
          // 상단 앱바
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 하단 팝업 리스트
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '주변 팝업스토어',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: popupList.length,
                      itemBuilder: (context, index) {
                        final popup = popupList[index];
                        return Container(
                          width: 280,
                          margin: EdgeInsets.only(right: 12),
                          child: Card(
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    popup.imageUrl ?? '',
                                    width: 80,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          popup.localizedName(context),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          popup.address ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
