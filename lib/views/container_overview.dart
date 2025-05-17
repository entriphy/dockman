import 'package:dockman/api/api.dart';
import 'package:dockman/extensions/portainer.dart';
import 'package:dockman/preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

const _statusTextStyle = TextStyle(fontWeight: FontWeight.bold);

class ContainerOverview extends StatefulWidget {
  final DockerConnection connection;
  final PortainerContainer container;

  const ContainerOverview({
    super.key,
    required this.connection,
    required this.container,
  });

  @override
  State<ContainerOverview> createState() => _ContainerOverviewState();
}

class _ContainerOverviewState extends State<ContainerOverview> {
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
      final api = widget.connection.createAPI();
      await api.postContainer(
          widget.connection.endpoint, widget.container.id, action);
      await Future.delayed(const Duration(seconds: 1));
      final container = await api.getContainer(
          widget.connection.endpoint, widget.container.id);
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 16.0,
          children: [
            Text("Actions", style: Theme.of(context).textTheme.headlineLarge),
            Chip(
              label: Text(widget.container.state.toString(),
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: widget.container.state.color
                  .harmonizeWith(Theme.of(context).colorScheme.primary),
            ),
            if (_action) const CircularProgressIndicator(),
          ],
        ),
        Row(
          spacing: 8.0,
          mainAxisAlignment: MainAxisAlignment.center,
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
        Text("Info", style: Theme.of(context).textTheme.headlineLarge),
        Table(
          border: TableBorder.all(color: Colors.grey.shade700),
          columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              const Text(
                "ID",
                textAlign: TextAlign.center,
                style: _statusTextStyle,
              ),
              Text(
                widget.container.id,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
            TableRow(children: [
              const Text(
                "Name",
                textAlign: TextAlign.center,
                style: _statusTextStyle,
              ),
              Text(
                widget.container.names[0].substring(1),
                textAlign: TextAlign.center,
              ),
            ]),
            TableRow(children: [
              const Text(
                "Image",
                textAlign: TextAlign.center,
                style: _statusTextStyle,
              ),
              Text(
                widget.container.image,
                textAlign: TextAlign.center,
              ),
            ]),
            TableRow(children: [
              const Text(
                "Created",
                textAlign: TextAlign.center,
                style: _statusTextStyle,
              ),
              Text(
                widget.container.created.toLocal().toString(),
                textAlign: TextAlign.center,
              ),
            ]),
          ],
        ),
        Text("Ports", style: Theme.of(context).textTheme.headlineLarge),
        ...widget.container.ports.map(
          (port) => port.ip != null
              ? Text(
                  "• ${port.ip}:${port.publicPort!} → ${port.privatePort}/${port.type}")
              : Text(
                  "• ${port.privatePort}/${port.type}",
                  style: TextStyle(color: Theme.of(context).disabledColor),
                ),
        )
      ],
    );
  }
}
