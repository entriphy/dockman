import 'package:dockman/api/api.dart';
import 'package:dockman/extensions/file_size.dart';
import 'package:dockman/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ImageTile extends HookWidget {
  final PortainerEndpoint environment;
  final PortainerImage image;
  final bool used;

  const ImageTile({
    super.key,
    required this.environment,
    required this.image,
    this.used = false,
  });

  @override
  Widget build(BuildContext context) {
    final removing = useState(false);

    return ListTile(
      title: Row(
        spacing: 8.0,
        children: [
          if (!used)
            const Chip(
              label: Text("Unused"),
              labelPadding: EdgeInsets.all(0.0),
            ),
          Chip(
            label: Text(image.size.fileSize()),
            labelPadding: const EdgeInsets.all(0.0),
          ),
          Expanded(
            child: Text(
              image.id.substring(7, 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Created ${image.created.toLocal().toString()}"),
          if (image.repoTags.isNotEmpty) Text("Tag: ${image.repoTags.first}")
        ],
      ),
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
                      await api.deleteImage(environment.id, image.id);
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
