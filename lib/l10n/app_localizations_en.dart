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
}
