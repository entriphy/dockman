import 'package:dockman/api/api.dart';
import 'package:dockman/preferences.dart';
import 'package:dockman/views/image_tile.dart';
import 'package:flutter/material.dart';

class ImagesList extends StatelessWidget {
  final PortainerEndpoint environment;

  const ImagesList({super.key, required this.environment});

  Future<(List<PortainerImage>, Set<String>)> _fetchImages() async {
    final api = Preferences.getConnection()!.createAPI();
    final images = await api.getImages(environment.id);
    final containers = await api.getContainers(environment.id);
    final usedImages = containers.map((e) => e.imageId).toSet();
    return (images, usedImages);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchImages(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return snapshot.requireData.$1.isEmpty
              ? const Center(child: Text("No images found."))
              : ListView(
                  children: snapshot.data!.$1
                      .map(
                        (image) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ImageTile(
                            environment: environment,
                            image: image,
                            used: snapshot.data!.$2.contains(image.id),
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
