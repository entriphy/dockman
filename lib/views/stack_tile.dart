import 'package:dockman/api/api.dart';
import 'package:dockman/preferences.dart';
import 'package:dockman/views/container_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StackTile extends HookWidget {
  final PortainerEndpoint environment;
  final PortainerStack stack;

  const StackTile({
    super.key,
    required this.environment,
    required this.stack,
  });

  @override
  Widget build(BuildContext context) {
    // final removing = useState(false);
    final api = Preferences.getConnection()!.createAPI();
    final result = useMemoized<Future<List<PortainerContainer>>?>(
        () => api.getContainers(
              environment.id,
              filters: '{"label":["com.docker.compose.project=${stack.name}"]}',
            ),
        []);
    final future = useFuture(result, preserveState: false);

    return ExpansionTile(
      // onExpansionChanged: (value) {
      //   if (value && result == null) {
      //     result =
      //   }
      // }
      childrenPadding: const EdgeInsets.all(8.0),
      title: Row(
        spacing: 8.0,
        children: [
          // Chip(
          //   label: Text(image.size.fileSize()),
          //   labelPadding: const EdgeInsets.all(0.0),
          // ),
          Expanded(
            child: Text(
              stack.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Created ${stack.creationDate.toLocal().toString()}"),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      children: future.hasError
          ? [Text("Error: ${future.error}")]
          : !future.hasData
              ? const [Center(child: CircularProgressIndicator())]
              : future.requireData
                  .map(
                    (container) => ContainerTile(
                      environment: environment,
                      container: container,
                    ),
                  )
                  .toList(),
      // trailing: removing.value
      //     ? const CircularProgressIndicator()
      //     : PopupMenuButton<String>(
      //         itemBuilder: (context) => [
      //           const PopupMenuItem(
      //             value: "remove",
      //             child: Text("Remove"),
      //           )
      //         ],
      //         onSelected: (value) async {
      //           switch (value) {
      //             case "remove":
      //               final api = Preferences.getConnection()!.createAPI();
      //               removing.value = true;
      //               try {
      //                 await api.deleteNetwork(environment.id, network.id);
      //                 if (context.mounted) {
      //                   ScaffoldMessenger.of(context).showSnackBar(
      //                       const SnackBar(content: Text("Success!")));
      //                 }
      //               } catch (e) {
      //                 if (context.mounted) {
      //                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //                     content: Text(
      //                       "Error: $e",
      //                       style: TextStyle(
      //                         color: Theme.of(context)
      //                             .colorScheme
      //                             .onErrorContainer,
      //                       ),
      //                     ),
      //                     backgroundColor:
      //                         Theme.of(context).colorScheme.errorContainer,
      //                   ));
      //                 }
      //               }
      //               removing.value = false;
      //               break;
      //           }
      //         },
      //       ),
    );
  }
}
