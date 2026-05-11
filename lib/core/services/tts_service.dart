import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init({
    String language = 'en-US',
    double pitch = 1.0,
    double rate = 0.5,
  }) async {
    await _tts.setLanguage(language);
    await _tts.setPitch(pitch);
    await _tts.setSpeechRate(rate);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> setLanguage(String language) async {
    // Map short codes to TTS locale codes
    final locale = language == 'ja' ? 'ja-JP' : 'en-US';
    await _tts.setLanguage(locale);
  }

  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);

  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> stop() => _tts.stop();

  Future<List<dynamic>> getVoices() => _tts.getVoices;

  void dispose() {
    _tts.stop();
  }
}
