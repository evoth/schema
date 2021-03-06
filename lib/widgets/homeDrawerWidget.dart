import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/data/themeData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/main.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/loadingPage.dart';
import 'package:schema/routes/signInPage.dart';
import 'package:schema/widgets/homeDrawerLabelWidget.dart';
import 'package:schema/widgets/noteAddLabelWidget.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

// Returns the drawer used on the home screen
class HomeDrawer extends StatefulWidget {
  const HomeDrawer(this.data);

  // Data relating to editing labels
  final LabelsData data;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    // If user taps outside of text fields, unfocus (and dismiss keyboard) and
    // save label name if one was being edited
    return GestureDetector(
      onTap: () {
        doneLabelName();
        unfocus(context);
      },
      // Scrollable drawer
      child: Drawer(
        child: CustomScrollView(
          controller: ScrollController(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: homeDrawerContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Returns drawer header containing sign in / out button and text
  Widget homeDrawerHeader() {
    // Padding and decoration for header
    return Container(
      padding: EdgeInsets.all(Constants.drawerPadding),
      // Prevent overflow behind notification bar
      child: SafeArea(
        // Column to hold both the button and text
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shows sign in button if anonymous; sign out button otherwise
            noteData.isAnonymous
                // Sign in button
                ? SignInButton(
                    icon: Icon(
                      Icons.login,
                      color: Theme.of(context).primaryColor,
                      size: Constants.signInButtonSize *
                          Constants.drawerSignInScale,
                    ),
                    text: Constants.signInButton,
                    onPressed: (BuildContext context) async {
                      // Temporarily changes theme color to blue
                      themeData.tempTheme(
                        Constants.themeDefaultColorId,
                        noteData.themeIsDark,
                        noteData.themeIsMonochrome,
                      );

                      // Pops drawer and pushes sign in page
                      Navigator.of(navigatorKey.currentContext!).pop();
                      await Navigator.of(navigatorKey.currentContext!)
                          .push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => SignInPage(),
                        ),
                      );

                      // Changes color back if we canceled
                      themeData.updateTheme();
                    },
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
                    onPressed: (context) async {
                      if (noteData.isOnline) {
                        // Signs out and resets data
                        noteData = NoteData(ownerId: null);
                        await FirebaseAuth.instance.signOut();
                      } else {
                        // If we are offline, block from signing out
                        showAlert(
                          Constants.signOutOfflineErrorMessage,
                          useSnackbar: true,
                        );
                      }
                    },
                    scale: Constants.drawerSignInScale,
                  ),
            SizedBox(height: Constants.drawerPadding),
            // If anonymous, shows text either prompting to sign in; otherwise
            // displays email of signed in account
            Text(
              noteData.isAnonymous
                  ? Constants.drawerSignedOutText
                  : sprintf(
                      Constants.drawerSignedInText,
                      [FirebaseAuth.instance.currentUser?.email ?? ''],
                    ),
              style: TextStyle(
                fontSize: Constants.drawerSubtitleSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Returns labels section title tile based on whether it's in edit mode
  Widget labelsTitle(
      BuildContext context, bool editMode, String? filterLabelId) {
    return ListTile(
      // Title
      title: Text(
        widget.data.labelsEditMode
            ? Constants.editLabelsText
            : (filterLabelId != null
                ? Constants.filterLabelsText
                : Constants.labelsText),
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      // If filtering, stop filtering icon; otherwise, add icon and edit icon
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: filterLabelId != null
            ? [
                // Stop filtering icon
                IconButton(
                  splashRadius: Constants.drawerLabelSplashRadius,
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  tooltip: Constants.stopFilterTip,
                  // Stop filtering
                  onPressed: () {
                    widget.data.filterLabel(null);
                  },
                ),
              ]
            : [
                // Add label icon
                IconButton(
                  splashRadius: Constants.drawerLabelSplashRadius,
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  tooltip: Constants.newLabelText,
                  // Create new label
                  onPressed: () {
                    addNewLabel(null, () => setState(() {}));
                  },
                ),
                // Edit label icon
                IconButton(
                  splashRadius: Constants.drawerLabelSplashRadius,
                  // Shows check mark if in edit mode; otherwise shows edit icon
                  icon: Icon(
                    widget.data.labelsEditMode ? Icons.check : Icons.edit,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  // Tooltip based on edit mode
                  tooltip: widget.data.labelsEditMode
                      ? Constants.doneLabelsTip
                      : Constants.editLabelsTip,
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
    widget.data.editLabelName = name;
  }

  // Saves label name
  void doneLabelName() {
    if (widget.data.editLabelId != '' &&
        widget.data.editLabelName != null &&
        widget.data.editLabelName !=
            noteData.getLabelName(widget.data.editLabelId)) {
      noteData.editLabelName(
        widget.data.editLabelId,
        widget.data.editLabelName!,
      );
      widget.data.refreshNotes();
    }
    widget.data.editLabelId = '';
    widget.data.editLabelName = null;
    setState(() {});
  }

  // Puts label into name edit mode, and if another label's name was being
  // edited, save it
  void editLabelName(String labelId) {
    doneLabelName();
    widget.data.editLabelId = labelId;
    widget.data.editLabelName = noteData.getLabelName(labelId);
    setState(() {});
  }

  // Returns a list of widgets that make up the drawer
  List<Widget> homeDrawerContent(BuildContext context) {
    // Individual list tiles for each label
    List<Widget> labelTiles = [];
    for (String labelId in noteData.labelIds) {
      labelTiles.add(
        HomeDrawerLabel(
          labelId,
          updateLabelName,
          editLabelName,
          doneLabelName,
          widget.data,
        ),
      );
    }

    // List of widgets for the drawer column
    List<Widget> drawer = <Widget>[
          // Drawer header
          homeDrawerHeader(),
          Divider(),
          // Labels title
          labelsTitle(
              context, widget.data.labelsEditMode, widget.data.filterLabelId),
        ] +
        labelTiles +
        <Widget>[
          Expanded(child: Container()),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse(Constants.privacyPolicyLink));
                },
                child: Text(Constants.privacyPolicyButton),
              ),
              TextButton(
                onPressed: () async {
                  // Gets confirmation from user before deleting their account
                  // TODO: add checkbox (harder than it seems)
                  if (!(await confirm(
                    navigatorKey.currentContext!,
                    title: Text(Constants.accountDeleteTitle),
                    content: Text(Constants.accountDeleteMessage),
                    textOK: Text(Constants.accountDeleteOK),
                  ))) {
                    return;
                  }

                  // Push loading screen with deleting text
                  Navigator.of(navigatorKey.currentContext!)
                      .pushAndRemoveUntil<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => LoadingPage(
                        text: Constants.deleteLoading,
                      ),
                    ),
                    (route) => false,
                  );

                  // Delete user
                  await noteData.deleteUser();

                  // Resets data
                  noteData = NoteData(ownerId: null);
                },
                child: Text(Constants.deleteAccountButton),
              ),
            ],
          ),
          SizedBox(height: Constants.drawerPadding / 2),
        ];
    return drawer;
  }
}
