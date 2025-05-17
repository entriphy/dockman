import 'package:dockman/hole_material_page_route.dart';
import 'package:dockman/pages/home.dart';
import 'package:dockman/preferences.dart';
import 'package:dockman/views/connection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WelcomePage extends HookWidget {
  const WelcomePage({super.key});

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
    final enableBiometrics = useState(false);
    final connection = useState<DockerConnection?>(null);
    final color = Theme.of(context).colorScheme.onSurface;

    final pages = [
      PageViewModel(
        title: "Welcome!",
        body:
            "Dockman (Docker Manager) is a remote for Docker using Portainer.",
        image: Center(
          child: SvgPicture.asset(
            "assets/dockman.svg",
            width: 150.0,
            height: 150.0,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
      PageViewModel(
        title: "Install Portainer",
        bodyWidget: Column(
          spacing: 8.0,
          children: [
            const Text(
              "This app requires Portainer to function.\nFollow the instructions on the host where Docker is installed and create an access token:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: () => launchUrlString("https://portainer.io/install"),
              child: const Text(
                "https://portainer.io/install",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FilledButton(
              onPressed: () async {
                final res = await showDialog<DockerConnection>(
                  context: context,
                  builder: (context) => const ConnectionDialog(),
                );
                connection.value = res;
              },
              child: const Text("Connect"),
            ),
            if (connection.value != null)
              Text(
                "Connected to ${connection.value!.host}",
                textAlign: TextAlign.center,
              ),
          ],
        ),
        image: Center(
          child: SvgPicture.asset(
            "assets/portainer.svg",
            width: 150.0,
            height: 150.0,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
      PageViewModel(
        title: "Biometrics",
        bodyWidget: Column(
          spacing: 8.0,
          children: [
            const Text(
              "You can optionally enable biometric authentication upon opening this app.",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: enableBiometrics.value,
                  onChanged: (bool? value) async {
                    if (value == true && !await _checkBiometrics(context)) {
                      return;
                    }
                    enableBiometrics.value = value!;
                  },
                ),
                const Text(
                  "Enable biometrics",
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
                )
              ],
            )
          ],
        ),
        image: const Center(
          child: Icon(
            Icons.fingerprint,
            size: 150.0,
          ),
        ),
      )
    ];

    return SafeArea(
      top: false,
      child: IntroductionScreen(
        pages: pages,
        done: const Text("Done"),
        canProgress: (page) {
          return page == 1 ? connection.value != null : true;
        },
        next: const Text("Next"),
        onDone: () async {
          await Preferences.setConnection(
              connection.value!.host, connection.value!.token);
          await Preferences.setBiometrics(enableBiometrics.value);
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              HoleMaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        },
      ),
    );
  }
}
