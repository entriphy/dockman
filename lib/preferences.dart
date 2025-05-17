import 'dart:convert';

import 'package:dockman/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
    // await _instance!.clear();
  }

  static List<DockerConnection> getConnections() {
    final connections = _instance!.getStringList("connections");
    if (connections != null) {
      return connections
          .map((e) => DockerConnection.fromJson(json.decode(e)))
          .toList();
    } else {
      return [];
    }
  }

  static Future<void> addConnection(DockerConnection connection) async {
    final connections = _instance!.getStringList("connections") ?? [];
    connections.add(json.encode(connection.toJson()));
    await _instance!.setStringList("connections", connections);
  }

  static Future<void> deleteConnection(int i) async {
    final connections = _instance!.getStringList("connections") ?? [];
    connections.removeAt(i);
    await _instance!.setStringList("connections", connections);
  }

  static DockerConnection? getConnection() {
    final host = _instance!.getString("host");
    final token = _instance!.getString("token");
    if (host == null || token == null) {
      return null;
    } else {
      return DockerConnection("", host, token);
    }
  }

  static Future<void> setConnection(String host, String token) async {
    await _instance!.setString("host", host);
    await _instance!.setString("token", token);
  }

  static bool getBiometrics() {
    return _instance!.getBool("biometrics") ?? false;
  }

  static Future<void> setBiometrics(bool value) async {
    await _instance!.setBool("biometrics", value);
  }
}

class DockerConnection {
  String name;
  String host;
  String token;
  int endpoint = 0;

  DockerConnection(this.name, this.host, this.token);

  PortainerAPI createAPI() {
    return PortainerAPI(host, token);
  }

  factory DockerConnection.fromJson(Map<String, dynamic> json) =>
      DockerConnection(json["name"], json["host"], json["token"]);

  Map<String, dynamic> toJson() => {"name": name, "host": host, "token": token};
}
