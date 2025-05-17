// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dockman/extensions/file_size.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:dockman/api/api.dart';
import 'package:dockman/preferences.dart';

void useInterval(Duration delay, VoidCallback callback) {
  final savedCallback = useRef(callback);
  savedCallback.value = callback;

  useEffect(() {
    final timer = Timer.periodic(delay, (_) => savedCallback.value());
    return timer.cancel;
  }, [delay]);
}

class DataPoint {
  DateTime read;
  double cpuUsage;
  int memoryUsage;
  int rx;
  int tx;

  DataPoint({
    required this.read,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.rx,
    required this.tx,
  });
}

class StatsPage extends HookWidget {
  final PortainerEndpoint environment;
  final PortainerContainer container;
  final List<DataPoint> data = [];

  StatsPage({super.key, required this.environment, required this.container});

  @override
  Widget build(BuildContext context) {
    final api = Preferences.getConnection()!.createAPI();
    final force = useState(false);
    useInterval(const Duration(seconds: 1), () async {
      final stats = await api.getStats(environment.id, container.id);
      data.add(DataPoint(
        read: stats.read,
        cpuUsage: stats.cpuStats.cpuUsage.totalUsage /
            stats.cpuStats.systemCpuUsage *
            100.0,
        memoryUsage: stats.memoryStats.usage,
        rx: stats.networks.values.first.rxBytes,
        tx: stats.networks.values.first.txBytes,
      ));
      if (context.mounted) force.value = !force.value;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Stats: ${container.names.first.substring(1)}"),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8.0,
          children: [
            Text(
              "CPU usage",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Expanded(
              child: LineChart(
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
                LineChartData(
                  minY: 0.0,
                  lineBarsData: [
                    LineChartBarData(
                        spots: data.indexed
                            .map((d) => FlSpot(d.$1.toDouble(), d.$2.cpuUsage))
                            .toList())
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            "${val.toStringAsFixed(2)}%",
                          ),
                        ),
                        reservedSize: 100,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              "RAM usage",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Expanded(
              child: LineChart(
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
                LineChartData(
                  minY: 0.0,
                  lineBarsData: [
                    LineChartBarData(
                        spots: data.indexed
                            .map((d) => FlSpot(
                                d.$1.toDouble(), d.$2.memoryUsage.toDouble()))
                            .toList())
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            val.fileSize(),
                          ),
                        ),
                        reservedSize: 100,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              "Network usage (aggregate)",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Expanded(
              child: LineChart(
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
                LineChartData(
                  minY: 0.0,
                  lineBarsData: [
                    LineChartBarData(
                      color: Colors.blue,
                      spots: data.indexed
                          .map((d) =>
                              FlSpot(d.$1.toDouble(), d.$2.rx.toDouble()))
                          .toList(),
                    ),
                    LineChartBarData(
                      color: Colors.red,
                      spots: data.indexed
                          .map((d) =>
                              FlSpot(d.$1.toDouble(), d.$2.tx.toDouble()))
                          .toList(),
                    )
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            val.fileSize(),
                          ),
                        ),
                        reservedSize: 100,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
