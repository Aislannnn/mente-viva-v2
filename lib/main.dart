import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'features/auth/presentation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  buildAppOverlayStyle(bool escuro) {
    return escuro
        ? SystemUiOverlayStyle.light.copyWith(
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        return ValueListenableBuilder<double>(
          valueListenable: escalaFonte,
          builder: (context, escala, _) {
            return ValueListenableBuilder<String>(
              valueListenable: tipoFonte,
              builder: (context, fonte, _) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: buildAppOverlayStyle(escuro),
                  child: MaterialApp(
                    title: 'Mente Viva',
                    debugShowCheckedModeBanner: false,
                    theme: buildAppTheme(escuro: escuro, tipoFonte: fonte),
                    builder: (context, child) {
                      final media = MediaQuery.of(context);
                      return MediaQuery(
                        data: media.copyWith(
                          textScaler: escala == 1.0
                              ? media.textScaler
                              : _PreferenceTextScaler(media.textScaler, escala),
                        ),
                        child: child!,
                      );
                    },
                    home: const LoadingScreen(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Applies the in-app preference without discarding the platform's scaler,
/// including nonlinear scaling on newer Android versions.
final class _PreferenceTextScaler extends TextScaler {
  const _PreferenceTextScaler(this.platform, this.preference);

  final TextScaler platform;
  final double preference;

  @override
  double scale(double fontSize) => platform.scale(fontSize) * preference;

  @override
  double get textScaleFactor => platform.scale(1) * preference;

  @override
  bool operator ==(Object other) =>
      other is _PreferenceTextScaler &&
      other.platform == platform &&
      other.preference == preference;

  @override
  int get hashCode => Object.hash(platform, preference);
}

