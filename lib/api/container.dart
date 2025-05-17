enum PortainerContainerState { running, exited, paused }

class PortainerContainer {
  String id;
  List<String> names;
  String image;
  String imageId;
  PortainerContainerState state;
  String status;
  List<PortainerContainerPort> ports;
  DateTime created;

  PortainerContainer(Map<String, dynamic> container)
      : id = container["Id"],
        names = List<String>.from(container["Names"]),
        image = container["Image"],
        imageId = container["ImageID"],
        state = PortainerContainerState.values.byName(container["State"]),
        status = container["Status"],
        ports = container["Ports"]
            .map<PortainerContainerPort>((port) => PortainerContainerPort(port))
            .toList(),
        created = DateTime.fromMillisecondsSinceEpoch(
          container["Created"] * 1000,
          isUtc: true,
        );
}

class PortainerContainerPort {
  int privatePort;
  int? publicPort;
  String type;
  String? ip;

  PortainerContainerPort(Map<String, dynamic> port)
      : privatePort = port["PrivatePort"],
        publicPort = port["PublicPort"],
        type = port["Type"],
        ip = port["IP"];
}

class PortainerContainerDetail {
  String id;
  DateTime created;
  PortainerContainerDetailState state;

  PortainerContainerDetail(Map<String, dynamic> container)
      : id = container["Id"],
        created = DateTime.parse(container["Created"]),
        state = PortainerContainerDetailState(container["State"]);
}

class PortainerContainerDetailState {
  // bool dead;
  // String error;
  // int exitCode;
  // DateTime finishedAt;
  // bool oomKilled;
  // bool paused;
  // int pid;
  // bool restarting;
  // bool running;
  // DateTime startedAt;
  String status;

  PortainerContainerDetailState(Map<String, dynamic> state)
      : status = state["Status"];
}
