import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helps store theme data with shared preferences and update app when changed
class SchemaThemeData with ChangeNotifier {
  int colorId;
  bool isDark;
  bool isMonochrome;

  // Creates new instance from shared preferences
  static Future<SchemaThemeData> fromSP() async {
    final sp = await SharedPreferences.getInstance();
    return SchemaThemeData(
      sp.getInt('colorId') ?? noteData.themeColorId,
      sp.getBool('isDark') ?? noteData.themeIsDark,
      sp.getBool('isMonochrome') ?? noteData.themeIsMonochrome,
    );
  }

  // If the theme has changed, set theme and notify the app so it can update
  void updateTheme() async {
    if (noteData.themeColorId != colorId ||
        noteData.themeIsDark != isDark ||
        noteData.themeIsMonochrome != isMonochrome) {
      final sp = await SharedPreferences.getInstance();
      colorId = noteData.themeColorId;
      sp.setInt('colorId', colorId);
      isDark = noteData.themeIsDark;
      sp.setBool('isDark', isDark);
      isMonochrome = noteData.themeIsMonochrome;
      sp.setBool('isMonochrome', isMonochrome);
      notifyListeners();
    }
  }

  // Temporary theme that will be changed back when updateTheme is called
  void tempTheme(
    int tempColorId,
    bool tempIsDark,
    bool tempIsMonochrome,
  ) async {
    colorId = tempColorId;
    isDark = tempIsDark;
    isMonochrome = tempIsMonochrome;
    notifyListeners();
  }

  // Color helper function
  Color colorWithSaturationLightness(
    Color color,
    double? saturation,
    double? lightness,
    bool isMonochrome,
  ) {
    HSLColor newColor = HSLColor.fromColor(color);
    if (saturation != null && !isMonochrome) {
      newColor = newColor.withSaturation(saturation);
    }
    if (lightness != null) {
      newColor = newColor.withLightness(lightness);
    }
    return newColor.toColor();
  }

  // Creates ThemeData from whether the theme is dark and a color swatch
  ThemeData getTheme() {
    MaterialColor color = Constants.themeColorOptions[colorId];
    // TODO: comment
    if (isDark) {
      Color canvasColor = colorWithSaturationLightness(
        color,
        0.05,
        0.15,
        isMonochrome,
      );
      Color backgroundColor = colorWithSaturationLightness(
        color,
        0.4,
        0.22,
        isMonochrome,
      );
      Color noteColor = Color.alphaBlend(
        backgroundColor.withOpacity(Constants.noteOpacity),
        canvasColor,
      );
      return ThemeData(
        brightness: Brightness.dark,
        primarySwatch: color,
        primaryColor: color,
        accentColor: color,
        backgroundColor: backgroundColor,
        canvasColor: canvasColor,
        dialogBackgroundColor: noteColor,
        appBarTheme: AppBarTheme(
          backgroundColor: canvasColor,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: Constants.appBarSize,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(Constants.dialogRadius),
            ),
          ),
        ),
        fontFamily: 'Roboto',
      );
    } else {
      Color canvasColor = colorWithSaturationLightness(
        color,
        1,
        0.99,
        isMonochrome,
      );
      Color backgroundColor = colorWithSaturationLightness(
        color,
        0.8,
        0.85,
        isMonochrome,
      );
      Color noteColor = Color.alphaBlend(
        backgroundColor.withOpacity(Constants.noteOpacity),
        canvasColor,
      );
      return ThemeData(
        brightness: Brightness.light,
        primarySwatch: color,
        primaryColor: color,
        accentColor: color,
        backgroundColor: backgroundColor,
        canvasColor: canvasColor,
        dialogBackgroundColor: noteColor,
        appBarTheme: AppBarTheme(
          backgroundColor: canvasColor,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: Constants.appBarSize,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(Constants.dialogRadius),
            ),
          ),
        ),
        fontFamily: 'Roboto',
      );
    }
  }

  // Returns whether color is monochrome color
  bool isMonochromeColor(int colorId) {
    return Constants.themeMonochromeColors
        .contains(Constants.themeColorOptions[colorId]);
  }

  SchemaThemeData(this.colorId, this.isDark, this.isMonochrome);
}

// Initial theme data
SchemaThemeData themeData = SchemaThemeData(
  noteData.themeColorId,
  noteData.themeIsDark,
  noteData.themeIsMonochrome,
);
