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

  @override
  String get thisWeek => '今週';

  @override
  String get tomorrow => '明日';

  @override
  String get child => '子ども';

  @override
  String get repeat => '繰り返し';

  @override
  String get none => 'なし';

  @override
  String get photo => '写真';

  @override
  String get unsplash => 'Unsplash';

  @override
  String get notSet => '未設定';

  @override
  String get ratingSad => '悲しい';

  @override
  String get ratingOkay => 'まあまあ';

  @override
  String get ratingGood => '良い';

  @override
  String get ratingGreat => '最高';

  @override
  String get timezone => 'タイムゾーン';

  @override
  String get selectTimezone => 'タイムゾーンを選択';

  @override
  String get voicePreviewText => 'これは音声のプレビューです';

  @override
  String get deleteEvent => 'イベントを削除';

  @override
  String get recurringLabel => '繰り返し';

  @override
  String get editRecurringEvent => '繰り返しイベントを編集';

  @override
  String get editRecurringMessage => 'すべてのイベントを編集しますか、それともこの回のみですか？';

  @override
  String get justThisOne => 'この回のみ';

  @override
  String get allEvents => 'すべてのイベント';

  @override
  String get daily => '毎日';

  @override
  String get weekly => '毎週';

  @override
  String get monthly => '毎月';

  @override
  String get every => '毎';

  @override
  String get dayUnit => '日';

  @override
  String get weekUnit => '週';

  @override
  String get monthUnit => '月';

  @override
  String get onDay => '毎月';

  @override
  String get noEndDate => '終了日なし';

  @override
  String endsOn(String date) {
    return '$dateに終了';
  }

  @override
  String get searchUnsplash => 'Unsplashを検索';

  @override
  String get searchPhotosHint => '写真を検索...';

  @override
  String get noResults => '結果が見つかりません';

  @override
  String get downloadFailed => '画像のダウンロードに失敗しました';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get getStarted => 'はじめる';

  @override
  String get onboardingPlanTitle => '一日を計画しよう';

  @override
  String get onboardingPlanDesc => 'カレンダーにイベントやタスクを作成。今日と今週の予定を確認できます。';

  @override
  String get onboardingRecurringTitle => '繰り返しイベント';

  @override
  String get onboardingRecurringDesc => 'イベントを毎日、毎週、毎月繰り返すよう設定。日課を忘れません。';

  @override
  String get onboardingTtsTitle => '読み上げ';

  @override
  String get onboardingTtsDesc => 'スピーカーボタンをタップすると、イベントの詳細を読み上げます。英語と日本語に対応。';

  @override
  String get onboardingReviewTitle => '気持ちをレビュー';

  @override
  String get onboardingReviewDesc =>
      'イベントの後、どうだったか評価しましょう。気分が落ちているときは、楽しみなことを思い出させます。';

  @override
  String get onboardingPhotoTitle => '写真を追加';

  @override
  String get onboardingPhotoDesc => 'カメラ、ギャラリー、またはUnsplashから写真を添付できます。';

  @override
  String get month => '月';

  @override
  String get week => '週';

  @override
  String get day => '日';

  @override
  String get allDay => '終日';

  @override
  String get noTime => '時間未設定';

  @override
  String get goBack => '戻る';
}
