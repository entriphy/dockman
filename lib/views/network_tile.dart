import 'package:dockman/api/api.dart';
import 'package:dockman/extensions/portainer.dart';
import 'package:dockman/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NetworkTile extends HookWidget {
  final PortainerEndpoint environment;
  final PortainerNetwork network;

  const NetworkTile({
    super.key,
    required this.environment,
    required this.network,
  });

  @override
  Widget build(BuildContext context) {
    final removing = useState(false);

    return ListTile(
      title: Row(
        spacing: 8.0,
        children: [
          if (network.portainer.resourceControl.system)
            const Chip(
              label: Text("System"),
              labelPadding: EdgeInsets.all(0.0),
            ),
          Expanded(
            child: Text(
              network.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Created ${network.created.toLocal().toString()}"),
          Text("Driver: ${network.driver}"),
          if (network.ipam.config != null)
            ...network.ipam.config!.map((conf) => Text(
                "IPv${conf.subnet.contains(":") ? "6" : "4"} Subnet: ${conf.subnet}")),
          if (network.ipam.config != null)
            ...network.ipam.config!.map((conf) => Text(
                "IPv${conf.gateway.contains(":") ? "6" : "4"} Gateway: ${conf.gateway}")),
        ],
      ),
      leading: Icon(network.icon),
      trailing: removing.value
          ? const CircularProgressIndicator()
          : PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "remove",
                  child: Text("Remove"),
                )
              ],
              onSelected: (value) async {
                switch (value) {
                  case "remove":
                    final api = Preferences.getConnection()!.createAPI();
                    removing.value = true;
                    try {
                      await api.deleteNetwork(environment.id, network.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Success!")));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "Error: $e",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                        ));
                      }
                    }
                    removing.value = false;
                    break;
                }
              },
            ),
    );
  }
}
