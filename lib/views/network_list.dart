import 'package:dockman/api/api.dart';
import 'package:dockman/preferences.dart';
import 'package:dockman/views/network_tile.dart';
import 'package:flutter/material.dart';

class NetworkList extends StatelessWidget {
  final PortainerEndpoint environment;

  const NetworkList({super.key, required this.environment});

  Future<List<PortainerNetwork>> _fetchNetworks() async {
    final api = Preferences.getConnection()!.createAPI();
    final networks = await api.getNetworks(environment.id);
    return networks;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchNetworks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return snapshot.requireData.isEmpty
              ? const Center(child: Text("No networks found."))
              : ListView(
                  children: snapshot.data!
                      .map(
                        (network) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NetworkTile(
                            environment: environment,
                            network: network,
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
