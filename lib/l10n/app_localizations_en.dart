// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navSettings => 'Settings';

  @override
  String get navSuggest => 'Suggest';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAddBook => 'Add Book';

  @override
  String get navRecommendations => 'Recommendations';

  @override
  String get navLogout => 'Logout';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusWishlist => 'Wishlist';

  @override
  String get statusAlreadyRead => 'Already Read';

  @override
  String get welcomeSubtitle =>
      'Smart Book Tracking\nand Reading Analytics App';

  @override
  String get welcomeTagline =>
      'Cute, cozy and smart reading journal for book lovers 💛';

  @override
  String get welcomeLogin => 'Login';

  @override
  String get welcomeRegister => 'Register';

  @override
  String get loginWelcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Login to continue reading';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginRegisterLink => 'Register';

  @override
  String get loginErrEmailEmpty => 'Please enter your email.';

  @override
  String get loginErrEmailInvalid => 'Please enter a valid email.';

  @override
  String get loginErrPasswordEmpty => 'Please enter your password.';

  @override
  String get loginErrUserNotFound => 'No account found with this email.';

  @override
  String get loginErrWrongPassword => 'Incorrect email or password.';

  @override
  String get loginErrInvalidEmail => 'Please enter a valid email address.';

  @override
  String get loginErrTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get loginErrGeneral => 'Login failed. Please try again.';

  @override
  String get registerCreateAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Start your reading journey';

  @override
  String get registerFullName => 'Full Name';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerButton => 'Register';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLoginLink => 'Login';

  @override
  String get registerErrNameEmpty => 'Please enter your name.';

  @override
  String get registerErrEmailEmpty => 'Please enter your email.';

  @override
  String get registerErrEmailInvalid => 'Please enter a valid email.';

  @override
  String get registerErrPasswordEmpty => 'Please enter a password.';

  @override
  String get registerErrPasswordShort =>
      'Password must be at least 6 characters.';

  @override
  String get registerErrConfirmEmpty => 'Please confirm your password.';

  @override
  String get registerErrPasswordMismatch => 'Passwords do not match.';

  @override
  String get registerErrEmailInUse => 'This email is already registered.';

  @override
  String get registerErrWeakPassword =>
      'Password must be at least 6 characters.';

  @override
  String get registerErrGeneral => 'Registration failed. Please try again.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboarding1Title => 'Welcome to Readify';

  @override
  String get onboarding1Desc =>
      'Your cozy digital reading journal.\nAdd every book you read and never lose track again.';

  @override
  String get onboarding2Title => 'Track Reading Sessions';

  @override
  String get onboarding2Desc =>
      'Start a session when you sit down to read.\nSee your daily reading time and weekly progress in Analytics.';

  @override
  String get onboarding3Title => 'Discover Books Instantly';

  @override
  String get onboarding3Desc =>
      'Search millions of books with one tap.\nTitle, author, cover and page count fill automatically.';

  @override
  String streakDays(int days) {
    return '$days day streak';
  }

  @override
  String get streakStart => 'Start your streak today!';

  @override
  String get homeGreetMorning => 'Good morning';

  @override
  String get homeGreetAfternoon => 'Good afternoon';

  @override
  String get homeGreetEvening => 'Good evening';

  @override
  String get homeReader => 'Reader';

  @override
  String get homeSubtitle => 'Here\'s your reading overview';

  @override
  String get homeTotalBooks => 'Total Books';

  @override
  String get homeReading => 'Reading';

  @override
  String get homeAlreadyRead => 'Already Read';

  @override
  String get homePagesRead => 'Pages Read';

  @override
  String get homeCurrentlyReading => 'Currently Reading';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeMyLibrary => 'My Library';

  @override
  String get homeSuggestions => 'Suggestions';

  @override
  String get homeAddBook => 'Add Book';

  @override
  String homeBooksAlreadyRead(int count) {
    return '$count books already read';
  }

  @override
  String get homeViewHistory => 'Tap to view your reading history';

  @override
  String get homeGoalTitle => "Today's Goal";

  @override
  String get homeGoalReached => 'Goal reached! 🎉';

  @override
  String homeGoalProgress(int done, int goal) => '$done / $goal pages';

  @override
  String get libraryTitle => 'My Library';

  @override
  String get librarySearchHint => 'Search title, author, genre…';

  @override
  String get libraryFilterAll => 'All';

  @override
  String get libraryFilterFavorites => 'Favorites';

  @override
  String get librarySortDateAdded => 'Date Added';

  @override
  String get librarySortTitle => 'Title';

  @override
  String get librarySortAuthor => 'Author';

  @override
  String get librarySortProgress => 'Progress';

  @override
  String libraryBooksCount(int count) {
    return '$count books';
  }

  @override
  String get libraryEmptyFavorites =>
      'No favorites yet.\nTap the heart icon on any book.';

  @override
  String get libraryEmptyReading => 'Not reading anything right now.';

  @override
  String get libraryEmptyWishlist => 'Your wishlist is empty.';

  @override
  String get libraryEmptyAlreadyRead => 'No completed books yet.';

  @override
  String get libraryEmptyDefault => 'No books found. Add one!';

  @override
  String libraryNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get libraryDelete => 'Delete';

  @override
  String libraryDeleted(String title) {
    return '\"$title\" deleted.';
  }

  @override
  String get libraryUndo => 'Undo';

  @override
  String get libraryErrFavorite => 'Failed to update favorite.';

  @override
  String get libraryErrDelete => 'Failed to delete book.';

  @override
  String get libraryErrRestore => 'Could not restore book.';

  @override
  String get librarySomethingWrong => 'Something went wrong.';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsReadingSummary => 'Reading Summary';

  @override
  String get analyticsOverallProgress => 'Overall Progress';

  @override
  String get analyticsTotalBooks => 'Total Books';

  @override
  String get analyticsReading => 'Reading';

  @override
  String get analyticsAlreadyRead => 'Already Read';

  @override
  String get analyticsWishlist => 'Wishlist';

  @override
  String get analyticsFavorites => 'Favorites';

  @override
  String get analyticsPagesRead => 'Pages Read';

  @override
  String get analyticsAvgRating => 'Avg Rating';

  @override
  String get analyticsReadingSessions => 'Reading Sessions';

  @override
  String get analyticsNoSessions =>
      'No sessions yet.\nStart a reading session!';

  @override
  String get analyticsRecentSessions => 'Recent Sessions';

  @override
  String get analyticsSessions => 'Sessions';

  @override
  String get analyticsTotalTime => 'Total Time';

  @override
  String get analyticsPagesThisWeek => 'Pages This Week';

  @override
  String get analyticsAvgSession => 'Avg Session';

  @override
  String get profileTitle => 'My Profile';

  @override
  String profileFavoriteGenre(String genre) {
    return 'Favorite genre: $genre';
  }

  @override
  String get profileLibrary => 'Library';

  @override
  String get profileActivity => 'Reading Activity';

  @override
  String get profileTotalBooks => 'Total Books';

  @override
  String get profileFinished => 'Finished';

  @override
  String get profileReading => 'Reading';

  @override
  String get profileWishlist => 'Wishlist';

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profilePagesRead => 'Pages Read';

  @override
  String get profileSessions => 'Sessions';

  @override
  String get profileTotalTime => 'Total Time';

  @override
  String get profileAvgSession => 'Avg Session';

  @override
  String get profilePagesInSessions => 'Pages in Sessions';

  @override
  String get profileNoSessions =>
      'No reading sessions yet.\nOpen a book and start reading!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDailyReminder => 'Daily Reading Reminder';

  @override
  String get settingsDailyReminderSub => 'Receive a daily push notification';

  @override
  String get settingsReminderTime => 'Reminder Time';

  @override
  String get settingsHighlightFavorites => 'Highlight Favorite Books';

  @override
  String settingsDailyGoal(int count) {
    return 'Daily Reading Goal: $count pages';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsBrightnessLight => 'Light';

  @override
  String get settingsBrightnessDark => 'Dark';

  @override
  String get settingsBrightnessSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get addBookTitle => 'Add Book';

  @override
  String get addBookSearchCardTitle => 'Search to auto-fill';

  @override
  String get addBookSearchCardSub =>
      'Find by title or author — fills form automatically';

  @override
  String get fieldBookTitle => 'Book Title';

  @override
  String get fieldGenre => 'Genre';

  @override
  String get fieldAuthor => 'Author';

  @override
  String get fieldCoverUrlOptional => 'Cover URL (optional)';

  @override
  String get fieldCoverUrl => 'Cover URL';

  @override
  String get fieldTotalPages => 'Total Pages';

  @override
  String get fieldCurrentPage => 'Current Page';

  @override
  String get fieldNote => 'Personal Note';

  @override
  String get fieldFavorite => 'Add to favorites';

  @override
  String get fieldFavoriteShort => 'Favorite';

  @override
  String fieldRating(int value) {
    return 'Rating: $value / 5';
  }

  @override
  String get fieldReadingStatus => 'Reading Status';

  @override
  String get addBookSave => 'Save Book';

  @override
  String get addBookSaving => 'Saving…';

  @override
  String get addBookSuccess => 'Book added successfully.';

  @override
  String get addBookFailed => 'Failed to save book. Please try again.';

  @override
  String addBookAutoFill(String title) {
    return '\"$title\" filled in automatically.';
  }

  @override
  String addBookPartialFill(String title, String missing) {
    return '\"$title\" partially filled. Please enter $missing manually.';
  }

  @override
  String get editBookTitle => 'Edit Book';

  @override
  String get editBookUpdate => 'Update Book';

  @override
  String get editBookSaving => 'Saving…';

  @override
  String get editBookSuccess => 'Book updated successfully.';

  @override
  String get editBookFailed => 'Failed to update book. Please try again.';

  @override
  String get searchHintSheet => 'Search by title or author...';

  @override
  String get searchNoResults => 'No results found.';

  @override
  String get validatorTitleRequired => 'Title is required';

  @override
  String get validatorAuthorRequired => 'Author is required';

  @override
  String get validatorPagesRequired => 'Enter a valid page count';

  @override
  String get detailTitle => 'Book Detail';

  @override
  String get detailReadingProgress => 'Reading Progress';

  @override
  String pagesProgress(int current, int total) {
    return '$current of $total pages';
  }

  @override
  String detailPages(int count) {
    return '$count pages';
  }

  @override
  String get detailSaveProgress => 'Save Progress';

  @override
  String get detailStartSession => 'Start Reading Session';

  @override
  String get detailFinishSession => 'Finish Reading Session';

  @override
  String get detailSessionInProgress => 'Session in progress';

  @override
  String get detailFinishDialogTitle => 'Finish Reading Session';

  @override
  String detailDuration(String time) {
    return 'Duration: $time';
  }

  @override
  String get detailWhatPage => 'What page did you reach?';

  @override
  String get detailSaveSession => 'Save Session';

  @override
  String get detailCancel => 'Cancel';

  @override
  String detailSessionSaved(int duration, int pages) {
    return 'Session saved! ${duration}m · $pages pages read';
  }

  @override
  String get detailErrSaveSession =>
      'Failed to save session. Please try again.';

  @override
  String get detailProgressSaved => 'Progress saved.';

  @override
  String get detailErrProgress => 'Failed to save progress. Please try again.';

  @override
  String get detailErrFavorite => 'Failed to update favorite.';

  @override
  String get detailErrRating => 'Failed to save rating.';

  @override
  String get recsTitle => 'Book Recommendations';

  @override
  String get recsAllRead => 'You\'ve already read all recommended books 💛';

  @override
  String recsAuthor(String name) {
    return 'Author: $name';
  }

  @override
  String recsGenre(String genre) {
    return 'Genre: $genre';
  }

  @override
  String recsPages(int count) {
    return 'Pages: $count';
  }

  @override
  String recsRating(String rating) {
    return 'Rating: $rating';
  }

  @override
  String get recsClose => 'Close';

  @override
  String get recsAddBook => 'Add This Book';

  @override
  String get recsAddFavorite => 'Add to Favorites';
}
