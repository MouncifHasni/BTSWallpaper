import 'package:flutter/material.dart';

Color globaleSelectedItembackgroundColor = Colors.grey.shade900;

class ThemeProvider extends ChangeNotifier{
  ThemeMode themeMode = ThemeMode.dark;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn){
    themeMode = isOn?ThemeMode.dark:ThemeMode.light;
    notifyListeners();
  }

}

class MyThemes{

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    backgroundColor: Colors.black,
    splashColor: Colors.black,
    colorScheme: ColorScheme.highContrastDark(),
    appBarTheme: AppBarTheme(backgroundColor: Colors.black54)
  

  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.black,
    colorScheme: ColorScheme.light()
  );


}