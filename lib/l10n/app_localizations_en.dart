// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Autism AVC';

  @override
  String get today => 'Today';

  @override
  String get calendar => 'Calendar';

  @override
  String get settings => 'Settings';

  @override
  String get newEvent => 'New Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get title => 'Title';

  @override
  String get details => 'Details';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get create => 'Create';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get readAloud => 'Read Aloud';

  @override
  String get review => 'Review';

  @override
  String get submit => 'Submit';

  @override
  String get done => 'Done';

  @override
  String get thankYou => 'Thank you!';

  @override
  String get howDoYouFeel => 'How do you feel about this?';

  @override
  String get noEventsToday => 'No events today.\nTap + to add one!';

  @override
  String get noEventsOnDay => 'No events on this day';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this event?';

  @override
  String get language => 'Language';

  @override
  String get textToSpeech => 'Text-to-Speech';

  @override
  String get pitch => 'Pitch';

  @override
  String get speed => 'Speed';

  @override
  String get previewVoice => 'Preview Voice';

  @override
  String happyMessage(String details) {
    return 'Thank you for telling me how you feel. Just remember you get to $details';
  }

  @override
  String get titleRequired => 'Title is required';

  @override
  String get detailsRequired => 'Details are required';

  @override
  String get profanityTitle => 'Title can\'t include obscene words';

  @override
  String get profanityDetails => 'Details can\'t include obscene words';

  @override
  String get thisWeek => 'This Week';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get child => 'Child';

  @override
  String get repeat => 'Repeat';

  @override
  String get none => 'None';

  @override
  String get photo => 'Photo';

  @override
  String get unsplash => 'Unsplash';

  @override
  String get notSet => 'Not set';

  @override
  String get ratingSad => 'Sad';

  @override
  String get ratingOkay => 'Okay';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingGreat => 'Great';

  @override
  String get timezone => 'Timezone';

  @override
  String get selectTimezone => 'Select Timezone';

  @override
  String get voicePreviewText => 'This is a voice preview';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get recurringLabel => 'Recurring';

  @override
  String get editRecurringEvent => 'Edit Recurring Event';

  @override
  String get editRecurringMessage =>
      'Do you want to edit all occurrences or just this one?';

  @override
  String get justThisOne => 'Just This One';

  @override
  String get allEvents => 'All Events';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get every => 'Every';

  @override
  String get dayUnit => 'day(s)';

  @override
  String get weekUnit => 'week(s)';

  @override
  String get monthUnit => 'month(s)';

  @override
  String get onDay => 'On day';

  @override
  String get noEndDate => 'No end date';

  @override
  String endsOn(String date) {
    return 'Ends $date';
  }

  @override
  String get searchUnsplash => 'Search Unsplash';

  @override
  String get searchPhotosHint => 'Search photos...';

  @override
  String get noResults => 'No results found';

  @override
  String get downloadFailed => 'Failed to download image';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingPlanTitle => 'Plan Your Day';

  @override
  String get onboardingPlanDesc =>
      'Create events and tasks on your calendar. See what\'s coming up today and this week.';

  @override
  String get onboardingRecurringTitle => 'Recurring Events';

  @override
  String get onboardingRecurringDesc =>
      'Set events to repeat daily, weekly, or monthly. Never forget your routine.';

  @override
  String get onboardingTtsTitle => 'Read Aloud';

  @override
  String get onboardingTtsDesc =>
      'Tap the speaker button to hear event details read aloud. Works in English and Japanese.';

  @override
  String get onboardingReviewTitle => 'Review How You Feel';

  @override
  String get onboardingReviewDesc =>
      'After an event, rate how it went. If you\'re feeling down, we\'ll remind you of something to look forward to.';

  @override
  String get onboardingPhotoTitle => 'Add Photos';

  @override
  String get onboardingPhotoDesc =>
      'Attach photos from your camera, gallery, or search Unsplash for the perfect image.';
}
