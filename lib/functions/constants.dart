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

  // Edit page
  static const double editPadding = 30;
  static const double textMinHeight = 40;
  static const double addNewGap = 5;
  static const double addLabelTitleSize = 22;
  static const double addLabelOptionSize = 18;
  static const double labelChipSpacing = 10;
  static const double removeLabelIconSize = 20;

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

  // Tooltips and hint texts
  static const String newNoteTip = 'New Note';
  static const String deleteNoteTip = 'Delete Note';
  static const String titleHint = 'Title';
  static const String textHint = 'Note';
  static const String addLabelText = 'Add label';
  static const String newLabelText = 'Create new label';
  static const String newLabelHint = 'Label name';
  static const String removeLabelTip = 'Remove label';

  // Button texts
  static const String googleButton = 'Sign in with Google';
  static const String anonButton = 'Skip sign in for now';

  // Loading texts
  static const String defaultLoading = 'Loading...';
  static const String initLoading = 'Initializing...';

  // Messages and descriptions
  static const String welcomeText =
      'Welcome to Schema! Sign in with your Google account to access your notes ' +
          'across multiple devices. Alternatively, you can start making notes ' +
          'without signing in, and sign in later if you change your mind.';

  /* Asset constants */

  // Asset paths
  static String googleG = 'assets/google_g_logo.svg';
}
