// App constants
import 'package:flutter/material.dart';

class Constants {
  /* Note and grid constants */

  // Min and preferred widths of a note
  static const double minNoteWidth = 180;
  static const double prefNoteWidth = 250;

  // Note aspect ratio (height/width)
  static const double noteAR = 1;

  // Note padding and border radius
  static const double notePadding = 15;
  static const double noteRadius = 10;
  static const double gridPadding = 10;
  static const double noteTitleSpace = 10;

  // Note opacity
  static const double noteOpacity = 0.8;

  // Note dimension options (represents relative dimensions, 1x1 being default)
  static const List<List<int>> layoutDimensionOptions = [
    [1, 1],
    [2, 1],
    [1, 2],
    [2, 2],
  ];
  static const List<String> layoutDimensionNames = [
    "Default",
    "Wide",
    "Tall",
    "Large",
  ];
  static const List<String> layoutDimensionTips = [
    "1 x 1",
    "2 x 1",
    "1 x 2",
    "2 x 2",
  ];

  /* Page layout constants */

  // Home page
  static const double homePadding = 30;
  static const double drawerTitleSize = 24;
  static const double drawerSubtitleSize = 16;
  static const double drawerPadding = 16;
  static const double drawerSignInScale = 0.8;
  static const double drawerLabelSplashRadius = 24;
  static const double appBarPadding = 10;
  static const double appBarSize = 20;

  // Edit page
  static const double editPadding = 30;
  static const double textMinHeight = 40;
  static const double addNewGap = 5;
  static const double addLabelTitleSize = 22;
  static const double addLabelOptionSize = 18;
  static const double labelChipSpacing = 10;
  static const double labelChipIconSize = 20;
  static const double labelChipPadding = 5;

  // Sign in page
  static const double signInWidth = 400;
  static const double signInHeight = 480;
  static const double signInPadding = 40;
  static const double signInButtonSize = 20;
  static const double signInButtonPadding = 5;
  static const double signInTextSize = 20;
  static const double signInTileSize = 30 + signInButtonSize;

  // Theme edit dialog
  static const int themeEditCount = 6;
  static const double themeEditSpacing = 10;
  static const double themeEditRadius = 8;
  static const double themeEditSize = 40;

  // Layout edit dialog
  static const double layoutEditSpacing = 10;
  static const double layoutEditRadius = 10;
  static const double layoutEditSize = 80;

  /* Durations */

  // Delay and animation durations (in milliseconds)
  static const int noteDragDelay = 500;
  static const int noteShiftDuration = 300;

  // Length of inactivity before note is saved (in seconds)
  static const int saveInactivityDuration = 3;

  /* NoteData constants */
  static const int deleteBatchSize = 100;
  static const int lazyBatchSize = 100;

  /* String constants */

  // Page titles
  static const String appTitle = 'Schema';
  static const String editTitle = 'Edit note';
  static const String signInTitle = 'Sign in';

  // Alert/snackbar messages
  static const String discardMessage = 'Empty note discarded';
  static const String deleteMessage = 'Note deleted';
  static const String signInErrorMessage = 'Sign in error. Please try again.';
  static const String labelExistsMessage =
      'A label with this name already exists.';
  static const String labelNameEmptyMessage = 'Label name cannot be empty.';
  static const String deleteNoteMessageTitle = 'Delete note?';
  static const String deleteNoteMessage =
      'This will permanently delete this note and its contents.';
  static const String deleteLabelMessageTitle = 'Delete label?';
  static const String deleteLabelMessage =
      'This will permanently delete this label and remove it from all notes.';
  static const String cantDragMessage =
      'Cannot rearrange notes while filtering by a label.';
  static const String updateNotesErrorMessage = 'Error getting notes.';
  static const String transferTitle = 'Transfer data?';
  static const String transferMessage =
      'This will transfer your notes and labels to your Google account. ' +
          'Otherwise, the notes you made while signed out will be permanently ' +
          'deleted.';
  static const String transferCancel = 'Delete data';
  static const String transferOK = 'Transfer data';
  static const String transferDeleteTitle = 'Delete data?';
  static const String transferDeleteMessage =
      'This will delete all notes and labels you made while signed out. Any ' +
          'notes already saved on your Google account will remain.';
  static const String transferDeleteOK = 'Delete data';
  static const String transferCompleteMessage = 'Transfer complete';
  static const String layoutEditTitle = 'Change note layout';
  static const String layoutEditOK = 'Done';
  static const String themeEditTitle = 'Edit theme';
  static const String themeEditOK = 'Done';
  static const String savedCloudMessage = 'This note is saved to the cloud. ' +
      'The most recent edit was on %s at %s.';
  static const String savedOfflineMessage = 'This note is saved on this ' +
      'device, but hasn\'t been synced to the cloud yet. The most recent ' +
      'edit was on %s at %s.';
  static const String isOnlineMessage =
      'Device back online. Connecting to cloud...';
  static const String isOfflineMessage =
      'Connection has been lost. Saving notes locally while offline.';

  // Tooltips and hint texts
  static const String newNoteTip = 'New note';
  static const String deleteNoteTip = 'Delete note';
  static const String titleHint = 'Title';
  static const String textHint = 'Note';
  static const String addLabelText = 'Add label';
  static const String newLabelText = 'Create new label';
  static const String labelNameHint = 'Label name';
  static const String removeLabelTip = 'Remove label';
  static const String deleteLabelTip = 'Delete label';
  static const String editLabelsTip = 'Edit labels';
  static const String doneLabelsTip = 'Done';
  static const String editLabelNameTip = 'Edit label name';
  static const String doneLabelNameTip = 'Done';
  static const String stopFilterTip = 'Stop filtering';
  static const String layoutTip = 'Change note layout';
  static const String themeTip = 'Edit theme';
  static const String savingTip = 'Saving...';
  static const String savedCloudTip = 'Saved to cloud';
  static const String savedOfflineTip = 'Saved offline';

  // Button texts
  static const String googleButton = 'Sign in with Google';
  static const String anonButton = 'Skip sign in for now';
  static const String signOutButton = 'Sign out of Google account';
  static const String settingsButton = 'Settings';
  static const String privacyPolicyButton = 'Privacy Policy';
  static const String themeLightButton = 'Light mode';
  static const String themeDarkButton = 'Dark mode';
  static const String themeIntenseButton = 'Intense mode';

  // Misc
  static const String labelsText = 'Labels';
  static const String editLabelsText = 'Edit labels';
  static const String filterLabelsText = 'Filter by label';

  // Loading texts
  static const String defaultLoading = 'Loading...';
  static const String initLoading = 'Initializing...';
  static const String transferLoading = 'Transferring data...';
  static const String deleteLoading = 'Deleting data...';
  static const String signInLoading = 'Signing in...';

  // Messages and descriptions
  static const String welcomeText =
      'Welcome to Schema! Sign in with your Google account to access your notes ' +
          'across multiple devices. Alternatively, you can start making notes ' +
          'without signing in, and sign in later if you change your mind.';
  static const String drawerSignedInText = 'Signed in as %s';
  static const String drawerSignedOutText = 'Sign in to sync notes.';

  // Links
  static const String privacyPolicyLink = 'https://evoth.cf/privacy/#privacy';

  /* Asset constants */

  // Asset paths
  static const String googleG = 'assets/google_g_logo.svg';

  /* Theme constants */

  // Color options
  static const List<MaterialColor> themeColorOptions = [
    Colors.grey,
    Colors.blueGrey,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.indigo,
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
  ];
  static const List<String> themeColorNames = [
    'Grey',
    'Blue Grey',
    'Red',
    'Deep Orange',
    'Orange',
    'Amber',
    'Yellow',
    'Lime',
    'Lime Green',
    'Green',
    'Teal',
    'Cyan',
    'Light Blue',
    'Blue',
    'Indigo',
    'Deep Purple',
    'Purple',
    'Pink',
  ];
  static const List<MaterialColor> themeMonochromeColors = [
    Colors.grey,
    Colors.blueGrey,
  ];

  // Theme defaults
  static const int themeDefaultColorId = 13;
  static const bool themeDefaultIsDark = true;
  static const bool themeDefaultIsMonochrome = true;
}
