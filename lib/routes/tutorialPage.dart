import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/main.dart';
import 'package:schema/widgets/loopedVideoWidget.dart';

// Returns tutorial page
class TutorialPage extends StatefulWidget {
  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  // Index of the currently expanded panel (-1 for none)
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(
        title: Text(Constants.tutorialTitle),
        elevation: 0,
        // If on mobile, background color should be lighter
        backgroundColor:
            isMobileDevice() ? Theme.of(context).dialogBackgroundColor : null,
      ),
      // If on mobile, background color should be lighter
      backgroundColor:
          isMobileDevice() ? Theme.of(context).dialogBackgroundColor : null,
      // LayoutBuilder used to get constraints
      body: LayoutBuilder(
        // Scroll
        builder: (context, constraints) => SingleChildScrollView(
          // Column to hold content + padding
          child: Column(
            children: [
              // A container with a minimum size of fullscreen so that we can
              // center the content when the screen is taller than content
              Container(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: isMobileDevice()
                      ? 0
                      : constraints.maxHeight - Constants.tutorialPadding,
                ),
                child: Center(
                  // Only centered vertically if not on mobile device
                  heightFactor: isMobileDevice() ? 1.0 : null,
                  // Container in center to hold content
                  child: Container(
                    width: isMobileDevice()
                        ? double.infinity
                        : Constants.tutorialWidth,
                    // If not on mobile, rounded corners with padding
                    padding: isMobileDevice()
                        ? null
                        : EdgeInsets.all(Constants.tutorialPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dialogBackgroundColor,
                      borderRadius: isMobileDevice()
                          ? null
                          : BorderRadius.circular(Constants.tutorialPadding),
                    ),
                    // ExpansionPanelList to hold tutorial items
                    child: tutorialPanelList(),
                  ),
                ),
              ),
              SizedBox(height: Constants.tutorialPadding),
            ],
          ),
        ),
      ),
    );
  }

  // Returns expansion panel list, used to show how to do different actions
  Widget tutorialPanelList() {
    // Only one panel can be expanded at a time (video player limitations)
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        if (!isExpanded) {
          expandedIndex = index;
        } else {
          expandedIndex = -1;
        }
        setState(() {});
      },
      // Makes a list of expansion panels based on a list of TutorialItem's
      children: Constants.tutorialContent
          .asMap()
          .map<int, ExpansionPanel>((int index, TutorialItem item) {
            // Whether this panel is expanded
            bool isExpanded = index == expandedIndex;

            return MapEntry(
              index,
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  // Title of tutorial action with custom background color
                  return ListTile(
                    title: Text(item.title),
                    tileColor: Theme.of(context).dialogBackgroundColor,
                    selectedColor: Theme.of(context).dialogBackgroundColor,
                    selectedTileColor: Theme.of(context).dialogBackgroundColor,
                  );
                },
                // Body of panel, which is only shown when expanded
                body: ListTile(
                  // If there is a video to be shown, show it. Otherwise just
                  // show text.
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (item.hasVid && isExpanded
                            ? <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Constants.tutorialVidRadius),
                                  child: LoopedVideo(item.vidPath!),
                                ),
                                SizedBox(
                                  height: Constants.tutorialPadding,
                                )
                              ]
                            : <Widget>[]) +
                        [
                          Text(item.description),
                        ],
                  ),
                  tileColor: Theme.of(context).dialogBackgroundColor,
                  selectedColor: Theme.of(context).dialogBackgroundColor,
                  selectedTileColor: Theme.of(context).dialogBackgroundColor,
                ),
                isExpanded: isExpanded,
                canTapOnHeader: true,
                backgroundColor: Theme.of(navigatorKey.currentContext!)
                    .dialogBackgroundColor,
              ),
            );
          })
          .values
          .toList(),
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
    );
  }
}
