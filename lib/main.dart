import 'package:dockman/firebase_options.dart';
import 'package:dockman/pages/auth.dart';
import 'package:dockman/pages/home.dart';
import 'package:dockman/pages/welcome.dart';
import 'package:dockman/preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          Color color = const Color.fromARGB(255, 29, 99, 237);
          lightColorScheme = ColorScheme.fromSeed(seedColor: color);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: color,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          home:
              Preferences.getConnection() == null
                  ? const WelcomePage()
                  : Preferences.getBiometrics()
                  ? const AuthenticationPage()
                  : const HomePage(),
          theme: ThemeData(colorScheme: lightColorScheme),
          darkTheme: ThemeData(colorScheme: darkColorScheme),
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
