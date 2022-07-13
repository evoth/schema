// App constants
import 'package:flutter/material.dart';
import 'package:schema/functions/general.dart';

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

  // Note and label opacity
  static const double noteOpacity = 0.8;
  static const double labelOpacity = 0.7;

  // Note dimension options (represents relative dimensions, 1x1 being default)
  static const List<List<int>> layoutDimensionOptions = [
    [1, 1],
    [2, 1],
    [1, 2],
    [2, 2],
  ];
  static const List<String> layoutDimensionNames = [
    'Default',
    'Wide',
    'Tall',
    'Large',
  ];
  static const List<String> layoutDimensionTips = [
    '1 x 1',
    '2 x 1',
    '1 x 2',
    '2 x 2',
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
  static const double homePlaceholderSize = 20;
  static const double homeArrowWidth = 5;
  static const double homeArrowTipLength = 25;

  // Edit page
  static const double editPadding = 30;
  static const double editDialogPadding = 10;
  static const double editWidth = 600;
  static const double editHeight = 900;
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

  // Tutorial page
  static const double tutorialPadding = 20;
  static const double tutorialVidRadius = 10;
  static const double tutorialWidth = 500;
  static const double tutorialAspectRatioDesktop = 824 / 868;
  static const double tutorialAspectRatioMobile = 800 / 1012;

  /* Durations */

  // Delay and animation durations (in milliseconds)
  static const int noteDragDelay = 500;
  static const int noteShiftDuration = 300;
  static const int noteHeroDuration = 300;

  // Length of inactivity before note is saved (in seconds)
  static const int saveInactivityDuration = 3;

  /* NoteData constants */
  static const int deleteBatchSize = 100;
  static const int lazyBatchSize = 100;

  /* String constants */

  // Page titles
  static const String appTitle = 'Schema';
  static const String appTitleLong = 'Schema Notes';
  static const String editTitle = 'Edit note';
  static const String signInTitle = 'Sign in';
  static const String tutorialTitle = 'Tutorial';

  // Alert/snackbar messages
  static const String discardMessage = 'Empty note discarded';
  static const String deleteMessage = 'Note deleted';
  static const String signInErrorMessage = 'Sign in error. Please try again.';
  static const String signInOfflineErrorMessage =
      'Cannot sign in without internet connection.';
  static const String signOutOfflineErrorMessage =
      'Cannot sign out without internet connection.';
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
      'This will permanently delete all notes and labels that you made while ' +
          'signed out. Any notes already saved on your Google account will remain.';
  static const String transferDeleteOK = 'Delete data';
  static const String transferCompleteMessage = 'Transfer complete';
  static const String accountDeleteTitle = 'Delete account and all data?';
  static const String accountDeleteMessage =
      'This will permanently delete all notes and labels that you have made ' +
          'on this account.';
  static const String accountDeleteConfirm = 'I understand.';
  static const String accountDeleteOK = 'Delete account';
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
  static const String noteEditOK = 'Close';

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
  static const String tutorialTip = 'Tutorial';
  static const String savingTip = 'Saving...';
  static const String savedCloudTip = 'Saved to cloud';
  static const String savedOfflineTip = 'Saved offline';
  static const String backTip = 'Back';

  // Button texts
  static const String signInGoogleButton = 'Sign in with Google';
  static const String signInAnonButton = 'Skip sign in for now';
  static const String signInCancelButton = 'Stay signed out for now';
  static const String signInButton = 'Sign in to sync your data';
  static const String signOutButton = 'Sign out of your account';
  static const String privacyPolicyButton = 'Privacy Policy';
  static const String deleteAccountButton = 'Delete account';
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
  static const String drawerSignedOutText =
      'Notes are only saving to this device.';
  static const String homePlaceholderTextAll =
      'You don\'t have any notes yet. Press the plus button to create your ' +
          'first!';
  static const String homePlaceholderTextLabel =
      'There are no notes with this label. Press the plus button to add one!';

  // Links
  static const String privacyPolicyLink =
      'https://ethanvoth.com/privacy/#privacy';

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

  // Color for background of Google sign in button (see branding guidelines at
  // https://developers.google.com/identity/branding-guidelines)
  static const Color googleColor = Color(0xFF4285F4);

  // Dialog theme
  static const double dialogRadius = 20;

  // Theme defaults
  static const int themeDefaultColorId = 13;
  static const bool themeDefaultIsDark = true;
  static const bool themeDefaultIsMonochrome = true;

  /* Tutorial content */

  static List<TutorialItem> tutorialContent = [
    TutorialItem(
      title: 'Create and delete notes',
      description:
          'On the home screen, press the plus button in the bottom right ' +
              'corner. A new note will be created and ready to edit! To ' +
              'delete a note, ' +
              (isMobileDevice() ? 'tap ' : 'click ') +
              'the note on the home screen to open the edit page. Then, press ' +
              'the delete button in the top right corner of the edit page to ' +
              'delete the note.',
      vidPathDesktop: 'assets/tutorial/desktop_create_delete_notes.mp4',
      vidPathMobile: 'assets/tutorial/mobile_create_delete_notes.mp4',
    ),
    TutorialItem(
      title: 'Edit a note',
      description: (isMobileDevice() ? 'Tap ' : 'Click ') +
          'the note on the home screen to open the edit page. There, you ' +
          'can edit its title and text, add and remove labels, or delete ' +
          'the note. Once you\'re done, just press the arrow in the top ' +
          'left corner to return to the home page.',
      vidPathDesktop: 'assets/tutorial/desktop_edit_note.mp4',
      vidPathMobile: 'assets/tutorial/mobile_edit_note.mp4',
    ),
    TutorialItem(
      title: 'Arrange notes',
      description: (isMobileDevice()
              ? 'Press and hold a note to start dragging it, '
              : 'Click and drag a note, ') +
          'then move it wherever you like. (Moving notes is disabled when ' +
          'filtering by a label. Once you stop filtering, it will be enabled ' +
          'again.)',
      vidPathDesktop: 'assets/tutorial/desktop_arrange_notes.mp4',
      vidPathMobile: 'assets/tutorial/mobile_arrange_notes.mp4',
    ),
    TutorialItem(
      title: 'Edit a note\'s labels',
      description:
          'In the note\'s edit page, press the "Add label" button to add a ' +
              'label to the note. To remove a label, press the "x" button ' +
              'next to it.',
      vidPathDesktop: 'assets/tutorial/desktop_edit_note_labels.mp4',
      vidPathMobile: 'assets/tutorial/mobile_edit_note_labels.mp4',
    ),
    TutorialItem(
      title: 'Create and delete labels',
      description:
          'On the home page, press the 3 bars in the top left corner to open ' +
              'the drawer. To create a new label, press the plus button by the ' +
              'word "Labels". To delete a label, press the edit button, then ' +
              'press the delete button by the label you want to delete.',
      vidPathDesktop: 'assets/tutorial/desktop_create_delete_labels.mp4',
      vidPathMobile: 'assets/tutorial/mobile_create_delete_labels.mp4',
    ),
    TutorialItem(
      title: 'Edit the name of a label',
      description:
          'On the home page, press the 3 bars in the top left corner to open ' +
              'the drawer. Press the edit button by the word "Labels", then ' +
              (isMobileDevice() ? 'tap ' : 'click ') +
              'a label to edit its ' +
              'name. Press the checkmark or enter key when you\'re done.',
      vidPathDesktop: 'assets/tutorial/desktop_edit_label_name.mp4',
      vidPathMobile: 'assets/tutorial/mobile_edit_label_name.mp4',
    ),
    TutorialItem(
      title: 'Filter notes by a label',
      description:
          'On the home page, press the 3 bars in the top left corner to open ' +
              'the drawer. ' +
              (isMobileDevice() ? 'Tap ' : 'Click ') +
              'a label to show only notes with that label. To stop filtering ' +
              'and return to all notes, press the "x" button by the label.',
      vidPathDesktop: 'assets/tutorial/desktop_filter_by_label.mp4',
      vidPathMobile: 'assets/tutorial/mobile_filter_by_label.mp4',
    ),
  ];
}

// Stores the content of one item in the tutorial page
class TutorialItem {
  // If both video paths are provided, mark as having a video and fill the path
  // field with the correct path for the device
  TutorialItem({
    required this.title,
    required this.description,
    String? vidPathDesktop,
    String? vidPathMobile,
  })  : this.hasVid = vidPathDesktop != null && vidPathMobile != null,
        this.vidPath = isMobileDevice() ? vidPathMobile : vidPathDesktop,
        this.vidAspectRatio = isMobileDevice()
            ? Constants.tutorialAspectRatioMobile
            : Constants.tutorialAspectRatioDesktop;

  final String title;
  final String description;
  final bool hasVid;
  final String? vidPath;
  final double vidAspectRatio;
}
