import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/map_widget/mixin/google_map_mixin.dart';
import 'package:flutter_application_1/map_widget/screens/state_management/google_map_notifier.dart';
import 'package:flutter_application_1/map_widget/screens/state_management/map_type_notifier.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
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
  final myMapTypeNotifier = MyMapTypeNotifier();

  get currentMapType => myMapTypeNotifier.mapType;

  var provider =
      CachedNetworkTileProvider(); // save cache map to improve the UX

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
      floatingActionButton: InkWell(
        onTap: () {
          int index = MapTypeEnum.available.indexOf(currentMapType);

          var mapTypeToChange = MapTypeEnum.available.elementAt(1 - index);

          myMapTypeNotifier.onMapTypeChanged(mapTypeToChange);
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.change_circle,
              size: 100,
              color: Colors.blue,
            ),
            Text(
              "change map tile url",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: myMapTypeNotifier,
        builder: (context, child) {
          return _buildMap(myMapTypeNotifier.mapType);
        },
      ),
    );
  }

  Widget _buildMap(MapTypeEnum mapType) {
    var point =
        const LatLng(10.8231, 106.6297); // Example location in Ho Chi Minh City

    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 13.0,
      ),
      children: [
        _getMap(mapType),

        // marker
        DragMarkers(
          markers: [
            DragMarker(
              key: GlobalKey<DragMarkerWidgetState>(),
              point: point,
              size: const Size.square(75),
              offset: const Offset(0, -20),
              dragOffset: const Offset(0, -35),
              builder: (_, __, isDragging) {
                return const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 100,
                );
                // return SvgPicture.asset(
                //   Assets.map.pinMarker,
                //   width: 11,
                //   height: 11,
                //   fit: BoxFit.scaleDown,
                // );
              },
              onDragEnd: (details, point) {},
              scrollMapNearEdge: true,
              scrollNearEdgeRatio: 2.0,
              scrollNearEdgeSpeed: 2.0,
            ),
          ],
        )
      ],
    );
  }

  Widget _getMap(MapTypeEnum mapType) {
    switch (mapType) {
      case MapTypeEnum.google:
        return _buildGoogleMap();
      case MapTypeEnum.mapBox:
        return _buildMapBox();
    }
  }

  Widget _buildMapBox() {
    return TileLayer(
      urlTemplate:
          'https://api.mapbox.com/styles/v1/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
      minZoom: AppConstants.minZoom,
      maxZoom: AppConstants.maxZoom,
      additionalOptions: {
        'mapStyleId': AppConstants.mapBoxStyleId,
        'accessToken': AppConstants.mapBoxAccessToken,
      },
      tileProvider: provider,
    );
  }

  Widget _buildGoogleMap() {
    return ListenableBuilder(
        listenable: myGoogleMapUrlNotifier,
        builder: (context, child) {
          return myGoogleMapUrlNotifier.url.isNotEmpty
              ? TileLayer(
                  urlTemplate: myGoogleMapUrlNotifier.url,
                  minZoom: AppConstants.minZoom,
                  maxZoom: AppConstants.maxZoom,
                  errorTileCallback: (tile, error, stackTrace) {
                    // errorTileCallback?.call();
                  },
                  tileProvider: provider,
                )
              : const Center(
                  child:
                      Text("Please add google Tile API key to view the map"));
        });
  }
}
