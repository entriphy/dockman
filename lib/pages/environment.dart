import 'package:dockman/api/endpoint.dart';
import 'package:dockman/views/container_list.dart';
import 'package:dockman/views/image_list.dart';
import 'package:dockman/views/network_list.dart';
import 'package:dockman/views/stack_list.dart';
import 'package:flutter/material.dart';

class EnvironmentPage extends StatefulWidget {
  final PortainerEndpoint environment;

  const EnvironmentPage({super.key, required this.environment});

  @override
  State<EnvironmentPage> createState() => _EnvironmentPageState();
}

class _EnvironmentPageState extends State<EnvironmentPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Environment: ${widget.environment.name}"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: "Containers",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: "Stacks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Images",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: "Networks",
          )
        ],
      ),
      body: switch (_selectedIndex) {
        0 => ContainersList(environment: widget.environment),
        1 => StackList(environment: widget.environment),
        2 => ImagesList(environment: widget.environment),
        3 => NetworkList(environment: widget.environment),
        _ => const Center(
            child: Text(
              "Unimplemented",
              textScaler: TextScaler.linear(1.5),
            ),
          )
      },
    );
  }
}
