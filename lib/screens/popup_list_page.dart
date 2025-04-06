import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/popup_provider.dart';
import 'package:url_launcher/url_launcher.dart';


class PopupListPage extends StatelessWidget {
  @override
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        Center(
                          child: Image.network(popup.imageUrl, width: 150, height: 150, fit: BoxFit.fill)
                        ),
                        SizedBox(height: 8.0),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(popup.name),
                          subtitle: Text(popup.description),
                          trailing: IconButton(
                            icon: Icon(Icons.link, color: Colors.blue),
                            onPressed: () => _openLink(context, popup.link),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              icon: Icon(Icons.map, color: Colors.green),
                              label: Text("네이버 지도"),
                              onPressed: () => _openLink(context, popup.naverMap),
                            ),
                            TextButton.icon(
                              icon: Icon(Icons.map, color: Colors.orange),
                              label: Text("카카오 지도"),
                              onPressed: () => _openLink(context, popup.kakaoMap),
                            ),
                            TextButton.icon(
                              icon: Icon(Icons.map, color: Colors.blue),
                              label: Text("구글 맵"),
                              onPressed: () => _openLink(context, popup.googleMap),
                            ),
                          ],
                        ),
                      ],
                    ));
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
