import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/data/themeData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';

// Returns a column of content to put in the theme edit dialog from home page
class ThemeEditContent extends StatefulWidget {
  const ThemeEditContent();

  @override
  State<ThemeEditContent> createState() => _ThemeEditContentState();
}

class _ThemeEditContentState extends State<ThemeEditContent> {
  // Returns a button from the given text and function
  ElevatedButton themeModeButton(
    String text,
    bool isDark,
    bool isMonochrome,
    bool checkmark,
  ) {
    return ElevatedButton(
      // Changes theme to given mode
      onPressed: () {
        noteData.themeIsDark = isDark;
        noteData.themeIsMonochrome = isMonochrome;
        noteData.themeTimeUpdated = timestampNowRounded();
        themeData.updateTheme();
        noteData.updateData();
        setState(() {});
      },
      // Style determined by constants
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(
          Constants.themeEditSpacing * 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Constants.themeEditRadius,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: (checkmark
                ? [
                    Icon(
                      Icons.check,
                      color:
                          Theme.of(context).accentTextTheme.bodyMedium?.color,
                      size: Theme.of(context).textTheme.bodyText1?.fontSize,
                    ),
                    SizedBox(width: Constants.themeEditSpacing),
                  ]
                : <Widget>[]) +
            [
              Text(text),
            ],
      ),
    );
  }

  // Returns list of available theme modes for this color (checkmark beside
  // currently selected mode)
  List<Widget> themeModeButtons() {
    List<Widget> content = [];
    bool intenseMode = !themeData.isMonochromeColor(noteData.themeColorId) &&
        noteData.themeIsMonochrome;
    // Light mode button
    content.add(
      // Both isDark and isMonochrome are false (isMonochrome has no effect)
      themeModeButton(
        Constants.themeLightButton,
        false,
        false,
        !noteData.themeIsDark,
      ),
    );
    content.add(
      SizedBox(height: Constants.themeEditSpacing),
    );
    // Dark mode button
    content.add(
      // isDark is true, isMonochrome is dependent on color
      themeModeButton(
        Constants.themeDarkButton,
        true,
        themeData.isMonochromeColor(noteData.themeColorId),
        noteData.themeIsDark && !intenseMode,
      ),
    );
    content.add(
      SizedBox(height: Constants.themeEditSpacing),
    );
    if (!themeData.isMonochromeColor(noteData.themeColorId)) {
      // Intense mode button
      content.add(
        // Both isDark and isMonochrome are true for intense mode
        themeModeButton(
          Constants.themeIntenseButton,
          true,
          true,
          intenseMode,
        ),
      );
      content.add(
        SizedBox(height: Constants.themeEditSpacing),
      );
    }
    return content;
  }

  // Returns a grid of colored tiles (with tooltips) to choose a theme color
  GridView themeColorTiles() {
    return GridView.count(
      // Spacing and cross axis count (number of tiles in a row)
      crossAxisCount: Constants.themeEditCount,
      mainAxisSpacing: Constants.themeEditSpacing,
      crossAxisSpacing: Constants.themeEditSpacing,
      // Creates a tappable tile for each color option
      children: Constants.themeColorOptions.map((color) {
        int colorId = Constants.themeColorOptions.indexOf(color);
        // Tooltip with name of color
        return Tooltip(
          message: Constants.themeColorNames[colorId],
          child: GestureDetector(
            onTap: () {
              // Changes theme color and maintains correct theme mode
              bool intenseMode =
                  !themeData.isMonochromeColor(noteData.themeColorId) &&
                      noteData.themeIsMonochrome;
              noteData.themeColorId = colorId;
              noteData.themeIsMonochrome =
                  themeData.isMonochromeColor(colorId) || intenseMode;
              noteData.themeTimeUpdated = timestampNowRounded();
              themeData.updateTheme();
              noteData.updateData();
              setState(() {});
            },
            // Actual colored container
            child: Container(
              width: Constants.themeEditSize,
              height: Constants.themeEditSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(
                  Constants.themeEditRadius,
                ),
              ),
              // If this is the currently selected color, show checkmark
              child: noteData.themeColorId == colorId
                  ? Icon(
                      Icons.check,
                      color:
                          Theme.of(context).accentTextTheme.bodyMedium?.color,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ScrollView in case screen is too short
    return SingleChildScrollView(
      // Column is min so that it doesn't fill all vertical space possible
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // Combines theme mode buttons and color tiles
        children: themeModeButtons() +
            [
              Divider(),
              SizedBox(height: Constants.themeEditSpacing),
              SizedBox(
                // Calculates correct width and height to contain tiles
                height: (Constants.themeColorOptions.length /
                                Constants.themeEditCount)
                            .ceil() *
                        (Constants.themeEditSize + Constants.themeEditSpacing) -
                    Constants.themeEditSpacing,
                width: (Constants.themeEditCount) *
                        (Constants.themeEditSize + Constants.themeEditSpacing) -
                    Constants.themeEditSpacing,
                child: themeColorTiles(),
              ),
            ],
      ),
    );
  }
}
