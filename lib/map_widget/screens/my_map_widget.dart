import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/map_widget/mixin/google_map_mixin.dart';
import 'package:flutter_application_1/map_widget/screens/state_managment/google_map_notifier.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CachedNetworkTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(getTileUrl(coordinates, options));
  }
}

class MyMapWidget extends StatefulWidget {
  const MyMapWidget({super.key});

  @override
  State<MyMapWidget> createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> with MyGoogleMapMixin {
  final myGoogleMapUrlNotifier = MyGoogleMapNotifier();

  @override
  void initState() {
    super.initState();
    initUrl();
  }

  void initUrl() async {
    String? url = await getGoogleMapTileUrl();
    if (url != null) {
      myGoogleMapUrlNotifier.onUrlChange(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
          listenable: myGoogleMapUrlNotifier,
          builder: (context, child) {
            return myGoogleMapUrlNotifier.url.isNotEmpty
                ? _buildMap(myGoogleMapUrlNotifier.url)
                : const Center(
                    child:
                        Text("Please add google Tile API key to view the map"));
          }),
    );
  }

  Widget _buildMap(String urlTemplate) {
    // save cache map to improve the UX
    var provider = CachedNetworkTileProvider();

    return FlutterMap(
      options: const MapOptions(
        initialCenter:
            LatLng(10.8231, 106.6297), // Example location in Ho Chi Minh City
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: urlTemplate,
          minZoom: AppConstants.minZoom,
          maxZoom: AppConstants.maxZoom,
          errorTileCallback: (tile, error, stackTrace) {
            // errorTileCallback?.call();
          },
          tileProvider: provider,
        )
      ],
    );
  }
}
