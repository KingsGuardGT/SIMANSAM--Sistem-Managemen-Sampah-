import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppThemeData {
  final Color primaryColor = Color.fromRGBO(34, 111, 39, 1);
  final Color secondaryColor = Colors.grey.shade900;
  final Color accentColor = Color.fromRGBO(50, 163, 57, 1);
  final Color redColor = Colors.red;
  final Color blueColor = Colors.blue;
  final Color deepBlueColor = Colors.blue.shade800;
  final Color yellowColor = Colors.yellow;
  final Color whiteColor = Colors.white;
  final Color greyColor = Colors.grey;
  final Color grey200Color = Colors.grey.shade200;

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Color.fromRGBO(34, 111, 39, 1),
    fontFamily: 'Open Sans',
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.grey.shade900,
    ),
    appBarTheme: AppBarTheme(color: Colors.white, elevation: 0.0),
    iconTheme: IconThemeData(color: Colors.grey.shade900),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 96.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
      labelSmall: TextStyle(fontSize: 10.0, fontWeight: FontWeight.normal),
    ), colorScheme: ColorScheme.light().copyWith(background: Colors.grey.shade900).copyWith(secondary: Color.fromRGBO(50, 163, 57, 1)),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColor: Color.fromRGBO(34, 111, 39, 1),
    fontFamily: 'Open Sans',
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.grey.shade900,
    ),
    appBarTheme: AppBarTheme(color: Colors.grey.shade900, elevation: 0.0),
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 96.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
      labelSmall: TextStyle(fontSize: 10.0, fontWeight: FontWeight.normal),
    ), colorScheme: ColorScheme.dark().copyWith(background: Colors.grey.shade900).copyWith(secondary: Color.fromRGBO(50, 163, 57, 1)),
  );
}
