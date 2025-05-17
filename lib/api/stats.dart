class PortainerStats {
  String id;
  String name;
  DateTime preread;
  DateTime read;
  PortainerMemoryStats memoryStats;
  PortainerCpuStats cpuStats;
  Map<String, PortainerNetworkStats> networks;

  PortainerStats(Map<String, dynamic> stats)
      : id = stats["id"],
        name = stats["name"],
        preread = DateTime.parse(stats["preread"]),
        read = DateTime.parse(stats["read"]),
        memoryStats = PortainerMemoryStats(stats["memory_stats"]),
        cpuStats = PortainerCpuStats(stats["cpu_stats"]),
        networks = (stats["networks"] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, PortainerNetworkStats(v)));
}

class PortainerMemoryStats {
  int usage;
  int limit;

  PortainerMemoryStats(Map<String, dynamic> stats)
      : usage = stats["usage"],
        limit = stats["limit"];
}

class PortainerCpuStats {
  int onlineCpus;
  int systemCpuUsage;
  PortainerCpuUsageStats cpuUsage;

  PortainerCpuStats(Map<String, dynamic> stats)
      : onlineCpus = stats["online_cpus"],
        systemCpuUsage = stats["system_cpu_usage"],
        cpuUsage = PortainerCpuUsageStats(stats["cpu_usage"]);
}

class PortainerCpuUsageStats {
  int totalUsage;
  int usageInKernelmode;
  int usageInUsermode;

  PortainerCpuUsageStats(Map<String, dynamic> stats)
      : totalUsage = stats["total_usage"],
        usageInKernelmode = stats["usage_in_kernelmode"],
        usageInUsermode = stats["usage_in_usermode"];
}

class PortainerNetworkStats {
  int rxBytes;
  int rxDropped;
  int rxErrors;
  int rxPackets;
  int txBytes;
  int txDropped;
  int txErrors;
  int txPackets;

  PortainerNetworkStats(Map<String, dynamic> stats)
      : rxBytes = stats["rx_bytes"],
        rxDropped = stats["rx_dropped"],
        rxErrors = stats["rx_errors"],
        rxPackets = stats["rx_packets"],
        txBytes = stats["tx_bytes"],
        txDropped = stats["tx_dropped"],
        txErrors = stats["tx_errors"],
        txPackets = stats["tx_packets"];
}
