import 'package:dockman/api/endpoint.dart';
import 'package:dockman/pages/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EnvironmentTile extends StatelessWidget {
  final PortainerEndpoint endpoint;

  const EnvironmentTile({super.key, required this.endpoint});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "${endpoint.name} (${endpoint.url})",
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Wrap(
        spacing: 8.0,
        children: [
          Chip(
              label: Text(
                  "${endpoint.snapshots.first.runningContainerCount} containers")),
          Chip(label: Text("${endpoint.snapshots.first.stackCount} stacks")),
          Chip(label: Text("${endpoint.snapshots.first.volumeCount} volumes")),
          Chip(label: Text("${endpoint.snapshots.first.imageCount} images")),
        ],
      ),
      leading: SvgPicture.asset(
        "assets/docker.svg",
        width: 40.0,
        height: 40.0,
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnvironmentPage(environment: endpoint),
          ),
        );
      },
    );
  }
}
