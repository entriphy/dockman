class PortainerNetwork {
  DateTime created;
  String driver;
  String id;
  String name;
  String scope;
  PortainerNetworkPortainer portainer;
  PortainerNetworkIPAM ipam;

  PortainerNetwork(Map<String, dynamic> network)
      : created = DateTime.parse(network["Created"]),
        driver = network["Driver"],
        id = network["Id"],
        name = network["Name"],
        scope = network["Scope"],
        portainer = PortainerNetworkPortainer(network["Portainer"]),
        ipam = PortainerNetworkIPAM(network["IPAM"]);
}

class PortainerNetworkPortainer {
  PortainerNetworkResourceControl resourceControl;

  PortainerNetworkPortainer(Map<String, dynamic> portainer)
      : resourceControl =
            PortainerNetworkResourceControl(portainer["ResourceControl"]);
}

class PortainerNetworkResourceControl {
  int id;
  String resourceId;
  bool public;
  bool system;

  PortainerNetworkResourceControl(Map<String, dynamic> resourceControl)
      : id = resourceControl["Id"],
        resourceId = resourceControl["ResourceId"],
        public = resourceControl["Public"],
        system = resourceControl["System"];
}

class PortainerNetworkIPAM {
  String driver;
  List<PortainerNetworkIPAMConfig>? config;

  PortainerNetworkIPAM(Map<String, dynamic> ipam)
      : driver = ipam["Driver"],
        config = ipam["Config"]
            ?.map<PortainerNetworkIPAMConfig>(
                (conf) => PortainerNetworkIPAMConfig(conf))
            .toList();
}

class PortainerNetworkIPAMConfig {
  String gateway;
  String subnet;

  PortainerNetworkIPAMConfig(Map<String, dynamic> config)
      : gateway = config["Gateway"],
        subnet = config["Subnet"];
}
