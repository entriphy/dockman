import 'package:dockman/preferences.dart';
import 'package:dockman/views/connection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:local_auth/local_auth.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  Future<bool> _checkBiometrics(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();

    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    if (!canAuthenticate) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "Biometric authentication is not supported on this device."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              )
            ],
          ),
        );
      }

      return false;
    }

    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    if (!availableBiometrics.contains(BiometricType.strong)) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "No biometric authentication methods detected. To use biometric authentication, configure it in system settings."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              )
            ],
          ),
        );
      }

      return false;
    }

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      return didAuthenticate;
    } catch (e) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(
                "An unknown error occurred when setting up biometric authentication: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              )
            ],
          ),
        );
      }

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricAuthentication = useState(Preferences.getBiometrics());
    final connection = useState(Preferences.getConnection()!);

    return Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: const Text("Biometric authentication"),
                subtitle: const Text(
                    "Require biometric authentication upon starting the app."),
                leading: const Icon(Icons.fingerprint),
                trailing: Checkbox(
                  value: biometricAuthentication.value,
                  onChanged: (bool? value) async {
                    if (value == true && !await _checkBiometrics(context)) {
                      return;
                    }
                    await Preferences.setBiometrics(value!);
                    biometricAuthentication.value = value;
                  },
                ),
              ),
              ListTile(
                title: const Text("Portainer Connection"),
                subtitle: Text(
                    "Change Portainer connection info.\nCurrent: ${connection.value.host}"),
                leading: const Icon(Icons.settings_ethernet),
                onTap: () async {
                  final res = await showDialog<DockerConnection>(
                    context: context,
                    builder: (context) => const ConnectionDialog(),
                  );
                  if (res != null) {
                    connection.value = res;
                    await Preferences.setConnection(res.host, res.token);
                  }
                },
              )
            ],
          ).toList(),
        ));
  }
}
