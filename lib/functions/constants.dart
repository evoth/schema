// App constants
import 'package:schema/functions/general.dart';

class Constants {
  /* Note dimension constants */

  // Min and preferred widths of a note
  static const double minNoteWidth = 180;
  static const double prefNoteWidth = 250;

  // Note aspect ratio (height/width)
  static const double noteAR = 1;

  /* Page layout constants */

  // Sign in container dimensions
  static const double signInWidth = 420;
  static const double signInHeight = 560;
  static const double signInPadding = 40;
  static const double signInButtonSize = 20;
  static const double signInButtonPadding = 25;
  static const double signInTextSize = 20;

  /* String constants */

  // Page titles
  static const String appTitle = 'Schema';
  static const String editTitle = 'Edit note';
  static const String signInTitle = 'Sign in';

  // Snackbar messages
  static const String discardMessage = 'Empty note discarded';
  static const String deleteMessage = 'Note deleted';
  static const String signInErrorMessage = 'Sign in error. Please try again.';

  // Tooltips and hint texts
  static const String newNoteTip = 'New Note';
  static const String deleteNoteTip = 'Delete Note';
  static const String titleHint = 'Title';
  static const String textHint = 'Note';

  // Button texts
  static const String googleButton = 'Sign in with Google';
  static const String anonButton = 'Skip sign in for now';

  // Loading texts
  static const String defaultLoading = 'Loading...';
  static const String initLoading = 'Initializing...';

  // Messages and descriptions
  static const String welcomeText =
      'Welcome to Schema! Sign in to your Google account to access your notes ' +
          'across multiple devices. Alternatively, you can start making notes ' +
          'without signing in, and sign in later if you change your mind.';

  /* Asset constants */

  // Asset paths
  static String googleG = 'assets/google_g_logo_white.svg';
}
