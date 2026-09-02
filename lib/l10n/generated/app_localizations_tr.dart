// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppL10nTr extends AppL10n {
  AppL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Valizim';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionCancel => 'Vazgeç';

  @override
  String get actionDelete => 'Sil';

  @override
  String get actionDone => 'Bitti';

  @override
  String get actionNext => 'İleri';

  @override
  String get actionBack => 'Geri';

  @override
  String get actionClose => 'Kapat';

  @override
  String get actionAdd => 'Ekle';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionShare => 'Paylaş';

  @override
  String get actionUndo => 'Geri al';

  @override
  String get actionContinue => 'Devam et';

  @override
  String get actionNotNow => 'Şimdi değil';

  @override
  String get actionOpenSettings => 'Ayarları aç';

  @override
  String get actionRemove => 'Kaldır';

  @override
  String get actionTryAgain => 'Tekrar dene';

  @override
  String get tripTypeBeach => 'Deniz tatili';

  @override
  String get tripTypeBeachHint => 'Güneş, kum ve deniz';

  @override
  String get tripTypeCity => 'Şehir gezisi';

  @override
  String get tripTypeCityHint => 'Yürüyüş, kafe ve müze';

  @override
  String get tripTypeBusiness => 'İş seyahati';

  @override
  String get tripTypeBusinessHint => 'Toplantı ve şık kıyafet';

  @override
  String get tripTypeCamping => 'Kamp';

  @override
  String get tripTypeCampingHint => 'Doğada ve kendi başına';

  @override
  String get tripTypeWinter => 'Kış tatili';

  @override
  String get tripTypeWinterHint => 'Soğuk hava ve kat kat giyinme';

  @override
  String get tripTypeGeneral => 'Genel';

  @override
  String get tripTypeGeneralHint => 'Sadece temel eşyalar';

  @override
  String get categoryDocuments => 'Belgeler';

  @override
  String get categoryClothing => 'Kıyafet';

  @override
  String get categoryToiletries => 'Kişisel bakım';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryElectronics => 'Elektronik';

  @override
  String get categoryGear => 'Ekipman';

  @override
  String get categoryMisc => 'Diğer';

  @override
  String get homeTitle => 'Seyahatlerim';

  @override
  String get homeCreateTrip => 'Seyahat planla';

  @override
  String get homeEmptyTitle => 'Henüz seyahat yok';

  @override
  String get homeEmptyBody =>
      'Bir seyahat oluştur, Valizim senin için bavul listeni hazırlasın. Hesap da internet de gerekmez.';

  @override
  String get homeEmptyAction => 'İlk seyahatini planla';

  @override
  String get homeSectionUpcoming => 'Yaklaşan';

  @override
  String get homeSectionPast => 'Geçmiş';

  @override
  String get homeSectionUndated => 'Tarihi belli değil';

  @override
  String get homeStartsToday => 'Bugün başlıyor';

  @override
  String get homeStartsTomorrow => 'Yarın başlıyor';

  @override
  String homeStartsInDays(int days) {
    return '$days gün sonra';
  }

  @override
  String homeStartedDaysAgo(int days) {
    return '$days gün önce';
  }

  @override
  String homeFreeTripsUsed(int used, int limit) {
    return '$limit ücretsiz seyahatin $used tanesi kullanıldı';
  }

  @override
  String get homeMenuDuplicate => 'Kopyala';

  @override
  String get homeMenuArchive => 'Geçmişe taşı';

  @override
  String get homeMenuUnarchive => 'Yaklaşana taşı';

  @override
  String get homeMenuDelete => 'Seyahati sil';

  @override
  String get homeDeleteTitle => 'Bu seyahat silinsin mi?';

  @override
  String homeDeleteBody(String name) {
    return '$name ve içindeki tüm eşyalar bu cihazdan kaldırılacak.';
  }

  @override
  String get homeTripDeleted => 'Seyahat silindi';

  @override
  String get homeTripArchived => 'Geçmişe taşındı';

  @override
  String get homeTripRestored => 'Yaklaşana taşındı';

  @override
  String homeCopySuffix(String name) {
    return '$name (kopya)';
  }

  @override
  String get homeTripDuplicated => 'Seyahat kopyalandı';

  @override
  String daysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün',
    );
    return '$_temp0';
  }

  @override
  String travelersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi',
    );
    return '$_temp0';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eşya',
    );
    return '$_temp0';
  }

  @override
  String packedOfTotal(int packed, int total) {
    return '$total eşyanın $packed tanesi hazır';
  }

  @override
  String remainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eşya kaldı',
    );
    return '$_temp0';
  }

  @override
  String get wizardTitle => 'Yeni seyahat';

  @override
  String get wizardEditTitle => 'Seyahati düzenle';

  @override
  String get wizardStepTypeTitle => 'Nasıl bir seyahat?';

  @override
  String get wizardStepTypeBody => 'Listende ne olacağını bu belirler.';

  @override
  String get wizardStepDetailsTitle => 'Seyahat bilgileri';

  @override
  String get wizardStepExtrasTitle => 'Başka bir şey var mı?';

  @override
  String get wizardStepExtrasBody =>
      'İsteğe bağlı. Her biri listene birkaç eşya ekler.';

  @override
  String get wizardNameLabel => 'Seyahat adı';

  @override
  String get wizardNameHint => 'Barselona hafta sonu';

  @override
  String get wizardNameRequired => 'Seyahatine bir ad ver';

  @override
  String wizardNameTooLong(int max) {
    return '$max karakterden kısa olsun';
  }

  @override
  String get wizardDurationLabel => 'Kaç gün?';

  @override
  String wizardDurationValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün',
    );
    return '$_temp0';
  }

  @override
  String get wizardTravelersLabel => 'Kişi sayısı';

  @override
  String get wizardStartDateLabel => 'Başlangıç tarihi';

  @override
  String get wizardStartDateHelp => 'İsteğe bağlı. Hatırlatıcı için gerekli.';

  @override
  String get wizardStartDateNone => 'Seçilmedi';

  @override
  String get wizardStartDateClear => 'Tarihi temizle';

  @override
  String get wizardOptionSwimming => 'Yüzme';

  @override
  String get wizardOptionSwimmingHint => 'Mayo ve hızlı kuruyan havlu';

  @override
  String get wizardOptionFormal => 'Özel davet';

  @override
  String get wizardOptionFormalHint => 'Özel gün kıyafeti ve klasik ayakkabı';

  @override
  String get wizardOptionWork => 'Dizüstü / iş';

  @override
  String get wizardOptionWorkHint => 'Laptop, şarj ve adaptör';

  @override
  String get wizardOptionLaundry => 'Çamaşır imkânı';

  @override
  String get wizardOptionLaundryHint => 'Uzun seyahatlerde daha az kıyafet';

  @override
  String get wizardSubmit => 'Bavul listesini oluştur';

  @override
  String get wizardSubmitEdit => 'Değişiklikleri kaydet';

  @override
  String wizardPreview(int count) {
    return 'Yaklaşık $count eşya';
  }

  @override
  String get listProgressTitle => 'hazır';

  @override
  String get listAllPacked => 'Her şey hazır. İyi yolculuklar.';

  @override
  String get listNothingPacked => 'Henüz hiçbir şey hazır değil.';

  @override
  String get listAddItem => 'Eşya ekle';

  @override
  String get listAddItemTitle => 'Eşya ekle';

  @override
  String get listEditItemTitle => 'Eşyayı düzenle';

  @override
  String get listItemLabel => 'Eşya';

  @override
  String get listItemHint => 'Güneş gözlüğü';

  @override
  String get listItemRequired => 'Bir eşya adı yaz';

  @override
  String get listQuantity => 'Adet';

  @override
  String get listSection => 'Bölüm';

  @override
  String get listEssentialToggle => 'Vazgeçilmez olarak işaretle';

  @override
  String get listEssentialBadge => 'Vazgeçilmez';

  @override
  String get listItemRemoved => 'Eşya kaldırıldı';

  @override
  String listItemLimit(int max) {
    return 'Bu seyahat en fazla $max eşya alabilir.';
  }

  @override
  String get listHideChecked => 'Hazır olanları gizle';

  @override
  String get listShowChecked => 'Hazır olanları göster';

  @override
  String get listUncheckAll => 'Tüm işaretleri kaldır';

  @override
  String get listUncheckAllDone => 'Tüm işaretler kaldırıldı';

  @override
  String get listMenuEdit => 'Seyahati düzenle';

  @override
  String get listMenuTemplate => 'Şablon olarak kaydet';

  @override
  String get listMenuRegenerate => 'Listeyi yeniden oluştur';

  @override
  String get listRegenerateTitle => 'Liste yeniden oluşturulsun mu?';

  @override
  String get listRegenerateBody =>
      'Tüm eşyalar baştan oluşturulur ve işaretlerin silinir. Kendi eklediğin eşyalar kaldırılır.';

  @override
  String get listRegenerateAction => 'Yeniden oluştur';

  @override
  String get listRegenerated => 'Liste yeniden oluşturuldu';

  @override
  String get listEmptyTitle => 'Bu liste boş';

  @override
  String get listEmptyBody =>
      'İlk eşyanı ekle ya da listeyi şablondan yeniden oluştur.';

  @override
  String get listSwipeDelete => 'Sil';

  @override
  String get listNotFound => 'Bu seyahate artık ulaşılamıyor.';

  @override
  String get remindersTitle => 'Kalkış hatırlatıcıları';

  @override
  String get remindersNeedsDateTitle => 'Önce bir başlangıç tarihi seç';

  @override
  String get remindersNeedsDateBody =>
      'Hatırlatıcılar kalkış saatine göre kurulur, bu yüzden seyahatin bir başlangıç tarihi olmalı.';

  @override
  String get remindersAddDate => 'Başlangıç tarihi ekle';

  @override
  String get remindersDayBefore => '1 gün önce';

  @override
  String remindersHoursBefore(int hours) {
    return '$hours saat önce';
  }

  @override
  String get remindersDepartureTime => 'Kalkış saati';

  @override
  String remindersScheduledAt(String time) {
    return 'Hatırlatıcı: $time';
  }

  @override
  String get remindersInThePast => 'Bu saat çoktan geçti';

  @override
  String get remindersBlockedTitle => 'Bildirimler kapalı';

  @override
  String get remindersBlockedBody =>
      'iOS Ayarları\'ndan bildirimlere izin vermeden Valizim hatırlatıcı gösteremez.';

  @override
  String get remindersSaved => 'Hatırlatıcılar güncellendi';

  @override
  String notificationTitle(String name) {
    return '$name için bavul zamanı';
  }

  @override
  String notificationBodyRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eşya hâlâ hazır değil.',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyReady => 'Listen tamam. İyi yolculuklar.';

  @override
  String get shareTitle => 'Listeyi paylaş';

  @override
  String get shareAsText => 'Metin olarak paylaş';

  @override
  String get shareAsTextHint => 'Her uygulamada çalışır';

  @override
  String get shareAsImage => 'Kart olarak paylaş';

  @override
  String get shareAsImageHint => 'İlerlemenin görseli';

  @override
  String get shareFailed => 'Şu anda paylaşım yapılamıyor.';

  @override
  String get shareCardTagline => 'Valizim ile hazırlandı';

  @override
  String shareTextHeader(String name) {
    return '$name - bavul listesi';
  }

  @override
  String shareTextMeta(String days, String travelers) {
    return '$days - $travelers';
  }

  @override
  String get shareTextFooter => 'Valizim ile hazırlandı';

  @override
  String get templatesTitle => 'Şablonlar';

  @override
  String get templatesBuiltIn => 'Hazır şablonlar';

  @override
  String get templatesCustom => 'Şablonlarım';

  @override
  String get templatesCustomEmptyTitle => 'Kayıtlı şablon yok';

  @override
  String get templatesCustomEmptyBody =>
      'Bir bavul listesini aç ve daha sonra kullanmak için Şablon olarak kaydet seçeneğini kullan.';

  @override
  String get templatesUse => 'Bu şablonu kullan';

  @override
  String get templatesDeleteTitle => 'Bu şablon silinsin mi?';

  @override
  String templatesDeleteBody(String name) {
    return '$name kaldırılacak. Bu şablondan oluşturulmuş seyahatler etkilenmez.';
  }

  @override
  String get templatesDeleted => 'Şablon silindi';

  @override
  String get templateSaveTitle => 'Şablon olarak kaydet';

  @override
  String get templateNameLabel => 'Şablon adı';

  @override
  String get templateSaved => 'Şablon kaydedildi';

  @override
  String templatesBuiltInCount(int count) {
    return '$count hazır şablon';
  }

  @override
  String get proTitle => 'Valizim Pro';

  @override
  String get proSubtitle => 'Tek ödeme. Sonsuza kadar senin.';

  @override
  String get proFreeHeading => 'Her zaman ücretsiz';

  @override
  String proFreeTrips(int limit) {
    return '$limit kayıtlı seyahat';
  }

  @override
  String get proFreeTemplates => 'Altı hazır seyahat şablonunun tamamı';

  @override
  String get proFreeOffline => 'Tamamen çevrimdışı çalışır';

  @override
  String get proFreeShareText => 'Listeni metin olarak paylaş';

  @override
  String get proUnlockHeading => 'Pro ile açılan';

  @override
  String get proUnlockUnlimited => 'Sınırsız kayıtlı seyahat';

  @override
  String get proUnlockTemplates => 'Kendi şablonlarını kaydet';

  @override
  String get proUnlockDuplicate => 'Her seyahati kopyala ve tekrar kullan';

  @override
  String get proUnlockShareCard => 'Özel paylaşım kartları';

  @override
  String get proBuy => 'Pro\'yu aç';

  @override
  String proBuyPriced(String price) {
    return 'Pro\'yu aç - $price';
  }

  @override
  String get proRestore => 'Satın alımı geri yükle';

  @override
  String get proOwnedTitle => 'Pro\'ya sahipsin';

  @override
  String get proOwnedBody => 'Valizim\'i desteklediğin için teşekkürler.';

  @override
  String get proPending => 'Satın alman onay bekliyor.';

  @override
  String get proCancelled => 'Satın alma iptal edildi.';

  @override
  String get proFailed => 'Satın alma tamamlanamadı.';

  @override
  String get proRestored => 'Satın alım geri yüklendi. Pro açıldı.';

  @override
  String get proNothingToRestore =>
      'Bu Apple hesabı için önceki bir satın alım bulunamadı.';

  @override
  String get proUnavailable => 'App Store şu anda kullanılamıyor.';

  @override
  String get proPriceLoading => 'Fiyat yükleniyor';

  @override
  String get proPriceUnavailable => 'Fiyat alınamadı';

  @override
  String get proLegalNote =>
      'Ödeme Apple hesabından tahsil edilir. Bu tek seferlik bir satın alımdır, abonelik değildir.';

  @override
  String proLimitTitle(int limit) {
    return '$limit ücretsiz seyahatin tamamını kullandın';
  }

  @override
  String get proLimitBody =>
      'Sınırsız seyahat için Pro\'yu aç ya da yer açmak için bir seyahati sil.';

  @override
  String get proBadge => 'Pro';

  @override
  String get proLockedDuplicate => 'Seyahat kopyalama bir Pro özelliğidir.';

  @override
  String get proLockedTemplates => 'Özel şablonlar bir Pro özelliğidir.';

  @override
  String get proLockedShareCard => 'Paylaşım kartları bir Pro özelliğidir.';

  @override
  String get proSeeWhatsIncluded => 'Neler dahil, bak';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSectionDefaults => 'Yeni seyahat varsayılanları';

  @override
  String get settingsDefaultTravelers => 'Varsayılan kişi sayısı';

  @override
  String get settingsDefaultDuration => 'Varsayılan seyahat süresi';

  @override
  String get settingsSectionNotifications => 'Bildirimler';

  @override
  String get settingsNotificationStatus => 'Sistem izni';

  @override
  String get settingsNotificationAllowed => 'İzin verildi';

  @override
  String get settingsNotificationBlocked => 'Engellendi';

  @override
  String get settingsNotificationNotAsked => 'Henüz istenmedi';

  @override
  String get settingsNotificationBlockedHelp =>
      'iOS Ayarları\'ndan izin verilmeden hatırlatıcılar gönderilemez.';

  @override
  String get settingsSectionData => 'Veriler';

  @override
  String get settingsResetTemplates => 'Yeni seyahat varsayılanlarını sıfırla';

  @override
  String get settingsResetTemplatesBody =>
      'Kişi sayısını ve seyahat süresini özgün değerlerine döndürür. Seyahatlerine ve kayıtlı şablonlarına dokunulmaz.';

  @override
  String get settingsResetTemplatesDone => 'Varsayılanlar sıfırlandı';

  @override
  String get settingsDeleteAll => 'Tüm uygulama verilerini sil';

  @override
  String get settingsDeleteAllStep1Title => 'Her şey silinsin mi?';

  @override
  String get settingsDeleteAllStep1Body =>
      'Tüm seyahatler, eşyalar ve kayıtlı şablonlar bu cihazdan kalıcı olarak silinir.';

  @override
  String get settingsDeleteAllStep2Title => 'Bu işlem geri alınamaz';

  @override
  String settingsDeleteAllStep2Body(String count) {
    return 'Yedek ya da bulut kopyası yok. Yine de $count silinsin mi?';
  }

  @override
  String get settingsDeleteAllConfirm => 'Her şeyi sil';

  @override
  String get settingsDeleteAllDone => 'Tüm uygulama verileri silindi';

  @override
  String get settingsSectionAbout => 'Hakkında';

  @override
  String settingsVersion(String version, String build) {
    return 'Sürüm $version ($build)';
  }

  @override
  String get settingsPrivacy => 'Gizlilik';

  @override
  String get settingsTerms => 'Kullanım koşulları';

  @override
  String get settingsContact => 'Destek ile iletişim';

  @override
  String settingsRulesVersion(int version) {
    return 'Bavul kuralları v$version';
  }

  @override
  String get privacyTitle => 'Gizlilik';

  @override
  String get privacyHeadline => 'Seyahatlerin bu cihazda kalır.';

  @override
  String get privacyOnDeviceTitle => 'Yalnızca telefonunda saklanır';

  @override
  String get privacyOnDeviceBody =>
      'Seyahatler, eşyalar ve şablonlar uygulamanın içindeki bir veritabanında durur. Hiçbir şey hiçbir yere yüklenmez.';

  @override
  String get privacyNoAccountTitle => 'Hesap yok, takip yok';

  @override
  String get privacyNoAccountBody =>
      'Valizim\'de giriş, analitik ya da reklam yoktur. Kim olduğun hiç sorulmaz.';

  @override
  String get privacyNotificationsTitle => 'Hatırlatıcılar cihazda';

  @override
  String get privacyNotificationsBody =>
      'Kalkış hatırlatıcıları bu cihazda iOS tarafından kurulur. Hiçbir sunucu bildirim göndermez.';

  @override
  String get privacyPurchaseTitle => 'Satın alımlar Apple üzerinden';

  @override
  String get privacyPurchaseBody =>
      'Pro\'yu açarsan ödemeyi Apple yürütür ve uygulamaya yalnızca sahip olup olmadığını bildirir. Valizim ödeme bilgilerini hiç görmez.';

  @override
  String get privacySharingTitle => 'Paylaşım sana bağlı';

  @override
  String get privacySharingBody =>
      'Bir liste yalnızca sen paylaş dediğinde cihazdan çıkar ve sadece seyahat adı, eşyalar ve ilerleme yer alır.';

  @override
  String get privacyOpenPolicy => 'Gizlilik politikasının tamamını oku';

  @override
  String get privacyLinkFailed => 'Bağlantı açılamadı.';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti.';

  @override
  String get errorSaveFailed => 'Değişiklikler kaydedilemedi.';

  @override
  String get stepperDecrease => 'Azalt';

  @override
  String get stepperIncrease => 'Artır';
}
