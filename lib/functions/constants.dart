// App constants
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

  // Delay and animation durations
  static const int noteDragDelay = 500;
  static const int noteShiftDuration = 300;

  // Note opacity
  static const double noteOpacity = 0.8;

  /* Page layout constants */

  // Home page
  static const double homePadding = 30;
  static const double drawerTitleSize = 24;
  static const double drawerSubtitleSize = 16;
  static const double drawerHeaderHeight = 150;
  static const double drawerPadding = 16;
  static const double drawerSignInScale = 0.8;
  static const double drawerLabelSplashRadius = 24;

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

  /* String constants */

  // Page titles
  static const String appTitle = 'Schema';
  static const String editTitle = 'Edit note';
  static const String signInTitle = 'Sign in';

  // Snackbar messages
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

  // Button texts
  static const String googleButton = 'Sign in with Google';
  static const String anonButton = 'Skip sign in for now';
  static const String signOutButton = 'Sign out of Google account';
  static const String settingsButton = 'Settings';
  static const String privacyPolicyButton = 'Privacy Policy';

  // Misc
  static const String labelsText = 'Labels';
  static const String editLabelsText = 'Edit labels';
  static const String filterLabelsText = 'Filter by label';

  // Loading texts
  static const String defaultLoading = 'Loading...';
  static const String initLoading = 'Initializing...';

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
  static String googleG = 'assets/google_g_logo.svg';
}
