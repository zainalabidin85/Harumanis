// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get languageRowTitle => 'Bahasa / Language';

  @override
  String get languageMalay => 'Bahasa Malaysia';

  @override
  String get languageEnglish => 'English';

  @override
  String get stageEarly => 'Awal';

  @override
  String get stageBagging => 'Pembalutan';

  @override
  String get stagePreHarvest => 'Pra-tuai';

  @override
  String get stageUnknown => 'Tidak diketahui';

  @override
  String stageBadge(int stage, String label) {
    return 'Peringkat $stage · $label';
  }

  @override
  String get orderStatusPending => 'Menunggu';

  @override
  String get orderStatusConfirmed => 'Disahkan';

  @override
  String get orderStatusHarvested => 'Dituai';

  @override
  String get orderStatusDelivered => 'Dihantar';

  @override
  String get orderStatusCancelled => 'Dibatalkan';

  @override
  String get updateRequiredTitle => 'Kemas Kini Diperlukan';

  @override
  String get updateAvailableTitle => 'Kemas Kini Tersedia';

  @override
  String updateRequiredBody(String version) {
    return 'Beli Harumanis v$version diperlukan. Muat turun APK terkini untuk meneruskan.';
  }

  @override
  String updateAvailableBody(String version) {
    return 'Beli Harumanis v$version kini tersedia dengan ciri baharu dan pembaikan.';
  }

  @override
  String get updateLater => 'Nanti';

  @override
  String get updateExit => 'Keluar';

  @override
  String get updateOk => 'OK';

  @override
  String get updateDownload => 'Muat turun';

  @override
  String get commonEmail => 'E-mel';

  @override
  String get commonPassword => 'Kata laluan';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonRetry => 'Cuba lagi';

  @override
  String get commonFullName => 'Nama penuh';

  @override
  String get commonTotal => 'Jumlah';

  @override
  String get commonNoConnection =>
      'Tidak dapat menghubungi pelayan. Semak sambungan anda.';

  @override
  String get loginTagline => 'Segar dari ladang, terus kepada anda';

  @override
  String get loginWelcomeBack => 'Selamat kembali';

  @override
  String get loginSubtitle => 'Log masuk ke akaun pembeli anda';

  @override
  String get loginErrorFarmerAccount =>
      'Akaun ini didaftarkan sebagai pekebun. Sila gunakan aplikasi Ai-Harumanis.';

  @override
  String get loginErrorInvalidCredentials => 'E-mel atau kata laluan tidak sah';

  @override
  String get loginErrorFailed => 'Log masuk gagal. Sila cuba lagi.';

  @override
  String get loginForgotPasswordLink => 'Lupa kata laluan?';

  @override
  String get loginSignInButton => 'Log masuk';

  @override
  String get loginNoAccountPrompt => 'Belum ada akaun? ';

  @override
  String get loginRegister => 'Daftar';

  @override
  String get loginErrorEnterEmail => 'Sila masukkan e-mel anda.';

  @override
  String get loginErrorSendCodeFailed => 'Gagal menghantar kod.';

  @override
  String get loginPasswordResetDone =>
      'Kata laluan ditetapkan semula! Sila log masuk.';

  @override
  String get loginErrorInvalidCode => 'Kod tidak sah atau telah luput.';

  @override
  String get loginEnterResetCodeTitle => 'Masukkan Kod Tetapan Semula';

  @override
  String get loginForgotPasswordTitle => 'Lupa Kata Laluan';

  @override
  String get loginForgotPasswordBody =>
      'Masukkan e-mel anda untuk menerima kod tetapan semula.';

  @override
  String loginCodeSentTo(String email) {
    return 'Kod telah dihantar ke $email.';
  }

  @override
  String get loginSixDigitCodeLabel => 'Kod 6 digit';

  @override
  String get loginNewPasswordLabel => 'Kata laluan baharu';

  @override
  String get loginResetPasswordButton => 'Tetapkan Semula';

  @override
  String get loginSendCodeButton => 'Hantar Kod';

  @override
  String get loginCreateAccountTitle => 'Daftar Akaun Pembeli';

  @override
  String get loginDeliveryAddressRequiredLabel => 'Alamat penghantaran *';

  @override
  String get loginPhoneOptionalLabel => 'Telefon (pilihan)';

  @override
  String get loginWhatsappOptionalLabel => 'Nombor WhatsApp (pilihan)';

  @override
  String get loginErrorRegisterRequired =>
      'Nama, e-mel, alamat dan kata laluan diperlukan.';

  @override
  String get loginAccountCreated =>
      'Akaun berjaya didaftarkan! Sila log masuk.';

  @override
  String loginErrorRegisterFailed(String detail) {
    return 'Pendaftaran gagal: $detail';
  }

  @override
  String get deliveryAddressHint => 'Alamat penuh untuk penghantaran mangga';

  @override
  String get marketErrorLoad =>
      'Gagal memuatkan ladang. Tarik ke bawah untuk muat semula.';

  @override
  String get marketMyOrdersTooltip => 'Pesanan Saya';

  @override
  String get marketProfileTooltip => 'Profil';

  @override
  String get marketHeroSubtitle => 'Mangga terbaik Malaysia';

  @override
  String get marketPillDirect => 'Terus dari ladang';

  @override
  String get marketPillAiTracked => 'Tuaian dijejak AI';

  @override
  String marketFarmsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ladang tersedia',
    );
    return '$_temp0';
  }

  @override
  String marketMangoCount(int count) {
    return '$count biji mangga';
  }

  @override
  String marketReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '($count ulasan)',
    );
    return '$_temp0';
  }

  @override
  String get marketReadyToHarvest => 'Sedia dituai!';

  @override
  String marketHarvestIn(int days) {
    return 'Tuai dalam $days hari';
  }

  @override
  String get marketGrowthStages => 'Peringkat pertumbuhan';

  @override
  String marketLegendCount(String stage, int count) {
    return '$stage $count';
  }

  @override
  String get marketComingSoon => 'Akan Datang';

  @override
  String get marketComingSoonBody =>
      'Ladang Harumanis dari Perlis & Kedah\nakan dipaparkan di sini setelah disenaraikan.';

  @override
  String get marketWhatIsHarumanis => 'Apa itu Harumanis?';

  @override
  String get marketFact1 =>
      'Varieti mangga paling berharga di Malaysia — hanya ditanam di Perlis & Kedah';

  @override
  String get marketFact2 =>
      'Isi sangat manis, tiada serat, dengan aroma madu yang tersendiri';

  @override
  String get marketFact3 =>
      'Musim yang singkat — dituai setahun sekali, menjadikannya jarang dan sangat dicari';

  @override
  String get marketFact4 =>
      'Pesan terus dari ladang — segar, boleh dijejak, tanpa orang tengah';

  @override
  String get marketPullToRefresh =>
      'Tarik ke bawah untuk muat semula setelah ladang disenaraikan.';

  @override
  String get farmErrorLoad => 'Gagal memuatkan butiran ladang.';

  @override
  String get farmOwnerVerified => 'Pemilik Ladang Disahkan';

  @override
  String get farmOwner => 'Pemilik Ladang';

  @override
  String get farmAvailableFruit => 'Buah Tersedia';

  @override
  String get farmNearHarvest => 'Hampir dituai';

  @override
  String get farmFirstHarvest => 'Tuaian pertama';

  @override
  String get farmTreeBreakdown => 'Pecahan Mengikut Pokok';

  @override
  String farmTreeNumber(String number) {
    return 'Pokok $number';
  }

  @override
  String farmEstHarvest(String date) {
    return 'Anggaran tuai: $date';
  }

  @override
  String farmFruitCount(int count) {
    return '$count buah';
  }

  @override
  String get farmNoFruits => 'Belum ada buah dikesan.';

  @override
  String get farmRemindMe => 'Ingatkan Saya';

  @override
  String get farmPlaceOrder => 'Buat Pesanan';

  @override
  String get farmReviews => 'Ulasan';

  @override
  String farmReviewCount(int count) {
    return '$count ulasan';
  }

  @override
  String get farmNoReviews =>
      'Belum ada ulasan. Jadilah yang pertama berkongsi pengalaman anda!';

  @override
  String get ordersPaymentConfirmed =>
      'Bayaran disahkan! Pesanan anda kini aktif.';

  @override
  String get ordersErrorLoad => 'Gagal memuatkan pesanan.';

  @override
  String get ordersTitle => 'Pesanan Saya';

  @override
  String get ordersEmpty => 'Belum ada pesanan';

  @override
  String get ordersEmptyBody => 'Lihat ladang dan buat pesanan pertama anda!';

  @override
  String get ordersPaymentPending => 'Belum dibayar — tekan untuk bayar';

  @override
  String orderDetailPaymentFailed(String detail) {
    return 'Bayaran gagal: $detail';
  }

  @override
  String orderDetailWhatsappMessage(int id, String quantity, String farm) {
    return 'Hai, saya telah membuat Pesanan #$id untuk $quantity kg Harumanis dari $farm.';
  }

  @override
  String orderDetailTitle(int id) {
    return 'Pesanan #$id';
  }

  @override
  String get orderDetailPlaced => 'Pesanan dibuat!';

  @override
  String get orderDetailWaitingConfirm =>
      'Menunggu pekebun mengesahkan pesanan anda.';

  @override
  String get orderDetailStatus => 'Status';

  @override
  String get orderDetailFarm => 'Ladang';

  @override
  String get orderDetailQuantity => 'Kuantiti';

  @override
  String get orderDetailPricePerKg => 'Harga sekilogram';

  @override
  String get orderDetailPayment => 'Bayaran';

  @override
  String get orderDetailPaidTick => 'Dibayar ✓';

  @override
  String get orderDetailPaymentPending => 'Belum dibayar';

  @override
  String get orderDetailTargetDate => 'Tarikh sasaran';

  @override
  String get orderDetailOrderedOn => 'Dipesan pada';

  @override
  String orderDetailNotes(String notes) {
    return 'Catatan: $notes';
  }

  @override
  String get orderDetailPayNow => 'Bayar Sekarang';

  @override
  String get orderDetailEditReview => 'Sunting Ulasan Anda';

  @override
  String get orderDetailLeaveReview => 'Tulis Ulasan';

  @override
  String get orderDetailNoComment => 'Tiada komen';

  @override
  String get orderDetailContactWhatsapp => 'Hubungi Pekebun melalui WhatsApp';

  @override
  String get orderDetailNoWhatsapp => 'Pekebun belum menambah nombor WhatsApp.';

  @override
  String get orderTimelinePlaced => 'Pesanan Dibuat';

  @override
  String get orderTimelineCancelled => 'Dibatalkan';

  @override
  String get orderTimelineConfirmed => 'Disahkan oleh Pekebun';

  @override
  String get orderTimelinePaid => 'Bayaran Diterima';

  @override
  String get orderTimelineHarvested => 'Dituai';

  @override
  String get orderTimelineDelivered => 'Dihantar';

  @override
  String get orderTimelineTitle => 'Kemajuan Pesanan';

  @override
  String get reviewErrorNoRating => 'Sila pilih penilaian bintang.';

  @override
  String get reviewErrorSubmit => 'Gagal menghantar ulasan. Sila cuba lagi.';

  @override
  String get reviewPrompt => 'Bagaimana pengalaman anda dengan ladang ini?';

  @override
  String get reviewCommentHint => 'Kongsi pengalaman anda (pilihan)';

  @override
  String get reviewUpdate => 'Kemas Kini Ulasan';

  @override
  String get reviewSubmit => 'Hantar Ulasan';

  @override
  String get orderErrorQuantity => 'Sila masukkan kuantiti yang sah.';

  @override
  String get orderErrorNoPrice => 'Ladang ini belum menetapkan harga.';

  @override
  String get orderErrorPlace => 'Gagal membuat pesanan. Sila cuba lagi.';

  @override
  String get orderTitle => 'Buat Pesanan';

  @override
  String orderFruitsAvailable(int count, String farmer) {
    return '$count buah tersedia · $farmer';
  }

  @override
  String get orderDetails => 'Butiran Pesanan';

  @override
  String get orderQuantityLabel => 'Kuantiti (kg)';

  @override
  String get orderPlatformFee => 'termasuk yuran platform 2%';

  @override
  String get orderPriceNotSet => 'Belum ditetapkan';

  @override
  String orderTargetHarvest(String date) {
    return 'Sasaran tuai: $date';
  }

  @override
  String get orderTargetHarvestOptional => 'Tarikh sasaran tuai (pilihan)';

  @override
  String get orderNotesLabel => 'Catatan kepada pekebun (pilihan)';

  @override
  String get orderTotalAmount => 'Jumlah Bayaran';

  @override
  String get orderConfirm => 'Sahkan Pesanan';

  @override
  String get orderFootnote =>
      'Pesanan dihantar kepada pekebun untuk pengesahan. Bayaran dibuat selepas pekebun mengesahkan.';

  @override
  String get profileSessionExpiredRelogin =>
      'Sesi tamat. Sila log keluar dan log masuk semula.';

  @override
  String profileErrorLoadStatus(String status) {
    return 'Gagal memuatkan profil (ralat $status).';
  }

  @override
  String profileErrorLoad(String detail) {
    return 'Gagal memuatkan profil: $detail';
  }

  @override
  String get profileSaved => 'Profil disimpan.';

  @override
  String profileErrorSaveStatus(String status) {
    return 'Gagal menyimpan (ralat $status).';
  }

  @override
  String profileErrorSaveStatusDetail(String status, String detail) {
    return 'Gagal menyimpan (ralat $status: $detail).';
  }

  @override
  String profileErrorSave(String detail) {
    return 'Gagal menyimpan: $detail';
  }

  @override
  String get profileTitle => 'Profil Saya';

  @override
  String get profileBuyerAccount => 'Akaun Pembeli';

  @override
  String get profilePersonalInfo => 'Maklumat Peribadi';

  @override
  String get profileDeliveryAddressLabel => 'Alamat penghantaran';

  @override
  String get profilePhoneLabel => 'Nombor telefon';

  @override
  String get profilePhoneHint => 'cth. 0123456789';

  @override
  String get profileWhatsappHint => 'cth. 60123456789';

  @override
  String get profileWhatsappLabel => 'Nombor WhatsApp';

  @override
  String get profileWhatsappHelper =>
      'Pekebun boleh menghubungi anda di sini mengenai pesanan anda';

  @override
  String get profileSaveButton => 'Simpan Profil';

  @override
  String get profileAppVersion => 'Versi Aplikasi';

  @override
  String get profilePoweredBy => 'Dikuasakan oleh';

  @override
  String get profileSignOut => 'Log keluar';

  @override
  String get pulpErrorNoCamera => 'Tiada kamera ditemui pada peranti ini.';

  @override
  String get pulpErrorCameraUnavailable =>
      'Kamera tidak tersedia. Semak kebenaran aplikasi.';

  @override
  String get pulpErrorCapture => 'Gagal menangkap gambar. Cuba lagi.';

  @override
  String get pulpCameraTitle => 'Kematangan Isi';

  @override
  String get pulpSwipeBack => 'Leret ke kanan untuk kembali';

  @override
  String get pulpCameraInstruction =>
      'Belah mangga kepada dua · Letak bahagian rata ke atas\nLetak isi di dalam kotak · Guna cahaya siang';

  @override
  String get pulpStage1 => 'Baru dituai';

  @override
  String get pulpStage2 => 'Mula masak';

  @override
  String get pulpStage3 => 'Sedang masak';

  @override
  String get pulpStage4 => 'Sedia dimakan';

  @override
  String get pulpStage5 => 'Terlalu masak';

  @override
  String get pulpErrorAnalysis => 'Analisis gagal. Cuba lagi.';

  @override
  String get pulpResultTitle => 'Analisis Isi';

  @override
  String get pulpAnalysing => 'Menganalisis warna isi…';

  @override
  String get pulpRipenessStage => 'Peringkat Kematangan';

  @override
  String pulpStageOf(int stage, String label) {
    return 'Peringkat $stage daripada 5 — $label';
  }

  @override
  String get pulpBrixLabel => 'Brix (Kemanisan)';

  @override
  String get pulpFirmnessLabel => 'Kepejalan';

  @override
  String get pulpReadyToEat => 'Sedia dimakan';

  @override
  String get pulpNotReady => 'Belum sedia';

  @override
  String pulpDaysToReady(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Kira-kira $days hari lagi pada suhu bilik',
    );
    return '$_temp0';
  }

  @override
  String get pulpColourComparison => 'Perbandingan Warna Isi';

  @override
  String get pulpDetected => 'Dikesan';

  @override
  String pulpStageReference(int stage) {
    return 'Rujukan peringkat $stage';
  }

  @override
  String pulpConfidence(String level) {
    return 'Keyakinan: $level';
  }

  @override
  String get pulpConfidenceHigh => 'tinggi';

  @override
  String get pulpConfidenceMedium => 'sederhana';

  @override
  String get pulpConfidenceLow => 'rendah';

  @override
  String get pulpCitation =>
      'Berdasarkan Nasir et al. (2021) — panduan kematangan Harumanis (UniMAP)';

  @override
  String get pulpScanAnother => 'Imbas Mangga Lain';

  @override
  String get reminderChannelName => 'Peringatan Kematangan';

  @override
  String get reminderChannelDescription =>
      'Memaklumkan anda apabila Harumanis anda sedia dimakan';

  @override
  String get reminderNotificationTitle =>
      '🥭 Harumanis anda sudah sedia dimakan!';

  @override
  String reminderNotificationBody(String farm) {
    return 'Harumanis yang anda beli dari $farm kini paling manis. Selamat menikmati!';
  }

  @override
  String get reminderAllowNotifications =>
      'Sila benarkan pemberitahuan untuk menetapkan peringatan.';

  @override
  String get reminderPickerHelp => 'Bilakah anda membeli buah ini?';

  @override
  String reminderSet(String date) {
    return 'Peringatan ditetapkan! Kami akan memaklumkan anda pada $date jam 9 pagi.';
  }

  @override
  String reminderErrorSet(String detail) {
    return 'Gagal menetapkan peringatan: $detail';
  }

  @override
  String get reminderSheetTitle => 'Tetapkan Peringatan Kematangan';

  @override
  String get reminderPurchaseQuestion => 'Bilakah anda membeli buah ini?';

  @override
  String get reminderChange => 'Tukar';

  @override
  String reminderExplanation(String date, int days) {
    return 'Kami akan mengingatkan anda pada $date jam 9 pagi — $days hari selepas pembelian, ketika Harumanis paling manis.';
  }

  @override
  String get reminderSetting => 'Menetapkan...';

  @override
  String get reminderSetButton => 'Tetapkan Peringatan';
}
