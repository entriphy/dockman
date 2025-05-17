import 'package:dockman/api/api.dart';
import 'package:dockman/preferences.dart';
import 'package:dockman/views/container_tile.dart';
import 'package:flutter/material.dart';

class ContainersList extends StatelessWidget {
  final PortainerEndpoint environment;

  const ContainersList({super.key, required this.environment});

  Future<List<PortainerContainer>> _fetchContainers() async {
    final api = Preferences.getConnection()!.createAPI();
    final containers = await api.getContainers(environment.id);
    containers.sort((a, b) => a.names[0].compareTo(b.names[0]));
    return containers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchContainers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return snapshot.requireData.isEmpty
              ? const Center(child: Text("No containers found."))
              : ListView(
                  children: snapshot.data!
                      .map(
                        (container) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ContainerTile(
                            environment: environment,
                            container: container,
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
