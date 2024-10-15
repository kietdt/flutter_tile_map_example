import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_application_1/map_widget/network/http_client.dart';
import 'package:flutter_application_1/map_widget/network/my_response.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

// ignore: camel_case_types
class DATA_CONST {
  // ignore: non_constant_identifier_names
  static String GG_MAP_SESSION_TOKEN = "GG_MAP_SESSION_TOKEN";

  // ignore: non_constant_identifier_names
  static String EXPIRY_GG_MAP_SESSION_TOKEN = "EXPIRY_GG_MAP_SESSION_TOKEN";
}

class AppConstants {
  static String googleMapAPIKey = ""; // insert your Google map Tile key here
  static double minZoom = 13;
  static double maxZoom = 22;
}

mixin MyGoogleMapMixin {
  Future<String?> getGoogleMapTileUrl() async {
    String? token = await getGoogleTileApiToken();
    if (token != null) {
      String result = await getRoadmapTiles(token);
      return result;
    }
    return null;
  }

  Future<String?> getGoogleTileApiToken() async {
    String? token = getLocalToken();

    if (token == null || isTokenExpired()) {
      var result = await getTileMapSessionToken();
      if (result.statusCode == HttpStatus.ok) {
        token = result.body['session'];
        String? expiry = result.body['expiry']; // in seconds
        if (token != null && expiry != null) {
          saveNewSessionToken(token, expiry);
        }
      }
    }

    return token;
  }

  void saveNewSessionToken(String token, String expiry) {
    GetIt.instance
        .get<SharedPreferences>()
        .setString(DATA_CONST.GG_MAP_SESSION_TOKEN, token);
    GetIt.instance
        .get<SharedPreferences>()
        .setString(DATA_CONST.EXPIRY_GG_MAP_SESSION_TOKEN, expiry);

    try {
      log("MyGoogleMapMixin -> saveNewSessionToken: token: $token");
      log("MyGoogleMapMixin -> saveNewSessionToken: expire at: ${DateTime.fromMillisecondsSinceEpoch(int.parse(expiry) * 1000)}");
    } catch (e) {
      log(e.toString());
    }
  }

  bool isTokenExpired() {
    bool result = false;

    String? expiry = GetIt.instance
        .get<SharedPreferences>()
        .getString(DATA_CONST.EXPIRY_GG_MAP_SESSION_TOKEN);

    if (expiry != null) {
      DateTime expireAt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(expiry) * 1000);
      result = DateTime.now().difference(expireAt).inSeconds > 0;
    }

    return result;
  }

  String? getLocalToken() {
    return GetIt.instance
        .get<SharedPreferences>()
        .getString(DATA_CONST.GG_MAP_SESSION_TOKEN);
  }

  Future<BResponse> getTileMapSessionToken() async {
    String apiKey = AppConstants.googleMapAPIKey;

    http.Response res = await ApiHelper.post(
      path: 'v1/createSession?key={key}',
      customBaseApi: "https://tile.googleapis.com/",
      params: {
        "key": apiKey,
      },
      body: {
        "mapType": "roadmap",
        "language": "en-US",
        "region": "US",
      },
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    dynamic responseData;

    try {
      responseData = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      log(e.toString());
    }
    
    var data = responseData ?? <String, dynamic>{};

    return BResponse(
      data,
      res.statusCode,
    );
  }

  Future<String> getRoadmapTiles(String token) async {
    // DOCUMENT => https://developers.google.com/maps/documentation/tile/roadmap

    String apiKey = AppConstants.googleMapAPIKey;

    return "https://tile.googleapis.com/v1/2dtiles/{z}/{x}/{y}?session=$token&key=$apiKey";
  }
}
