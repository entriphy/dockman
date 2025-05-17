import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dockman/api/container.dart';
import 'package:dockman/api/endpoint.dart';
import 'package:dockman/api/image.dart';
import 'package:dockman/api/log.dart';
import 'package:dockman/api/network.dart';
import 'package:dockman/api/settings.dart';
import 'package:dockman/api/stack.dart';
import 'package:dockman/api/stats.dart';

export 'package:dockman/api/container.dart';
export 'package:dockman/api/endpoint.dart';
export 'package:dockman/api/image.dart';
export 'package:dockman/api/log.dart';
export 'package:dockman/api/network.dart';
export 'package:dockman/api/settings.dart';
export 'package:dockman/api/stack.dart';
export 'package:dockman/api/stats.dart';

class PortainerAPI {
  Dio dio;
  String token;

  PortainerAPI(String uri, this.token)
      : dio = Dio(
          BaseOptions(
            baseUrl: Uri.parse(uri).replace(path: "/api").toString(),
            headers: {"X-API-Key": token},
          ),
        );

  Future<List<PortainerEndpoint>> getEndpoints() async {
    Response<List<dynamic>> res = await dio.get(
      "/endpoints",
    );
    List<Map<String, dynamic>> endpoints =
        res.data!.map((e) => e as Map<String, dynamic>).toList();
    return endpoints.map((e) => PortainerEndpoint(e)).toList();
  }

  Future<List<PortainerContainer>> getContainers(int endpoint,
      {String? filters}) async {
    Response<List<dynamic>> res = await dio.get(
      "/endpoints/$endpoint/docker/containers/json",
      queryParameters: {
        "all": "true",
        if (filters != null) "filters": filters,
      },
    );
    List<Map<String, dynamic>> containers =
        res.data!.map((e) => e as Map<String, dynamic>).toList();
    return containers.map((e) => PortainerContainer(e)).toList();
  }

  Future<PortainerContainerDetail> getContainer(
    int endpoint,
    String id,
  ) async {
    Response<Map<String, dynamic>> res = await dio.get(
      "/endpoints/$endpoint/docker/containers/$id/json",
    );
    return PortainerContainerDetail(res.data!);
  }

  Future<void> postContainer(
    int endpoint,
    String id,
    String action,
  ) async {
    Response<String> res = await dio.post(
      "/endpoints/$endpoint/docker/containers/$id/$action",
      options: Options(validateStatus: (status) => true),
    );
    if (res.statusCode != 204) {
      throw res.data!;
    }
  }

  Future<List<PortainerLog>> getContainerLogs(int endpoint, String id,
      {bool timestamps = false}) async {
    Response<Uint8List> res = await dio.get(
      "/endpoints/$endpoint/docker/containers/$id/logs",
      queryParameters: {
        "since": "0",
        "stderr": "1",
        "stdout": "1",
        "tail": "100",
        "timestamps": timestamps ? "1" : "0"
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return PortainerLog.parseLogs(res.data!, timestamps);
  }

  Future<PortainerApiSettings> getApiSettings() async {
    Response<Map<String, dynamic>> res = await dio.get(
      "/settings/public",
    );
    return PortainerApiSettings(res.data!);
  }

  Future<List<PortainerImage>> getImages(int endpoint) async {
    Response<List<dynamic>> res = await dio.get(
      "/endpoints/$endpoint/docker/images/json",
      queryParameters: {"all": "true"},
    );
    List<Map<String, dynamic>> images =
        res.data!.map((e) => e as Map<String, dynamic>).toList();
    return images.map((e) => PortainerImage(e)).toList();
  }

  Future<void> deleteImage(int endpoint, String id) async {
    Response<List<dynamic>> res = await dio.delete(
      "/endpoints/$endpoint/docker/images/$id",
    );
    if (res.statusCode != 204) {
      throw res.data!;
    }
  }

  Future<PortainerStats> getStats(int endpoint, String id) async {
    Response<Map<String, dynamic>> res = await dio.get(
        "/endpoints/$endpoint/docker/containers/$id/stats",
        queryParameters: {"stream": false});
    return PortainerStats(res.data!);
  }

  Future<List<PortainerNetwork>> getNetworks(int endpoint) async {
    Response<List<dynamic>> res = await dio.get(
      "/endpoints/$endpoint/docker/networks",
    );
    List<Map<String, dynamic>> networks =
        res.data!.map((e) => e as Map<String, dynamic>).toList();
    return networks.map((e) => PortainerNetwork(e)).toList();
  }

  Future<void> deleteNetwork(int endpoint, String id) async {
    Response<List<dynamic>> res = await dio.delete(
      "/endpoints/$endpoint/docker/networks/$id",
    );
    if (res.statusCode != 204) {
      throw res.data!;
    }
  }

  Future<List<PortainerStack>> getStacks(int endpoint) async {
    Response<List<dynamic>> res = await dio.get(
      "/stacks",
      queryParameters: {"filters": '{"EndpointID": $endpoint}'},
    );
    List<Map<String, dynamic>> stacks =
        res.data!.map((e) => e as Map<String, dynamic>).toList();
    return stacks.map((e) => PortainerStack(e)).toList();
  }
}
