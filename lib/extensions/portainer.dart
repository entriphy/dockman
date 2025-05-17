import 'package:dockman/api/api.dart';
import 'package:flutter/material.dart';

extension StatusColor on PortainerContainerState {
  Color get color {
    switch (this) {
      case PortainerContainerState.running:
        return Colors.green;
      case PortainerContainerState.exited:
        return Colors.red;
      case PortainerContainerState.paused:
        return Colors.yellow;
    }
  }
}

extension NetworkIcon on PortainerNetwork {
  IconData get icon {
    switch (driver) {
      case "null":
        return Icons.question_mark;
      case "bridge":
        return Icons.network_ping;
      case "host":
        return Icons.computer;
      default:
        return Icons.question_mark;
    }
  }
}
