import 'package:dockman/hole_material_page_route.dart';
import 'package:dockman/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationPage extends HookWidget {
  const AuthenticationPage({super.key});

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

  Future<void> authenticate(BuildContext context) async {
    if (await _checkBiometrics(context) && context.mounted) {
      Navigator.pushReplacement(
        context,
        HoleMaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final didAuth = useRef(false);
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (!didAuth.value && context.mounted) {
        didAuth.value = true;
        authenticate(context);
      }
    });

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.0,
          children: [
            Text(
              "Authenticate",
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              "Biometric authentication is enabled.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            IconButton(
              icon: const Icon(Icons.fingerprint, size: 72.0),
              onPressed: () => authenticate(context),
            )
          ],
        ),
      ),
    );
  }
}
