class PortainerEndpoint {
  int id;
  String name;
  String url;
  List<PortainerEndpointSnapshot> snapshots;

  PortainerEndpoint(Map<String, dynamic> json)
      : id = json["Id"],
        name = json["Name"],
        url = json["URL"],
        snapshots = json["Snapshots"]
            .map<PortainerEndpointSnapshot>(
                (port) => PortainerEndpointSnapshot(port))
            .toList();
}

class PortainerEndpointSnapshot {
  String dockerVersion;
  int imageCount;
  int volumeCount;
  int totalCPU;
  int totalMemory;
  int runningContainerCount;
  int healthyContainerCount;
  int unhealthyContainerCount;
  int stoppedContainerCount;
  int stackCount;

  PortainerEndpointSnapshot(Map<String, dynamic> json)
      : dockerVersion = json["DockerVersion"],
        imageCount = json["ImageCount"],
        volumeCount = json["VolumeCount"],
        totalCPU = json["TotalCPU"],
        totalMemory = json["TotalMemory"],
        runningContainerCount = json["RunningContainerCount"],
        healthyContainerCount = json["HealthyContainerCount"],
        unhealthyContainerCount = json["UnhealthyContainerCount"],
        stoppedContainerCount = json["StoppedContainerCount"],
        stackCount = json["StackCount"];
}
