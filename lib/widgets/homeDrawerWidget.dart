import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/auth.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/signInPage.dart';
import 'package:schema/widgets/homeDrawerLabelWidget.dart';
import 'package:schema/widgets/noteAddLabelWidget.dart';
import 'package:sprintf/sprintf.dart';

// Returns the drawer used on the home screen
class HomeDrawer extends StatefulWidget {
  const HomeDrawer(this.data, this.refreshNotes);

  // Data relateing to editing labels
  final DrawerLabelsEditData data;
  // Function for refreshing the home page
  final Function refreshNotes;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  // Returns drawer header containing sign in / out button and text
  DrawerHeader homeDrawerHeader(BuildContext context) {
    return DrawerHeader(
      padding: EdgeInsets.all(Constants.drawerPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      // Column to hold both the button and text
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shows sign in button if anonymous; otherwise shows sign out button
          noteData.isAnonymous
              // Google sign in button (roughly follows Google's guidelines:
              // https://developers.google.com/identity/branding-guidelines)
              ? SignInButton(
                  icon: SvgPicture.asset(
                    Constants.googleG,
                    height: Constants.signInButtonSize *
                        Constants.drawerSignInScale,
                  ),
                  text: Constants.googleButton,
                  onPressed: signInWithGoogle,
                  scale: Constants.drawerSignInScale,
                )
              // Sign out button
              : SignInButton(
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).primaryColor,
                    size: Constants.signInButtonSize *
                        Constants.drawerSignInScale,
                  ),
                  text: Constants.signOutButton,
                  onPressed: (context) => FirebaseAuth.instance.signOut(),
                  scale: Constants.drawerSignInScale,
                ),
          // If anonymous, shows text either prompting to sign in; otherwise
          // displays email of signed in account
          Text(
            noteData.isAnonymous
                ? Constants.drawerSignedOutText
                : sprintf(
                    Constants.drawerSignedInText,
                    [noteData.email ?? ''],
                  ),
            style: TextStyle(
              color: Colors.white,
              fontSize: Constants.drawerSubtitleSize,
            ),
          ),
        ],
      ),
    );
  }

  // Returns labels section title tile based on whether it's in edit mode
  ListTile labelsTitle(BuildContext context, bool editMode) {
    return ListTile(
      // Title
      title: Text(
        widget.data.labelsEditMode
            ? Constants.editLabelsText
            : Constants.labelsText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      // Add icon and edit icon
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add label icon
          IconButton(
            splashRadius: Constants.drawerLabelSplashRadius,
            tooltip: Constants.newLabelText,
            icon: Icon(
              Icons.add,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
            ),
            // Create new label
            onPressed: () {
              addNewLabel(context, null, () => setState(() {}));
            },
          ),
          // Edit label icon
          IconButton(
            splashRadius: Constants.drawerLabelSplashRadius,
            // Tooltip based on edit mode
            tooltip: widget.data.labelsEditMode
                ? Constants.doneLabelsTip
                : Constants.editLabelsTip,
            // Shows checkmark icon if in edit mode; otherwise shows edit icon
            icon: Icon(
              widget.data.labelsEditMode ? Icons.check : Icons.edit,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
            ),
            // Toggle edit mode
            onPressed: () {
              setState(() {
                if (widget.data.labelsEditMode) {
                  // Saves label name if one was being edited
                  doneLabelName();
                }
                widget.data.labelsEditMode = !widget.data.labelsEditMode;
              });
            },
          ),
        ],
      ),
    );
  }

  // Updates temp label name
  void updateLabelName(String name) {
    widget.data.labelName = name;
  }

  // Saves label name
  void doneLabelName() {
    if (widget.data.labelEditing != -1 &&
        widget.data.labelName != null &&
        widget.data.labelName != noteData.labelName(widget.data.labelEditing)) {
      noteData.editLabelName(
          context, widget.data.labelEditing, widget.data.labelName!);
      widget.refreshNotes();
    }
    widget.data.labelEditing = -1;
    widget.data.labelName = null;
    setState(() {});
  }

  // Puts label into name edit mode, and if another label's name was being
  // edited, save it
  void editLabelName(int labelId) {
    doneLabelName();
    widget.data.labelEditing = labelId;
    widget.data.labelName = noteData.labelName(labelId);
    setState(() {});
  }

  // Returns a list of widgets that make up the drawer
  List<Widget> homeDrawerContent(BuildContext context) {
    List<Widget> drawer = [
      // Drawer header
      SizedBox(
        height: Constants.drawerHeaderHeight,
        child: homeDrawerHeader(context),
      ),
      // Labels title
      labelsTitle(context, widget.data.labelsEditMode),
    ];
    // Individual list tiles for each label
    for (int labelId in noteData.getLabels()) {
      drawer.add(
        HomeDrawerLabel(
          labelId,
          widget.data.labelsEditMode,
          widget.data.labelEditing == labelId,
          widget.refreshNotes,
          editLabelName,
          doneLabelName,
          updateLabelName,
        ),
      );
    }
    return drawer;
  }

  @override
  Widget build(BuildContext context) {
    // If user taps outside of text fields, unfocus (and dismiss keyboard) and
    // save label name if one was being edited
    return GestureDetector(
      onTap: () {
        doneLabelName();
        unfocus(context);
      },
      // Saves label name before popping drawer
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: homeDrawerContent(context),
        ),
      ),
    );
  }
}
