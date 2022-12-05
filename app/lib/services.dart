import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import './constants.dart';
import 'models/plant_location_model.dart';
import 'widgets/dialogs.dart';

class APIResponse {
  String message;
  int responseCode;
  String errorCode;
  bool success;
  Object object;
  APIResponse(
      {this.message,
      this.success,
      this.errorCode,
      this.responseCode,
      this.object});
}

class RESTAPI {
  static const baseUrl = "$SERVER_DOMAIN/api/v1";
  static const commonHeaders = {
    'App-Auth': 'SistemesMultimedia2021',
  };
  static const FlutterSecureStorage secureStorage =
      const FlutterSecureStorage();

  static Future<bool> checkIfUserIsLoggedIn() async {
    return await secureStorage.read(key: 'access_token').then((value) {
      return value != null;
    });
  }

  static Future<APIResponse> refreshToken() async {
    try {
      String refreshToken = await secureStorage.read(key: 'refresh_token');

      final http.Response response =
          await http.post("$baseUrl/auth/refresh-token/",
              headers: {
                'Authorization': "Bearer $refreshToken",
              }..addAll(commonHeaders));

      var decodedResponse = json.decode(response.body);

      await secureStorage.write(
          key: 'access_token', value: decodedResponse['access_token']);
    } catch (e) {
      logOut();
      return new APIResponse(
        success: false,
      );
    }

    return new APIResponse(
      success: true,
    );
  }

  static Future<APIResponse> logOut() async {
    await secureStorage.delete(key: 'username');
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');

    return new APIResponse(
      success: true,
    );
  }

  static Future<APIResponse> login(String username, String password) async {
    http.Response response;

    try {
      response = await http.post(
        "$baseUrl/auth/login/",
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        }..addAll(commonHeaders),
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
    } catch (e, s) {
      print('login error: $e - stack: $s');
      return new APIResponse(
        success: false,
      );
    }

    Map decodedResponse = json.decode(utf8.decode(response.bodyBytes));

    if (decodedResponse.containsKey('error')) {
      return APIResponse(
        success: false,
        message: decodedResponse['error'],
      );
    }

    await secureStorage.write(
        key: 'refresh_token', value: decodedResponse['refresh_token']);
    await secureStorage.write(
        key: 'access_token', value: decodedResponse['access_token']);
    await secureStorage.write(key: 'username', value: username);

    return new APIResponse(
      success: true,
    );
  }

  static Future<APIResponse> signup(
      String username, String password1, password2) async {
    http.Response response;

    try {
      response = await http.post(
        "$baseUrl/auth/signup/",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }..addAll(commonHeaders),
        body: json.encode({
          'username': username,
          'password1': password1,
          'password2': password2,
        }),
      );
    } catch (e, s) {
      return new APIResponse(
        success: false,
        errorCode: 'connection_error',
      );
    }

    if (response.statusCode != 201 &&
        response.statusCode != 200 &&
        response.statusCode != 400) {
      return new APIResponse(
        success: false,
        responseCode: response.statusCode,
        errorCode: 'unhandled',
      );
    }

    Map decodedResponse = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 400) {
      return new APIResponse(
        success: false,
        errorCode: 'validation_error',
        message: decodedResponse['error'],
      );
    } else if (response.statusCode == 200) {
      return new APIResponse(
        success: false,
        errorCode: 'username_taken',
        message: decodedResponse['error'],
      );
    }

    return new APIResponse(
      success: true,
      object: decodedResponse,
    );
  }

  Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  static Future<APIResponse> listPlantLocations() async {
    var url = "$baseUrl/plants/";
    http.Response response;

    try {
      response = await http.get(
        url,
        headers: <String, String>{}..addAll(commonHeaders),
      );
    } catch (e) {
      return new APIResponse(
        success: false,
        errorCode: 'connection_error',
      );
    }

    if (response.statusCode == 404) {
      return new APIResponse(
        success: true,
        object: const <PlantLocationModel>[],
      );
    }

    Iterable list = json.decode(utf8.decode(response.bodyBytes))['data'];
    List<PlantLocationModel> plantLocations =
        list.map((model) => PlantLocationModel.fromJson(model)).toList();

    return new APIResponse(
      success: true,
      object: plantLocations,
    );
  }

  static Future<APIResponse> listUserPlantLocations({String username}) async {
    if (username == null) username = await secureStorage.read(key: "username");
    var url = "$baseUrl/plants/$username/";
    http.Response response;

    try {
      response = await http.get(
        url,
        headers: <String, String>{}..addAll(commonHeaders),
      );
    } catch (e) {
      return new APIResponse(
        success: false,
        errorCode: 'connection_error',
      );
    }

    if (response.statusCode == 404) {
      return new APIResponse(
        success: true,
        object: const <PlantLocationModel>[],
      );
    }

    Iterable list = json.decode(utf8.decode(response.bodyBytes))['data'];
    List<PlantLocationModel> plantLocations =
        list.map((model) => PlantLocationModel.fromJson(model)).toList();

    return new APIResponse(
      success: true,
      object: plantLocations,
    );
  }

  static Future<APIResponse> createPlantLocation(
      PlantLocationModel plantLocation) async {
    var url = "$baseUrl/plants/create/";
    var uri = Uri.parse(url);
    http.StreamedResponse response;

    var stream = new http.ByteStream(plantLocation.imageFile.openRead());
    var length = await plantLocation.imageFile.length();
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(plantLocation.imageFile.path));
    request.files.add(multipartFile);

    String accessToken = await secureStorage.read(key: "access_token");
    request.headers['Authorization'] = "Bearer $accessToken";
    commonHeaders.forEach((k, v) {
      request.headers[k] = v;
    });
    plantLocation.toJson().forEach((k, v) {
      request.fields[k] = v;
    });

    try {
      response = await request.send();
    } catch (e) {
      APIResponse refreshResponse = await refreshToken();

      if (!refreshResponse.success) {
        return new APIResponse(
          success: false,
          errorCode: 'connection_error',
        );
      }

      response = await request.send();
    }

    if (response.statusCode != 201) {
      return new APIResponse(
        success: false,
        responseCode: response.statusCode,
      );
    }

    return new APIResponse(
      success: true,
      responseCode: response.statusCode,
    );
  }

  static Future<APIResponse> identifyPlant(File imageFile, String type) async {
    var url = PLANTNET_ENDPOINT;
    var uri = Uri.parse(url);
    http.StreamedResponse response;

    var stream = new http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('images', stream, length,
        filename: basename(imageFile.path));
    request.files.add(multipartFile);
    request.fields['organs'] = type;

    try {
      response = await request.send();
    } catch (e) {
      return new APIResponse(
        success: false,
        errorCode: 'connection_error',
      );
    }

    if (response.statusCode != 200) {
      return new APIResponse(
        success: false,
        responseCode: response.statusCode,
        object: json.decode(utf8.decode(await response.stream.toBytes())),
      );
    }

    return new APIResponse(
      success: true,
      responseCode: response.statusCode,
      object: json.decode(utf8.decode(await response.stream.toBytes())),
    );
  }
}

Future<Position> getCurrentLocation(context) async {
  Position currentLocation;
  bool success = false;
  int intents = 0;

  while (!success || currentLocation == null) {
    try {
      currentLocation = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .timeout(Duration(seconds: 3), onTimeout: () {
        final Geolocator geolocatorObj = new Geolocator();
        geolocatorObj.forceAndroidLocationManager = true;
        return geolocatorObj
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
            .timeout(Duration(seconds: 3));
      });
      success = true;
    } catch (err) {
      intents++;

      if (intents >= 10) {
        await showErrorDialog(
          context,
          title: "Es necessiten els serveis d'ubicació",
          message:
              "Aquesta aplicació fa ús de la seva ubicació per mostrar-li les plantes del seu entorn i, en cas que vosté en faci alguna aportació, lligar la seva ubicació actual amb la imatge pujada.",
        );
        intents = 0;
      }
    }
  }

  return currentLocation;
}
