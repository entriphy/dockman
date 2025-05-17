import 'package:dockman/api/api.dart';
import 'package:dockman/preferences.dart';
import 'package:dockman/views/environment_tile.dart';
import 'package:flutter/material.dart';

class EnvironmentList extends StatelessWidget {
  const EnvironmentList({super.key});

  Future<List<PortainerEndpoint>> _fetchEndpoints() async {
    final api = Preferences.getConnection()!.createAPI();
    final endpoints = await api.getEndpoints();
    return endpoints;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchEndpoints(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return snapshot.requireData.isEmpty
              ? const Center(child: Text("No environments found."))
              : ListView(
                  children: snapshot.data!
                      .map(
                        (endpoint) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: EnvironmentTile(
                            endpoint: endpoint,
                          ),
                        ),
                      )
                      .toList(),
                );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
