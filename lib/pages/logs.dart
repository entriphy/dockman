import 'package:dockman/api/api.dart';
import 'package:dockman/preferences.dart';
import 'package:flutter/material.dart';

class LogsPage extends StatelessWidget {
  final PortainerEndpoint environment;
  final PortainerContainer container;

  const LogsPage({
    super.key,
    required this.environment,
    required this.container,
  });

  Future<List<PortainerLog>> _getLogs() async {
    final api = Preferences.getConnection()!.createAPI();
    return api.getContainerLogs(environment.id, container.id, timestamps: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logs: ${container.names[0].substring(1)}"),
      ),
      body: FutureBuilder(
        future: _getLogs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: snapshot.requireData.map(
                  (log) => ListTile(
                    title: SelectableText(
                      log.message,
                      style: const TextStyle(fontFamily: "monospace"),
                    ),
                    subtitle: log.timestamp != null
                        ? Text(log.timestamp!.toLocal().toString())
                        : null,
                  ),
                ),
              ).toList(),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
