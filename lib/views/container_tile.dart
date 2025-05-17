import 'package:dockman/api/api.dart';
import 'package:dockman/extensions/portainer.dart';
import 'package:dockman/pages/logs.dart';
import 'package:dockman/pages/stats.dart';
import 'package:dockman/preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class ContainerTile extends StatefulWidget {
  final PortainerEndpoint environment;
  final PortainerContainer container;

  const ContainerTile({
    super.key,
    required this.environment,
    required this.container,
  });

  @override
  State<ContainerTile> createState() => _ContainerTileState();
}

class _ContainerTileState extends State<ContainerTile> {
  bool _action = false;

  void _containerAction(String action, [bool dialog = false]) async {
    if (dialog) {
      final res = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm"),
          content: Text("Are you sure you want to $action the container?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
            )
          ],
        ),
      );
      if (res != true) return;
    }

    setState(() => _action = true);
    try {
      final api = Preferences.getConnection()!.createAPI();
      await api.postContainer(
          widget.environment.id, widget.container.id, action);
      await Future.delayed(const Duration(seconds: 1));
      final container =
          await api.getContainer(widget.environment.id, widget.container.id);
      setState(() => widget.container.state =
          PortainerContainerState.values.byName(container.state.status));
      setState(() => _action = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Success!")));
      }
    } catch (e) {
      setState(() => _action = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Error: $e",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.container.names[0].substring(1)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.container.image,
            overflow: TextOverflow.ellipsis,
          ),
          Text(widget.container.status),
        ],
      ),
      backgroundColor: Theme.of(context)
          .colorScheme
          .onInverseSurface
          .harmonizeWith(widget.container.state.color),
      shape: Border(
        left: BorderSide(
          color: widget.container.state.color
              .harmonizeWith(Theme.of(context).colorScheme.primary),
          width: 8.0,
        ),
      ),
      collapsedShape: Border(
        left: BorderSide(
          color: widget.container.state.color
              .harmonizeWith(Theme.of(context).colorScheme.primary),
          width: 8.0,
        ),
      ),
      trailing: _action ? const CircularProgressIndicator() : null,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4.0,
          children: [
            Chip(label: Text("Created ${widget.container.created.toLocal()}")),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4.0,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogsPage(
                    environment: widget.environment,
                    container: widget.container,
                  ),
                ),
              ),
              label: const Text("Logs"),
              icon: const Icon(Icons.description),
            ),
            FilledButton.icon(
              onPressed:
                  widget.container.state == PortainerContainerState.running
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatsPage(
                                environment: widget.environment,
                                container: widget.container,
                              ),
                            ),
                          )
                      : null,
              label: const Text("Stats"),
              icon: const Icon(Icons.query_stats),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8.0,
          children: [
            FilledButton.icon(
              onPressed: _action ||
                      widget.container.state != PortainerContainerState.exited
                  ? null
                  : () => _containerAction("start", true),
              label: const Text("Start"),
              icon: const Icon(Icons.play_arrow),
            ),
            FilledButton.icon(
              onPressed: _action ||
                      widget.container.state == PortainerContainerState.exited
                  ? null
                  : () => _containerAction("restart", true),
              label: const Text("Restart"),
              icon: const Icon(Icons.restart_alt),
            ),
            FilledButton.icon(
              onPressed: _action ||
                      widget.container.state != PortainerContainerState.running
                  ? null
                  : () => _containerAction("stop", true),
              label: const Text("Stop"),
              icon: const Icon(Icons.stop),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8.0,
          children: [
            FilledButton.icon(
              onPressed: _action ||
                      widget.container.state != PortainerContainerState.running
                  ? null
                  : () => _containerAction("pause", false),
              label: const Text("Pause"),
              icon: const Icon(Icons.pause),
            ),
            FilledButton.icon(
              onPressed: _action ||
                      widget.container.state != PortainerContainerState.paused
                  ? null
                  : () => _containerAction("unpause", false),
              label: const Text("Resume"),
              icon: const Icon(Icons.start),
            ),
            FilledButton.icon(
              onPressed: _action ||
                      widget.container.state == PortainerContainerState.exited
                  ? null
                  : () => _containerAction("kill", true),
              label: const Text("Kill"),
              icon: const Icon(Icons.cancel),
            ),
          ],
        ),
      ],
    );
  }
}
