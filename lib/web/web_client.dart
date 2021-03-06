import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:healthbook/model/models.dart';
import 'package:healthbook/util/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WebClient {
  final Duration delay;

  const WebClient([this.delay = const Duration(milliseconds: 3000)]);

  static Random random = new Random(12312423);
  static final HttpClient _httpClient = new HttpClient();

  Future<List<MedicalInformation>> fetchMedicalInformationEntries() async {
    return _performRemoteCallForEntries();
  }

  Future<List<RelevantQueryData>> fetchRelevantQueries() async {
    return _performRemoteCallForQueries();
  }

  Future<bool> postNewMedicalInformationEntry(
      MedicalInformation medicalInfo) async {
    print(
        "MedicalInfo (user Id: ${medicalInfo.userId}, title: ${medicalInfo.title}, description: ${medicalInfo.description}, tags: ${medicalInfo.tags}, image: omitted)");
    return _remotePostNewMedicalInformationEntry(medicalInfo);
  }

  Future<bool> postSharingPermissions(
      List<SharingPermission> permissions) async {
    return _remotePostSharingPermissions(permissions);
  }

  Future<RequestProperties> _retrieveRequestProperties() async {
    _httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return RequestProperties(prefs.getString(API_ADDRESS_KEY),
        prefs.getString(TOKEN_KEY), prefs.getString(USER_ID_KEY));
  }

  Future<List<MedicalInformation>> _performRemoteCallForEntries() async {
    try {
      final requestProperties = await _retrieveRequestProperties();
      final http.IOClient ioClient = new http.IOClient(_httpClient);
      http.Response response = await ioClient.get(
          "${requestProperties.apiAddress}/user/${requestProperties
              .userId}/medicalInformation",
          headers: {
            HttpHeaders.AUTHORIZATION: "Bearer ${requestProperties.apiToken}",
            HttpHeaders.ACCEPT: ContentType.JSON.value
          });
      if (response != null && response.statusCode == 200) {
        final List data = json.decode(response.body);
        final List<MedicalInformation> result = [];
        data.forEach((element) {
          result.add(new MedicalInformation.fromJson(element));
        });
        return result;
      }
      return [];
    } on Exception {
      print('Error while retrieving medical information entries!');
      return [];
    }
  }

  Future<List<RelevantQueryData>> _performRemoteCallForQueries() async {
    try {
      final requestProperties = await _retrieveRequestProperties();
      final http.IOClient ioClient = new http.IOClient(_httpClient);
      http.Response response = await ioClient.get(
          "${requestProperties.apiAddress}/user/${requestProperties
              .userId}/medicalQuery/matching",
          headers: {
            HttpHeaders.AUTHORIZATION: "Bearer ${requestProperties.apiToken}",
            HttpHeaders.ACCEPT: ContentType.JSON.value
          });
      if (response != null && response.statusCode == 200) {
        final List data = json.decode(response.body);
        final List<RelevantQueryData> result = [];
        data.forEach((element) {
          result.add(new RelevantQueryData.fromJson(element));
        });
        return result;
      }
      return [];
    } on Exception {
      print('Error while retrieving relevant medical queries!');
      return [];
    }
  }

  Future<bool> _remotePostNewMedicalInformationEntry(
      MedicalInformation medicalInfo) async {
    try {
      final requestProperties = await _retrieveRequestProperties();
      final http.IOClient ioClient = new http.IOClient(_httpClient);
      http.Response response = await ioClient.post(
          "${requestProperties.apiAddress}/user/${requestProperties
              .userId}/medicalInformation",
          headers: {
            HttpHeaders.AUTHORIZATION: "Bearer ${requestProperties.apiToken}",
            HttpHeaders.CONTENT_TYPE: ContentType.JSON.value,
            HttpHeaders.ACCEPT: ContentType.JSON.value
          },
          body: jsonEncode(medicalInfo.toJson()));
      if (response != null && response.statusCode == 200) {
        return true;
      }
      return false;
    } on Exception {
      print('Error while retrieving relevant medical queries!');
      return false;
    }
  }

  Future<bool> _remotePostSharingPermissions(
      List<SharingPermission> permissions) async {
    try {
      final requestProperties = await _retrieveRequestProperties();
      final http.IOClient ioClient = new http.IOClient(_httpClient);
      http.Response response = await ioClient.post(
          "${requestProperties.apiAddress}/user/${requestProperties
              .userId}/medicalQuery/permissions",
          headers: {
            HttpHeaders.AUTHORIZATION: "Bearer ${requestProperties.apiToken}",
            HttpHeaders.CONTENT_TYPE: ContentType.JSON.value,
            HttpHeaders.ACCEPT: ContentType.JSON.value
          },
          body: jsonEncode(permissions));
      if (response != null && response.statusCode == 200) {
        return true;
      }
      return false;
    } on Exception {
      print('Error while retrieving relevant medical queries!');
      return false;
    }
  }
}
