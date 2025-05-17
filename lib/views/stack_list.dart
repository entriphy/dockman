import 'package:dockman/api/api.dart';
import 'package:dockman/preferences.dart';
import 'package:dockman/views/stack_tile.dart';
import 'package:flutter/material.dart';

class StackList extends StatelessWidget {
  final PortainerEndpoint environment;

  const StackList({super.key, required this.environment});

  Future<List<PortainerStack>> _fetchStacks() async {
    final api = Preferences.getConnection()!.createAPI();
    final stacks = await api.getStacks(environment.id);
    return stacks;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchStacks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return snapshot.requireData.isEmpty
              ? const Center(child: Text("No stacks found."))
              : ListView(
                  children: snapshot.data!
                      .map(
                        (stack) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StackTile(
                            environment: environment,
                            stack: stack,
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
