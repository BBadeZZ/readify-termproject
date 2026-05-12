// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navLibrary => 'Kütüphane';

  @override
  String get navAnalytics => 'Analitik';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get navSuggest => 'Öneriler';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAddBook => 'Kitap Ekle';

  @override
  String get navRecommendations => 'Öneriler';

  @override
  String get navLogout => 'Çıkış Yap';

  @override
  String get statusReading => 'Okunuyor';

  @override
  String get statusWishlist => 'İstek Listesi';

  @override
  String get statusAlreadyRead => 'Okundu';

  @override
  String get welcomeSubtitle =>
      'Akıllı Kitap Takibi\nve Okuma Analitiği Uygulaması';

  @override
  String get welcomeTagline =>
      'Kitap severlere yönelik sevimli ve akıllı okuma günlüğü 💛';

  @override
  String get welcomeLogin => 'Giriş Yap';

  @override
  String get welcomeRegister => 'Kayıt Ol';

  @override
  String get loginWelcomeBack => 'Tekrar Hoş Geldiniz!';

  @override
  String get loginSubtitle => 'Okumaya devam etmek için giriş yapın';

  @override
  String get loginEmail => 'E-posta';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get loginNoAccount => 'Hesabınız yok mu? ';

  @override
  String get loginRegisterLink => 'Kayıt Ol';

  @override
  String get loginErrEmailEmpty => 'Lütfen e-postanızı girin.';

  @override
  String get loginErrEmailInvalid => 'Geçerli bir e-posta girin.';

  @override
  String get loginErrPasswordEmpty => 'Lütfen şifrenizi girin.';

  @override
  String get loginErrUserNotFound => 'Bu e-posta ile hesap bulunamadı.';

  @override
  String get loginErrWrongPassword => 'E-posta veya şifre hatalı.';

  @override
  String get loginErrInvalidEmail => 'Geçerli bir e-posta adresi girin.';

  @override
  String get loginErrTooManyRequests =>
      'Çok fazla deneme. Lütfen daha sonra deneyin.';

  @override
  String get loginErrGeneral => 'Giriş başarısız. Lütfen tekrar deneyin.';

  @override
  String get registerCreateAccount => 'Hesap Oluştur';

  @override
  String get registerSubtitle => 'Okuma yolculuğunuza başlayın';

  @override
  String get registerFullName => 'Ad Soyad';

  @override
  String get registerEmail => 'E-posta';

  @override
  String get registerPassword => 'Şifre';

  @override
  String get registerConfirmPassword => 'Şifreyi Onayla';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get registerHaveAccount => 'Zaten hesabınız var mı? ';

  @override
  String get registerLoginLink => 'Giriş Yap';

  @override
  String get registerErrNameEmpty => 'Lütfen adınızı girin.';

  @override
  String get registerErrEmailEmpty => 'Lütfen e-postanızı girin.';

  @override
  String get registerErrEmailInvalid => 'Geçerli bir e-posta girin.';

  @override
  String get registerErrPasswordEmpty => 'Lütfen şifre girin.';

  @override
  String get registerErrPasswordShort => 'Şifre en az 6 karakter olmalı.';

  @override
  String get registerErrConfirmEmpty => 'Lütfen şifrenizi onaylayın.';

  @override
  String get registerErrPasswordMismatch => 'Şifreler eşleşmiyor.';

  @override
  String get registerErrEmailInUse => 'Bu e-posta zaten kayıtlı.';

  @override
  String get registerErrWeakPassword => 'Şifre en az 6 karakter olmalı.';

  @override
  String get registerErrGeneral => 'Kayıt başarısız. Lütfen tekrar deneyin.';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingGetStarted => 'Başla';

  @override
  String get onboarding1Title => 'Readify\'a Hoş Geldiniz';

  @override
  String get onboarding1Desc =>
      'Dijital okuma günlüğünüz.\nOkuduğunuz her kitabı ekleyin ve takibini kaybetmeyin.';

  @override
  String get onboarding2Title => 'Okuma Seanslarını Takip Et';

  @override
  String get onboarding2Desc =>
      'Okumaya başlayınca seans başlatın.\nGünlük okuma sürenizi ve haftalık ilerlemenizi Analitik\'te görün.';

  @override
  String get onboarding3Title => 'Kitapları Anında Keşfet';

  @override
  String get onboarding3Desc =>
      'Tek dokunuşla milyonlarca kitabı arayın.\nBaşlık, yazar, kapak ve sayfa sayısı otomatik dolar.';

  @override
  String streakDays(int days) {
    return '$days günlük seri';
  }

  @override
  String get streakStart => 'Bugün okumaya başla!';

  @override
  String get homeGreetMorning => 'Günaydın';

  @override
  String get homeGreetAfternoon => 'İyi öğleler';

  @override
  String get homeGreetEvening => 'İyi akşamlar';

  @override
  String get homeReader => 'Okuyucu';

  @override
  String get homeSubtitle => 'Okuma özetiniz';

  @override
  String get homeTotalBooks => 'Toplam Kitap';

  @override
  String get homeReading => 'Okunuyor';

  @override
  String get homeAlreadyRead => 'Okundu';

  @override
  String get homePagesRead => 'Okunan Sayfa';

  @override
  String get homeCurrentlyReading => 'Şu An Okunanlar';

  @override
  String get homeSeeAll => 'Tümünü gör';

  @override
  String get homeQuickActions => 'Hızlı İşlemler';

  @override
  String get homeMyLibrary => 'Kütüphanem';

  @override
  String get homeSuggestions => 'Öneriler';

  @override
  String get homeAddBook => 'Kitap Ekle';

  @override
  String homeBooksAlreadyRead(int count) {
    return '$count kitap okundu';
  }

  @override
  String get homeViewHistory => 'Okuma geçmişinizi görmek için dokunun';

  @override
  String get homeGoalTitle => 'Bugünkü Hedef';

  @override
  String get homeGoalReached => 'Hedefe ulaştın! 🎉';

  @override
  String homeGoalProgress(int done, int goal) => '$done / $goal sayfa';

  @override
  String get libraryTitle => 'Kütüphanem';

  @override
  String get librarySearchHint => 'Başlık, yazar, tür ara…';

  @override
  String get libraryFilterAll => 'Tümü';

  @override
  String get libraryFilterFavorites => 'Favoriler';

  @override
  String get librarySortDateAdded => 'Eklenme Tarihi';

  @override
  String get librarySortTitle => 'Başlık';

  @override
  String get librarySortAuthor => 'Yazar';

  @override
  String get librarySortProgress => 'İlerleme';

  @override
  String libraryBooksCount(int count) {
    return '$count kitap';
  }

  @override
  String get libraryEmptyFavorites =>
      'Henüz favori yok.\nHerhangi bir kitabın kalp ikonuna dokunun.';

  @override
  String get libraryEmptyReading => 'Şu an hiçbir şey okunmuyor.';

  @override
  String get libraryEmptyWishlist => 'İstek listeniz boş.';

  @override
  String get libraryEmptyAlreadyRead => 'Henüz tamamlanan kitap yok.';

  @override
  String get libraryEmptyDefault => 'Kitap bulunamadı. Bir tane ekle!';

  @override
  String libraryNoResults(String query) {
    return '\"$query\" için sonuç bulunamadı';
  }

  @override
  String get libraryDelete => 'Sil';

  @override
  String libraryDeleted(String title) {
    return '\"$title\" silindi.';
  }

  @override
  String get libraryUndo => 'Geri Al';

  @override
  String get libraryErrFavorite => 'Favori güncellenemedi.';

  @override
  String get libraryErrDelete => 'Kitap silinemedi.';

  @override
  String get libraryErrRestore => 'Kitap geri yüklenemedi.';

  @override
  String get librarySomethingWrong => 'Bir sorun oluştu.';

  @override
  String get analyticsTitle => 'Analitik';

  @override
  String get analyticsReadingSummary => 'Okuma Özeti';

  @override
  String get analyticsOverallProgress => 'Genel İlerleme';

  @override
  String get analyticsTotalBooks => 'Toplam Kitap';

  @override
  String get analyticsReading => 'Okunuyor';

  @override
  String get analyticsAlreadyRead => 'Okundu';

  @override
  String get analyticsWishlist => 'İstek Listesi';

  @override
  String get analyticsFavorites => 'Favoriler';

  @override
  String get analyticsPagesRead => 'Okunan Sayfa';

  @override
  String get analyticsAvgRating => 'Ort. Puan';

  @override
  String get analyticsReadingSessions => 'Okuma Seansları';

  @override
  String get analyticsNoSessions => 'Henüz seans yok.\nOkuma seansı başlat!';

  @override
  String get analyticsRecentSessions => 'Son Seanslar';

  @override
  String get analyticsSessions => 'Seanslar';

  @override
  String get analyticsTotalTime => 'Toplam Süre';

  @override
  String get analyticsPagesThisWeek => 'Bu Hafta Sayfa';

  @override
  String get analyticsAvgSession => 'Ort. Seans';

  @override
  String get profileTitle => 'Profilim';

  @override
  String profileFavoriteGenre(String genre) {
    return 'Favori tür: $genre';
  }

  @override
  String get profileLibrary => 'Kütüphane';

  @override
  String get profileActivity => 'Okuma Aktivitesi';

  @override
  String get profileTotalBooks => 'Toplam Kitap';

  @override
  String get profileFinished => 'Bitti';

  @override
  String get profileReading => 'Okunuyor';

  @override
  String get profileWishlist => 'İstek Listesi';

  @override
  String get profileFavorites => 'Favoriler';

  @override
  String get profilePagesRead => 'Okunan Sayfa';

  @override
  String get profileSessions => 'Seanslar';

  @override
  String get profileTotalTime => 'Toplam Süre';

  @override
  String get profileAvgSession => 'Ort. Seans';

  @override
  String get profilePagesInSessions => 'Seanslardaki Sayfa';

  @override
  String get profileNoSessions =>
      'Henüz okuma seansı yok.\nBir kitap aç ve okumaya başla!';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsDailyReminder => 'Günlük Okuma Hatırlatıcısı';

  @override
  String get settingsDailyReminderSub => 'Günlük bildirim al';

  @override
  String get settingsReminderTime => 'Hatırlatma Saati';

  @override
  String get settingsHighlightFavorites => 'Favori Kitapları Vurgula';

  @override
  String settingsDailyGoal(int count) {
    return 'Günlük Okuma Hedefi: $count sayfa';
  }

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsBrightnessLight => 'Açık';

  @override
  String get settingsBrightnessDark => 'Koyu';

  @override
  String get settingsBrightnessSystem => 'Sistem';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get addBookTitle => 'Kitap Ekle';

  @override
  String get addBookSearchCardTitle => 'Otomatik doldur';

  @override
  String get addBookSearchCardSub =>
      'Başlık veya yazara göre ara — formu otomatik doldurur';

  @override
  String get fieldBookTitle => 'Kitap Başlığı';

  @override
  String get fieldGenre => 'Tür';

  @override
  String get fieldAuthor => 'Yazar';

  @override
  String get fieldCoverUrlOptional => 'Kapak URL\'i (isteğe bağlı)';

  @override
  String get fieldCoverUrl => 'Kapak URL\'i';

  @override
  String get fieldTotalPages => 'Toplam Sayfa';

  @override
  String get fieldCurrentPage => 'Mevcut Sayfa';

  @override
  String get fieldNote => 'Kişisel Not';

  @override
  String get fieldFavorite => 'Favorilere ekle';

  @override
  String get fieldFavoriteShort => 'Favori';

  @override
  String fieldRating(int value) {
    return 'Puan: $value / 5';
  }

  @override
  String get fieldReadingStatus => 'Okuma Durumu';

  @override
  String get addBookSave => 'Kitabı Kaydet';

  @override
  String get addBookSaving => 'Kaydediliyor…';

  @override
  String get addBookSuccess => 'Kitap başarıyla eklendi.';

  @override
  String get addBookFailed => 'Kitap kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String addBookAutoFill(String title) {
    return '\"$title\" otomatik olarak dolduruldu.';
  }

  @override
  String addBookPartialFill(String title, String missing) {
    return '\"$title\" kısmen dolduruldu. Lütfen $missing kısmını manuel girin.';
  }

  @override
  String get editBookTitle => 'Kitap Düzenle';

  @override
  String get editBookUpdate => 'Kitabı Güncelle';

  @override
  String get editBookSaving => 'Kaydediliyor…';

  @override
  String get editBookSuccess => 'Kitap başarıyla güncellendi.';

  @override
  String get editBookFailed => 'Kitap güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get searchHintSheet => 'Başlık veya yazara göre ara...';

  @override
  String get searchNoResults => 'Sonuç bulunamadı.';

  @override
  String get validatorTitleRequired => 'Başlık gerekli';

  @override
  String get validatorAuthorRequired => 'Yazar gerekli';

  @override
  String get validatorPagesRequired => 'Geçerli bir sayfa sayısı girin';

  @override
  String get detailTitle => 'Kitap Detayı';

  @override
  String get detailReadingProgress => 'Okuma İlerlemesi';

  @override
  String pagesProgress(int current, int total) {
    return '$total sayfanın $current sayfası';
  }

  @override
  String detailPages(int count) {
    return '$count sayfa';
  }

  @override
  String get detailSaveProgress => 'İlerlemeyi Kaydet';

  @override
  String get detailStartSession => 'Okuma Seansı Başlat';

  @override
  String get detailFinishSession => 'Okuma Seansını Bitir';

  @override
  String get detailSessionInProgress => 'Seans devam ediyor';

  @override
  String get detailFinishDialogTitle => 'Okuma Seansını Bitir';

  @override
  String detailDuration(String time) {
    return 'Süre: $time';
  }

  @override
  String get detailWhatPage => 'Kaçıncı sayfaya geldiniz?';

  @override
  String get detailSaveSession => 'Seansı Kaydet';

  @override
  String get detailCancel => 'İptal';

  @override
  String detailSessionSaved(int duration, int pages) {
    return 'Seans kaydedildi! ${duration}d · $pages sayfa okundu';
  }

  @override
  String get detailErrSaveSession =>
      'Seans kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get detailProgressSaved => 'İlerleme kaydedildi.';

  @override
  String get detailErrProgress =>
      'İlerleme kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get detailErrFavorite => 'Favori güncellenemedi.';

  @override
  String get detailErrRating => 'Puan kaydedilemedi.';

  @override
  String get recsTitle => 'Kitap Önerileri';

  @override
  String get recsAllRead => 'Tüm önerilen kitapları zaten okudunuz 💛';

  @override
  String recsAuthor(String name) {
    return 'Yazar: $name';
  }

  @override
  String recsGenre(String genre) {
    return 'Tür: $genre';
  }

  @override
  String recsPages(int count) {
    return 'Sayfa: $count';
  }

  @override
  String recsRating(String rating) {
    return 'Puan: $rating';
  }

  @override
  String get recsClose => 'Kapat';

  @override
  String get recsAddBook => 'Bu Kitabı Ekle';

  @override
  String get recsAddFavorite => 'Favorilere Ekle';
}
