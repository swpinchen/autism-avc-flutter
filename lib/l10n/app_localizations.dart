import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Autism AVC'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get newEvent;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read Aloud'**
  String get readAloud;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thankYou;

  /// No description provided for @howDoYouFeel.
  ///
  /// In en, this message translates to:
  /// **'How do you feel about this?'**
  String get howDoYouFeel;

  /// No description provided for @noEventsToday.
  ///
  /// In en, this message translates to:
  /// **'No events today.\nTap + to add one!'**
  String get noEventsToday;

  /// No description provided for @noEventsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No events on this day'**
  String get noEventsOnDay;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this event?'**
  String get deleteConfirm;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @textToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Text-to-Speech'**
  String get textToSpeech;

  /// No description provided for @pitch.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get pitch;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @previewVoice.
  ///
  /// In en, this message translates to:
  /// **'Preview Voice'**
  String get previewVoice;

  /// No description provided for @happyMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for telling me how you feel. Just remember you get to {details}'**
  String happyMessage(String details);

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @detailsRequired.
  ///
  /// In en, this message translates to:
  /// **'Details are required'**
  String get detailsRequired;

  /// No description provided for @profanityTitle.
  ///
  /// In en, this message translates to:
  /// **'Title can\'t include obscene words'**
  String get profanityTitle;

  /// No description provided for @profanityDetails.
  ///
  /// In en, this message translates to:
  /// **'Details can\'t include obscene words'**
  String get profanityDetails;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @unsplash.
  ///
  /// In en, this message translates to:
  /// **'Unsplash'**
  String get unsplash;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @ratingSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get ratingSad;

  /// No description provided for @ratingOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get ratingOkay;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get ratingGreat;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @selectTimezone.
  ///
  /// In en, this message translates to:
  /// **'Select Timezone'**
  String get selectTimezone;

  /// No description provided for @voicePreviewText.
  ///
  /// In en, this message translates to:
  /// **'This is a voice preview'**
  String get voicePreviewText;

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @recurringLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurringLabel;

  /// No description provided for @editRecurringEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring Event'**
  String get editRecurringEvent;

  /// No description provided for @editRecurringMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to edit all occurrences or just this one?'**
  String get editRecurringMessage;

  /// No description provided for @justThisOne.
  ///
  /// In en, this message translates to:
  /// **'Just This One'**
  String get justThisOne;

  /// No description provided for @allEvents.
  ///
  /// In en, this message translates to:
  /// **'All Events'**
  String get allEvents;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @dayUnit.
  ///
  /// In en, this message translates to:
  /// **'day(s)'**
  String get dayUnit;

  /// No description provided for @weekUnit.
  ///
  /// In en, this message translates to:
  /// **'week(s)'**
  String get weekUnit;

  /// No description provided for @monthUnit.
  ///
  /// In en, this message translates to:
  /// **'month(s)'**
  String get monthUnit;

  /// No description provided for @onDay.
  ///
  /// In en, this message translates to:
  /// **'On day'**
  String get onDay;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String endsOn(String date);

  /// No description provided for @searchUnsplash.
  ///
  /// In en, this message translates to:
  /// **'Search Unsplash'**
  String get searchUnsplash;

  /// No description provided for @searchPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Search photos...'**
  String get searchPhotosHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download image'**
  String get downloadFailed;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Day'**
  String get onboardingPlanTitle;

  /// No description provided for @onboardingPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Create events and tasks on your calendar. See what\'s coming up today and this week.'**
  String get onboardingPlanDesc;

  /// No description provided for @onboardingRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring Events'**
  String get onboardingRecurringTitle;

  /// No description provided for @onboardingRecurringDesc.
  ///
  /// In en, this message translates to:
  /// **'Set events to repeat daily, weekly, or monthly. Never forget your routine.'**
  String get onboardingRecurringDesc;

  /// No description provided for @onboardingTtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Read Aloud'**
  String get onboardingTtsTitle;

  /// No description provided for @onboardingTtsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the speaker button to hear event details read aloud. Works in English and Japanese.'**
  String get onboardingTtsDesc;

  /// No description provided for @onboardingReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review How You Feel'**
  String get onboardingReviewTitle;

  /// No description provided for @onboardingReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'After an event, rate how it went. If you\'re feeling down, we\'ll remind you of something to look forward to.'**
  String get onboardingReviewDesc;

  /// No description provided for @onboardingPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get onboardingPhotoTitle;

  /// No description provided for @onboardingPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Attach photos from your camera, gallery, or search Unsplash for the perfect image.'**
  String get onboardingPhotoDesc;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
