// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Autism AVC';

  @override
  String get today => '今日';

  @override
  String get calendar => 'カレンダー';

  @override
  String get settings => '設定';

  @override
  String get newEvent => '新しいイベント';

  @override
  String get editEvent => 'イベントを編集';

  @override
  String get title => 'タイトル';

  @override
  String get details => '詳細';

  @override
  String get start => '開始';

  @override
  String get end => '終了';

  @override
  String get create => '作成';

  @override
  String get update => '更新';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get readAloud => '読み上げ';

  @override
  String get review => 'レビュー';

  @override
  String get submit => '送信';

  @override
  String get done => '完了';

  @override
  String get thankYou => 'ありがとう！';

  @override
  String get howDoYouFeel => 'どう感じましたか？';

  @override
  String get noEventsToday => '今日のイベントはありません。\n＋をタップして追加！';

  @override
  String get noEventsOnDay => 'この日のイベントはありません';

  @override
  String get deleteConfirm => 'このイベントを削除してもよろしいですか？';

  @override
  String get language => '言語';

  @override
  String get textToSpeech => '音声読み上げ';

  @override
  String get pitch => 'ピッチ';

  @override
  String get speed => '速度';

  @override
  String get previewVoice => '音声プレビュー';

  @override
  String happyMessage(String details) {
    return '教えてくれてありがとう！その気持ちわかるよ。でも大丈夫！ もうすぐ$details';
  }

  @override
  String get titleRequired => 'タイトルは必須です';

  @override
  String get detailsRequired => '詳細は必須です';

  @override
  String get profanityTitle => 'タイトルに不適切な言葉を含めることはできません';

  @override
  String get profanityDetails => '詳細に不適切な言葉を含めることはできません';
}
