import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/popup_provider.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final popupList = context.watch<PopupProvider>().popups;

    return Scaffold(
      appBar: AppBar(title: Text('팝업 지도')),
      body: AppleMap(
        initialCameraPosition: CameraPosition(
          target: popupList.isNotEmpty
              ? LatLng(popupList.first.latitude, popupList.first.longitude)
              : LatLng(37.7749, -122.4194), // fallback 위치
          zoom: 12,
        ),
        annotations: popupList.map((popup) {
          return Annotation(
            annotationId: AnnotationId(popup.id.toString()),
            position: LatLng(popup.latitude, popup.longitude),
            infoWindow: InfoWindow(
              title: popup.name,
              snippet: popup.placeTag,
            ),
          );
        }).toSet(),
      ),
    );
  }
}
