import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';

// Returns a column of content to put in the theme edit dialog from home page
class LayoutEditContent extends StatefulWidget {
  const LayoutEditContent({required this.refresh});

  final Function refresh;

  @override
  State<LayoutEditContent> createState() => _LayoutEditContentState();
}

class _LayoutEditContentState extends State<LayoutEditContent> {
  @override
  Widget build(BuildContext context) {
    // ScrollView in case screen is too short
    return SingleChildScrollView(
      // Column is min so that it doesn't fill all vertical space possible
      child: SizedBox(
        // Calculates correct width and height to contain tiles
        height: 3 * Constants.layoutEditSize + Constants.layoutEditSpacing,
        width: 3 * Constants.layoutEditSize + Constants.layoutEditSpacing,
        child: layoutMosaic(),
      ),
    );
  }

  // Returns a tile representing a certain note dimension choice
  Widget layoutDimensionTile(
    BuildContext context,
    int dimensionId,
  ) {
    // Tooltip with name of color
    return Tooltip(
      message: Constants.layoutDimensionTips[dimensionId],
      child: GestureDetector(
        onTap: () {
          // Changes dimensions of notes
          noteData.layoutDimensionId = dimensionId;
          noteData.layoutTimeUpdated = timestampNowRounded();
          noteData.updateData();
          widget.refresh();
          setState(() {});
        },
        // Actual colored container
        child: Container(
          width: Constants.layoutDimensionOptions[dimensionId][0] *
              Constants.layoutEditSize,
          height: Constants.layoutDimensionOptions[dimensionId][1] *
              Constants.layoutEditSize,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(
              Constants.layoutEditRadius,
            ),
          ),
          // Checkmark if this is the currently selected dimension; text with
          // name of the dimension otherwise
          child: noteData.layoutDimensionId == dimensionId
              ? Icon(
                  Icons.check,
                  color: Theme.of(context).accentTextTheme.bodyMedium?.color,
                )
              : Center(
                  child: Text(
                    Constants.layoutDimensionNames[dimensionId],
                    style: TextStyle(
                      color:
                          Theme.of(context).accentTextTheme.bodyMedium?.color,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // Little mosaic to represent note dimension options
  Widget layoutMosaic() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      // Two rows of two options each
      children: [
        // Default and wide option tiles
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            layoutDimensionTile(context, 0),
            SizedBox(width: Constants.layoutEditSpacing),
            layoutDimensionTile(context, 1),
          ],
        ),
        SizedBox(height: Constants.layoutEditSpacing),
        // Tall and large option tiles
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            layoutDimensionTile(context, 2),
            SizedBox(width: Constants.layoutEditSpacing),
            layoutDimensionTile(context, 3),
          ],
        ),
      ],
    );
  }
}
