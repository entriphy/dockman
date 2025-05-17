import 'dart:convert';
import 'dart:typed_data';

enum PortainerLogType { out, err }

class PortainerLog {
  PortainerLogType type;
  String message;
  DateTime? timestamp;

  PortainerLog({
    required this.type,
    required this.message,
    this.timestamp,
  });

  static List<PortainerLog> parseLogs(Uint8List data,
      [bool parseTimestamps = false]) {
    final type = data[0];
    List<PortainerLog> logs = [];
    if ({1, 2}.contains(type)) {
      for (int i = 0; i < data.lengthInBytes; i++) {
        final type = data[i] == 1 ? PortainerLogType.out : PortainerLogType.err;
        final size = (data[i + 4] << 24) |
            (data[i + 5] << 16) |
            (data[i + 6] << 8) |
            (data[i + 7]);
        i += 8;
        String text = utf8.decode(data.sublist(i, i + size));
        DateTime? timestamp;
        if (parseTimestamps) {
          timestamp = DateTime.tryParse(text.substring(0, 30));
          if (timestamp != null) {
            text = text.substring(31);
          }
        }
        final log = PortainerLog(
          type: type,
          message: text,
          timestamp: timestamp,
        );
        logs.add(log);
        i += size - 1;
      }
    } else {
      logs.addAll(
        utf8.decode(data).split("\n").map(
              (log) => PortainerLog(
                type: PortainerLogType.out,
                message: log,
                timestamp: null,
              ),
            ),
      );
    }
    return logs;
  }
}
