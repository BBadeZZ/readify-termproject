import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest'**
  String get navSuggest;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navAddBook.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get navAddBook;

  /// No description provided for @navRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get navRecommendations;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get navLogout;

  /// No description provided for @statusReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get statusReading;

  /// No description provided for @statusWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get statusWishlist;

  /// No description provided for @statusAlreadyRead.
  ///
  /// In en, this message translates to:
  /// **'Already Read'**
  String get statusAlreadyRead;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Book Tracking\nand Reading Analytics App'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Cute, cozy and smart reading journal for book lovers 💛'**
  String get welcomeTagline;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get welcomeLogin;

  /// No description provided for @welcomeRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get welcomeRegister;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to continue reading'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginRegisterLink;

  /// No description provided for @loginErrEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get loginErrEmailEmpty;

  /// No description provided for @loginErrEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get loginErrEmailInvalid;

  /// No description provided for @loginErrPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get loginErrPasswordEmpty;

  /// No description provided for @loginErrUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get loginErrUserNotFound;

  /// No description provided for @loginErrWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get loginErrWrongPassword;

  /// No description provided for @loginErrInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get loginErrInvalidEmail;

  /// No description provided for @loginErrTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get loginErrTooManyRequests;

  /// No description provided for @loginErrGeneral.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginErrGeneral;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerCreateAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your reading journey'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullName;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @registerLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get registerLoginLink;

  /// No description provided for @registerErrNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get registerErrNameEmpty;

  /// No description provided for @registerErrEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get registerErrEmailEmpty;

  /// No description provided for @registerErrEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get registerErrEmailInvalid;

  /// No description provided for @registerErrPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get registerErrPasswordEmpty;

  /// No description provided for @registerErrPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get registerErrPasswordShort;

  /// No description provided for @registerErrConfirmEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get registerErrConfirmEmpty;

  /// No description provided for @registerErrPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerErrPasswordMismatch;

  /// No description provided for @registerErrEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get registerErrEmailInUse;

  /// No description provided for @registerErrWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get registerErrWeakPassword;

  /// No description provided for @registerErrGeneral.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registerErrGeneral;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Readify'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Your cozy digital reading journal.\nAdd every book you read and never lose track again.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Track Reading Sessions'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Start a session when you sit down to read.\nSee your daily reading time and weekly progress in Analytics.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Discover Books Instantly'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Search millions of books with one tap.\nTitle, author, cover and page count fill automatically.'**
  String get onboarding3Desc;

  /// No description provided for @homeGreetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetMorning;

  /// No description provided for @homeGreetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetAfternoon;

  /// No description provided for @homeGreetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetEvening;

  /// No description provided for @homeReader.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get homeReader;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your reading overview'**
  String get homeSubtitle;

  /// No description provided for @homeTotalBooks.
  ///
  /// In en, this message translates to:
  /// **'Total Books'**
  String get homeTotalBooks;

  /// No description provided for @homeReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get homeReading;

  /// No description provided for @homeAlreadyRead.
  ///
  /// In en, this message translates to:
  /// **'Already Read'**
  String get homeAlreadyRead;

  /// No description provided for @homePagesRead.
  ///
  /// In en, this message translates to:
  /// **'Pages Read'**
  String get homePagesRead;

  /// No description provided for @homeCurrentlyReading.
  ///
  /// In en, this message translates to:
  /// **'Currently Reading'**
  String get homeCurrentlyReading;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeMyLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get homeMyLibrary;

  /// No description provided for @homeSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get homeSuggestions;

  /// No description provided for @homeAddBook.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get homeAddBook;

  /// No description provided for @homeBooksAlreadyRead.
  ///
  /// In en, this message translates to:
  /// **'{count} books already read'**
  String homeBooksAlreadyRead(int count);

  /// No description provided for @homeViewHistory.
  ///
  /// In en, this message translates to:
  /// **'Tap to view your reading history'**
  String get homeViewHistory;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get libraryTitle;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, author, genre…'**
  String get librarySearchHint;

  /// No description provided for @libraryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryFilterAll;

  /// No description provided for @libraryFilterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get libraryFilterFavorites;

  /// No description provided for @librarySortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get librarySortDateAdded;

  /// No description provided for @librarySortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get librarySortTitle;

  /// No description provided for @librarySortAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get librarySortAuthor;

  /// No description provided for @librarySortProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get librarySortProgress;

  /// No description provided for @libraryEmptyFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.\nTap the heart icon on any book.'**
  String libraryBooksCount(int count);
  String get libraryEmptyFavorites;

  /// No description provided for @libraryEmptyReading.
  ///
  /// In en, this message translates to:
  /// **'Not reading anything right now.'**
  String get libraryEmptyReading;

  /// No description provided for @libraryEmptyWishlist.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty.'**
  String get libraryEmptyWishlist;

  /// No description provided for @libraryEmptyAlreadyRead.
  ///
  /// In en, this message translates to:
  /// **'No completed books yet.'**
  String get libraryEmptyAlreadyRead;

  /// No description provided for @libraryEmptyDefault.
  ///
  /// In en, this message translates to:
  /// **'No books found. Add one!'**
  String get libraryEmptyDefault;

  /// No description provided for @libraryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String libraryNoResults(String query);

  /// No description provided for @libraryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get libraryDelete;

  /// No description provided for @libraryDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" deleted.'**
  String libraryDeleted(String title);

  /// No description provided for @libraryUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get libraryUndo;

  /// No description provided for @libraryErrFavorite.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite.'**
  String get libraryErrFavorite;

  /// No description provided for @libraryErrDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete book.'**
  String get libraryErrDelete;

  /// No description provided for @libraryErrRestore.
  ///
  /// In en, this message translates to:
  /// **'Could not restore book.'**
  String get libraryErrRestore;

  /// No description provided for @librarySomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get librarySomethingWrong;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsReadingSummary.
  ///
  /// In en, this message translates to:
  /// **'Reading Summary'**
  String get analyticsReadingSummary;

  /// No description provided for @analyticsOverallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get analyticsOverallProgress;

  /// No description provided for @analyticsTotalBooks.
  ///
  /// In en, this message translates to:
  /// **'Total Books'**
  String get analyticsTotalBooks;

  /// No description provided for @analyticsReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get analyticsReading;

  /// No description provided for @analyticsAlreadyRead.
  ///
  /// In en, this message translates to:
  /// **'Already Read'**
  String get analyticsAlreadyRead;

  /// No description provided for @analyticsWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get analyticsWishlist;

  /// No description provided for @analyticsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get analyticsFavorites;

  /// No description provided for @analyticsPagesRead.
  ///
  /// In en, this message translates to:
  /// **'Pages Read'**
  String get analyticsPagesRead;

  /// No description provided for @analyticsAvgRating.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get analyticsAvgRating;

  /// No description provided for @analyticsReadingSessions.
  ///
  /// In en, this message translates to:
  /// **'Reading Sessions'**
  String get analyticsReadingSessions;

  /// No description provided for @analyticsNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.\nStart a reading session!'**
  String get analyticsNoSessions;

  /// No description provided for @analyticsRecentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent Sessions'**
  String get analyticsRecentSessions;

  /// No description provided for @analyticsSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get analyticsSessions;

  /// No description provided for @analyticsTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get analyticsTotalTime;

  /// No description provided for @analyticsPagesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Pages This Week'**
  String get analyticsPagesThisWeek;

  /// No description provided for @analyticsAvgSession.
  ///
  /// In en, this message translates to:
  /// **'Avg Session'**
  String get analyticsAvgSession;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileFavoriteGenre.
  ///
  /// In en, this message translates to:
  /// **'Favorite genre: {genre}'**
  String profileFavoriteGenre(String genre);

  /// No description provided for @profileLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get profileLibrary;

  /// No description provided for @profileActivity.
  ///
  /// In en, this message translates to:
  /// **'Reading Activity'**
  String get profileActivity;

  /// No description provided for @profileTotalBooks.
  ///
  /// In en, this message translates to:
  /// **'Total Books'**
  String get profileTotalBooks;

  /// No description provided for @profileFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get profileFinished;

  /// No description provided for @profileReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get profileReading;

  /// No description provided for @profileWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profileWishlist;

  /// No description provided for @profileFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileFavorites;

  /// No description provided for @profilePagesRead.
  ///
  /// In en, this message translates to:
  /// **'Pages Read'**
  String get profilePagesRead;

  /// No description provided for @profileSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get profileSessions;

  /// No description provided for @profileTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get profileTotalTime;

  /// No description provided for @profileAvgSession.
  ///
  /// In en, this message translates to:
  /// **'Avg Session'**
  String get profileAvgSession;

  /// No description provided for @profilePagesInSessions.
  ///
  /// In en, this message translates to:
  /// **'Pages in Sessions'**
  String get profilePagesInSessions;

  /// No description provided for @profileNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No reading sessions yet.\nOpen a book and start reading!'**
  String get profileNoSessions;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reading Reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDailyReminderSub.
  ///
  /// In en, this message translates to:
  /// **'Receive a daily push notification'**
  String get settingsDailyReminderSub;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get settingsReminderTime;

  /// No description provided for @settingsHighlightFavorites.
  ///
  /// In en, this message translates to:
  /// **'Highlight Favorite Books'**
  String get settingsHighlightFavorites;

  /// No description provided for @settingsDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Reading Goal: {count} pages'**
  String settingsDailyGoal(int count);

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsBrightnessLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsBrightnessLight;

  /// No description provided for @settingsBrightnessDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsBrightnessDark;

  /// No description provided for @settingsBrightnessSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsBrightnessSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @addBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get addBookTitle;

  /// No description provided for @addBookSearchCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Search to auto-fill'**
  String get addBookSearchCardTitle;

  /// No description provided for @addBookSearchCardSub.
  ///
  /// In en, this message translates to:
  /// **'Find by title or author — fills form automatically'**
  String get addBookSearchCardSub;

  /// No description provided for @fieldBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Title'**
  String get fieldBookTitle;
  String get fieldGenre;

  /// No description provided for @fieldAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get fieldAuthor;

  /// No description provided for @fieldCoverUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Cover URL (optional)'**
  String get fieldCoverUrlOptional;

  /// No description provided for @fieldCoverUrl.
  ///
  /// In en, this message translates to:
  /// **'Cover URL'**
  String get fieldCoverUrl;

  /// No description provided for @fieldTotalPages.
  ///
  /// In en, this message translates to:
  /// **'Total Pages'**
  String get fieldTotalPages;

  /// No description provided for @fieldCurrentPage.
  ///
  /// In en, this message translates to:
  /// **'Current Page'**
  String get fieldCurrentPage;

  /// No description provided for @fieldNote.
  ///
  /// In en, this message translates to:
  /// **'Personal Note'**
  String get fieldNote;

  /// No description provided for @fieldFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get fieldFavorite;

  /// No description provided for @fieldFavoriteShort.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get fieldFavoriteShort;

  /// No description provided for @fieldRating.
  ///
  /// In en, this message translates to:
  /// **'Rating: {value} / 5'**
  String fieldRating(int value);

  /// No description provided for @fieldReadingStatus.
  ///
  /// In en, this message translates to:
  /// **'Reading Status'**
  String get fieldReadingStatus;

  /// No description provided for @addBookSave.
  ///
  /// In en, this message translates to:
  /// **'Save Book'**
  String get addBookSave;

  /// No description provided for @addBookSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get addBookSaving;

  /// No description provided for @addBookSuccess.
  ///
  /// In en, this message translates to:
  /// **'Book added successfully.'**
  String get addBookSuccess;

  /// No description provided for @addBookFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save book. Please try again.'**
  String get addBookFailed;

  /// No description provided for @addBookAutoFill.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" filled in automatically.'**
  String addBookAutoFill(String title);

  /// No description provided for @addBookPartialFill.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" partially filled. Please enter {missing} manually.'**
  String addBookPartialFill(String title, String missing);

  /// No description provided for @editBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Book'**
  String get editBookTitle;

  /// No description provided for @editBookUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Book'**
  String get editBookUpdate;

  /// No description provided for @editBookSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get editBookSaving;

  /// No description provided for @editBookSuccess.
  ///
  /// In en, this message translates to:
  /// **'Book updated successfully.'**
  String get editBookSuccess;

  /// No description provided for @editBookFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update book. Please try again.'**
  String get editBookFailed;

  /// No description provided for @searchHintSheet.
  ///
  /// In en, this message translates to:
  /// **'Search by title or author...'**
  String get searchHintSheet;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get searchNoResults;

  /// No description provided for @validatorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get validatorTitleRequired;

  /// No description provided for @validatorAuthorRequired.
  ///
  /// In en, this message translates to:
  /// **'Author is required'**
  String get validatorAuthorRequired;

  /// No description provided for @validatorPagesRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid page count'**
  String get validatorPagesRequired;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Detail'**
  String get detailTitle;

  /// No description provided for @detailReadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading Progress'**
  String get detailReadingProgress;

  /// No description provided for @pagesProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} pages'**
  String pagesProgress(int current, int total);

  /// No description provided for @detailPages.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String detailPages(int count);

  /// No description provided for @detailSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Save Progress'**
  String get detailSaveProgress;

  /// No description provided for @detailStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start Reading Session'**
  String get detailStartSession;

  /// No description provided for @detailFinishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish Reading Session'**
  String get detailFinishSession;

  /// No description provided for @detailSessionInProgress.
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get detailSessionInProgress;

  /// No description provided for @detailFinishDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish Reading Session'**
  String get detailFinishDialogTitle;

  /// No description provided for @detailDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {time}'**
  String detailDuration(String time);

  /// No description provided for @detailWhatPage.
  ///
  /// In en, this message translates to:
  /// **'What page did you reach?'**
  String get detailWhatPage;

  /// No description provided for @detailSaveSession.
  ///
  /// In en, this message translates to:
  /// **'Save Session'**
  String get detailSaveSession;

  /// No description provided for @detailCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get detailCancel;

  /// No description provided for @detailSessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Session saved! {duration}m · {pages} pages read'**
  String detailSessionSaved(int duration, int pages);

  /// No description provided for @detailErrSaveSession.
  ///
  /// In en, this message translates to:
  /// **'Failed to save session. Please try again.'**
  String get detailErrSaveSession;

  /// No description provided for @detailProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress saved.'**
  String get detailProgressSaved;

  /// No description provided for @detailErrProgress.
  ///
  /// In en, this message translates to:
  /// **'Failed to save progress. Please try again.'**
  String get detailErrProgress;

  /// No description provided for @detailErrFavorite.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite.'**
  String get detailErrFavorite;

  /// No description provided for @detailErrRating.
  ///
  /// In en, this message translates to:
  /// **'Failed to save rating.'**
  String get detailErrRating;

  String get recsTitle;
  String get recsAllRead;
  String recsAuthor(String name);
  String recsGenre(String genre);
  String recsPages(int count);
  String recsRating(String rating);
  String get recsClose;
  String get recsAddBook;
  String get recsAddFavorite;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
