import 'package:flutter/services.dart';

class ProfanityFilterService {
  List<RegExp> _patterns = [];

  /// Load the blacklist from the bundled asset file.
  Future<void> init() async {
    final data = await rootBundle.loadString('assets/blacklist.txt');
    _patterns = data
        .split('\n')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .map((w) => RegExp(RegExp.escape(w), caseSensitive: false))
        .toList();
  }

  /// Returns a list of field-level errors, or an empty list if clean.
  /// Mirrors the Rails `Item#profanity` validation.
  List<String> validate({required String title, required String details}) {
    final errors = <String>[];
    for (final pattern in _patterns) {
      if (pattern.hasMatch(title)) {
        errors.add("Title can't include obscene words");
        break;
      }
    }
    for (final pattern in _patterns) {
      if (pattern.hasMatch(details)) {
        errors.add("Details can't include obscene words");
        break;
      }
    }
    return errors;
  }
}
