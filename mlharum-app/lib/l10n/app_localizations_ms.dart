// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get languageRowTitle => 'Bahasa';

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
  String get updateRequiredTitle => 'Kemas Kini Diperlukan';

  @override
  String get updateAvailableTitle => 'Kemas Kini Tersedia';

  @override
  String updateRequiredBody(String version) {
    return 'Ai-Harumanis v$version diperlukan. Muat turun APK terkini untuk meneruskan.';
  }

  @override
  String updateAvailableBody(String version) {
    return 'Ai-Harumanis v$version kini tersedia dengan ciri baharu dan pembaikan.';
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
  String get loginErrorBuyerAccount =>
      'Akaun ini didaftarkan sebagai pembeli. Sila gunakan aplikasi Beli Harumanis.';

  @override
  String get loginErrorInvalidCredentials => 'E-mel atau kata laluan tidak sah';

  @override
  String get loginErrorNoConnection =>
      'Tidak dapat menghubungi pelayan. Semak sambungan anda.';

  @override
  String loginErrorFailed(String detail) {
    return 'Log masuk gagal ($detail)';
  }

  @override
  String commonErrorWithDetail(String detail) {
    return 'Ralat: $detail';
  }

  @override
  String get loginTagline => 'Pengurus Ladang Harumanis';

  @override
  String get loginWelcomeBack => 'Selamat kembali';

  @override
  String get loginSubtitle => 'Log masuk ke akaun ladang anda';

  @override
  String get commonEmail => 'E-mel';

  @override
  String get commonPassword => 'Kata laluan';

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
  String get loginErrorSendCodeFailed => 'Gagal menghantar kod. Cuba lagi.';

  @override
  String get loginErrorFillAllFields => 'Sila isi semua ruangan.';

  @override
  String get loginPasswordResetDone =>
      'Kata laluan ditetapkan semula! Sila log masuk dengan kata laluan baharu.';

  @override
  String get loginErrorInvalidCode => 'Kod tidak sah atau telah luput.';

  @override
  String get loginEnterResetCodeTitle => 'Masukkan Kod Tetapan Semula';

  @override
  String get loginForgotPasswordTitle => 'Lupa Kata Laluan';

  @override
  String get loginForgotPasswordBody =>
      'Masukkan e-mel anda dan kami akan menghantar kod tetapan semula 6 digit.';

  @override
  String loginCodeSentTo(String email) {
    return 'Kod 6 digit telah dihantar ke $email.';
  }

  @override
  String get loginSixDigitCodeLabel => 'Kod 6 digit';

  @override
  String get loginNewPasswordLabel => 'Kata laluan baharu';

  @override
  String get commonCancel => 'Batal';

  @override
  String get loginResetPasswordButton => 'Tetapkan Semula';

  @override
  String get loginSendCodeButton => 'Hantar Kod';

  @override
  String get loginCreateAccountTitle => 'Daftar Akaun';

  @override
  String get commonFullName => 'Nama penuh';

  @override
  String get loginPhoneOptionalLabel => 'Telefon (pilihan)';

  @override
  String get loginErrorRegisterRequired =>
      'Nama, e-mel dan kata laluan diperlukan.';

  @override
  String get loginAccountCreated =>
      'Akaun berjaya didaftarkan. Sila log masuk.';

  @override
  String loginErrorRegisterFailed(String detail) {
    return 'Pendaftaran gagal: $detail';
  }

  @override
  String get homeProfileTooltip => 'Profil';

  @override
  String get homeSignOutTooltip => 'Log keluar';

  @override
  String get homePrompt => 'Apa yang anda ingin lakukan hari ini?';

  @override
  String get homeMyTreesTitle => 'Pokok Saya';

  @override
  String get homeMyTreesSubtitle => 'Imbas buah dan urus pokok';

  @override
  String get homeDashboardTitle => 'Papan Pemuka Ladang';

  @override
  String get homeDashboardSubtitle => 'Peta satelit ladang anda';

  @override
  String get homeSellSubtitle => 'Gambar ladang, pesanan & kod QR';

  @override
  String homeNewBadge(int count) {
    return '$count baharu';
  }

  @override
  String get homeAnnouncementsTitle => 'Pengumuman';

  @override
  String get homeAnnouncementsSubtitle => 'Kursus, bengkel & notis DOA';

  @override
  String get homeDoaMonitorTitle => 'Pemantauan DOA';

  @override
  String get homeDoaMonitorSubtitle => 'Hasil semua ladang mengikut peringkat';

  @override
  String get homeFarmPhotosTitle => 'Gambar Ladang';

  @override
  String get homeFarmPhotosSubtitle => 'Tambah gambar untuk menarik pembeli';

  @override
  String get homeIncomingOrdersTitle => 'Pesanan Masuk';

  @override
  String get homeIncomingOrdersSubtitle =>
      'Urus pesanan pembeli daripada Harumanis';

  @override
  String get homePulpTitle => 'Semak Kematangan Isi';

  @override
  String get homePulpSubtitle => 'Ramal Brix & kemanisan daripada warna isi';

  @override
  String get homeReminderQrTitle => 'QR Peringatan';

  @override
  String get homeReminderQrSubtitle =>
      'Pembeli boleh tetapkan peringatan masak';

  @override
  String get commonMyFarm => 'Ladang Saya';

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
  String get profileSessionExpired => 'Sesi tamat. Sila log masuk semula.';

  @override
  String profileErrorUpdateStatus(String status) {
    return 'Gagal mengemas kini (ralat $status).';
  }

  @override
  String profileErrorSavePriceStatus(String status) {
    return 'Gagal menyimpan harga (ralat $status).';
  }

  @override
  String get profileSaved => 'Profil disimpan.';

  @override
  String profileErrorSaveStatus(String status) {
    return 'Gagal menyimpan (ralat $status).';
  }

  @override
  String profileErrorSave(String detail) {
    return 'Gagal menyimpan: $detail';
  }

  @override
  String get profileTitle => 'Profil Saya';

  @override
  String get profileFarmerAccount => 'Akaun Pekebun';

  @override
  String get profilePersonalInfo => 'Maklumat Peribadi';

  @override
  String get profilePhoneLabel => 'Nombor telefon';

  @override
  String get profilePhoneHint => 'cth. 0123456789';

  @override
  String get profileWhatsappLabel => 'Nombor WhatsApp';

  @override
  String get profileWhatsappHint => 'cth. 60123456789';

  @override
  String get profileVisibleToBuyers => 'Boleh dilihat oleh pembeli';

  @override
  String get profileFarmInfo => 'Maklumat Ladang';

  @override
  String get profileNotSetUp => 'Belum ditetapkan';

  @override
  String get profileFarmNameLabel => 'Nama ladang';

  @override
  String get profileLocationLabel => 'Lokasi';

  @override
  String get profileLocationHint => 'cth. Perlis, Malaysia';

  @override
  String get profileListOnBeli => 'Senaraikan di Beli Harumanis';

  @override
  String get profileListedPublic =>
      'Pembeli boleh melihat dan memesan buah anda';

  @override
  String get profileListedPrivate => 'Ladang anda tidak dipaparkan';

  @override
  String get profilePricePerKgLabel => 'Harga sekilogram (RM)';

  @override
  String get commonSave => 'Simpan';

  @override
  String get profileSetPriceHint =>
      'Tetapkan harga supaya pembeli boleh membuat pesanan.';

  @override
  String get profileBankDetails => 'Maklumat Bank';

  @override
  String get profileBankDetailsSubtitle =>
      'Digunakan untuk menerima bayaran hasil jualan Harumanis.';

  @override
  String get profileBankNameLabel => 'Nama bank';

  @override
  String get profileBankNameHint => 'cth. Maybank';

  @override
  String get profileAccountNumberLabel => 'Nombor akaun';

  @override
  String get profileAccountNumberHint => 'cth. 1234567890';

  @override
  String get profileAccountHolderLabel => 'Nama pemegang akaun';

  @override
  String get profileAccountHolderHint => 'Nama seperti pada kad bank';

  @override
  String get profileSaveButton => 'Simpan Profil';

  @override
  String get treeListErrorNoFarm =>
      'Tiada ladang ditemui. Sila tetapkan ladang anda di Profil dahulu.';

  @override
  String treeListErrorLoad(String detail) {
    return 'Gagal memuatkan pokok: $detail';
  }

  @override
  String treeListGettingLocationAccuracy(String meters) {
    return 'Mendapatkan lokasi… ±${meters}m';
  }

  @override
  String get treeListGettingLocation => 'Mendapatkan lokasi…';

  @override
  String get treeListLocationUnavailable => 'Lokasi tidak tersedia';

  @override
  String get commonRetry => 'Cuba lagi';

  @override
  String get treeListAddTree => 'Tambah Pokok';

  @override
  String get treeListTreeNumberLabel => 'Nombor pokok *';

  @override
  String get treeListNotesLabel => 'Catatan (pilihan)';

  @override
  String get treeListNotesHint => 'cth. Dekat jalan utama';

  @override
  String treeListAddedWithGps(String number) {
    return 'Pokok $number ditambah dengan GPS.';
  }

  @override
  String treeListAddedNoGps(String number) {
    return 'Pokok $number ditambah (tanpa GPS).';
  }

  @override
  String treeListErrorAdd(String detail) {
    return 'Gagal menambah pokok: $detail';
  }

  @override
  String get commonAdd => 'Tambah';

  @override
  String get treeListEmptyTitle => 'Belum ada pokok didaftarkan';

  @override
  String get treeListEmptyBody => 'Tambah pokok mangga anda untuk bermula.';

  @override
  String get treeListAddFirstTree => 'Tambah Pokok Pertama';

  @override
  String treeDetailErrorLoadStatus(String status) {
    return 'Gagal memuatkan buah (ralat $status).';
  }

  @override
  String treeDetailDeleteTitle(String number) {
    return 'Padam Pokok $number?';
  }

  @override
  String get treeDetailDeleteBody =>
      'Pokok ini dan semua sejarah imbasannya akan dipadam selama-lamanya. Tindakan ini tidak boleh dibatalkan.';

  @override
  String get commonDelete => 'Padam';

  @override
  String get treeDetailErrorDelete => 'Gagal memadam pokok.';

  @override
  String treeDetailTitle(String number) {
    return 'Pokok $number';
  }

  @override
  String get treeDetailDeleteTooltip => 'Padam pokok';

  @override
  String get treeDetailAddFruit => '+ Tambah Buah';

  @override
  String treeDetailActiveFruits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count buah aktif',
    );
    return '$_temp0';
  }

  @override
  String treeDetailEarliestHarvest(String date) {
    return 'Tuaian terawal: $date';
  }

  @override
  String treeDetailStageCount(int stage, int count) {
    return 'P$stage: $count';
  }

  @override
  String get treeDetailReadyToHarvest => 'Sedia untuk dituai';

  @override
  String treeDetailDaysToHarvest(int days) {
    return '$days hari sebelum tuai';
  }

  @override
  String treeDetailFruitSummary(String size, String stage, int days) {
    return '$size cm · $stage · $days hari sebelum tuai';
  }

  @override
  String commonFailedStatus(String status) {
    return 'Gagal (ralat $status).';
  }

  @override
  String get treeDetailMarkHarvested => 'Tanda Sudah Dituai';

  @override
  String get treeDetailMarkAborted => 'Tanda Gugur / Rosak';

  @override
  String get treeDetailReasonLabel => 'Sebab (pilihan)';

  @override
  String get treeDetailReasonHint =>
      'cth. Gugur dari pokok, serangan perosak, penjarangan';

  @override
  String get treeDetailConfirmAbort => 'Sahkan Gugur';

  @override
  String get commonClose => 'Tutup';

  @override
  String get treeDetailEmptyTitle => 'Tiada buah aktif';

  @override
  String get treeDetailEmptyBody =>
      'Imbas pokok ini untuk mengesan dan menjejak mangga.';

  @override
  String harvestBadgeLabel(String date, int days) {
    return '$date · $days h';
  }

  @override
  String get cameraErrorNoHand =>
      'Tangan tidak dikesan. Buka tapak tangan anda di sebelah buah.';

  @override
  String get cameraErrorNoMango =>
      'Mangga tidak dikesan. Cuba lagi dengan pencahayaan yang lebih baik.';

  @override
  String get cameraErrorTimeout =>
      'Sambungan tamat masa. Semak internet anda dan cuba lagi.';

  @override
  String get cameraErrorNoConnection =>
      'Tidak dapat menghubungi pelayan. Semak sambungan internet anda.';

  @override
  String get cameraInstruction =>
      'Hala ke SATU mangga. Buka tapak tangan di sebelahnya, kemudian tekan butang tangkap.';

  @override
  String get resultReadyForBagging => 'Sedia untuk dibalut';

  @override
  String resultAttachLabel(String label) {
    return 'Lekatkan label $label pada buah ini';
  }

  @override
  String get commonDone => 'Selesai';

  @override
  String get resultFlushColorTitle => 'Tanda warna (pilihan)';

  @override
  String get resultFlushColorBody =>
      'Padankan dengan warna yang anda ikat pada kertas pembalut';

  @override
  String get resultFruitRecorded => 'Buah Direkodkan';

  @override
  String get resultStillDeveloping => 'Masih Membesar';

  @override
  String get commonTryAgain => 'Cuba Lagi';

  @override
  String get resultBackToTree => 'Kembali ke Pokok';

  @override
  String get dashboardErrorNoFarm => 'Tiada ladang ditemui.';

  @override
  String get dashboardErrorLoad => 'Gagal memuatkan papan pemuka.';

  @override
  String dashboardSeason(String year) {
    return 'Musim $year';
  }

  @override
  String get dashboardStatTrees => 'Pokok';

  @override
  String get dashboardStatActive => 'Aktif';

  @override
  String get dashboardStatHarvested => 'Dituai';

  @override
  String get dashboardStatAborted => 'Gugur';

  @override
  String get treeMarkerNoFruit => 'Tiada buah';

  @override
  String treeMarkerSnippet(int count, String harvest) {
    return '$count buah · $harvest';
  }

  @override
  String get pulpErrorNoCamera => 'Tiada kamera ditemui pada peranti ini.';

  @override
  String get pulpErrorCapture => 'Gagal menangkap gambar. Cuba lagi.';

  @override
  String get pulpCameraTitle => 'Kematangan Isi';

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
  String announcementsErrorLoad(String detail) {
    return 'Gagal memuatkan pengumuman: $detail';
  }

  @override
  String get announcementsFilterAll => 'Semua';

  @override
  String get announcementsFilterUpcoming => 'Akan datang';

  @override
  String get announcementsEmpty => 'Belum ada pengumuman.';

  @override
  String get announcementsPost => 'Hantar Pengumuman';

  @override
  String get announcementsPostSubtitle => 'Kongsi berita, bengkel atau notis';

  @override
  String get announcementDetailDeleteTitle => 'Padam pengumuman?';

  @override
  String get commonCantBeUndone => 'Tindakan ini tidak boleh dibatalkan.';

  @override
  String get announcementDetailErrorDelete => 'Gagal memadam. Sila cuba lagi.';

  @override
  String get commonEdit => 'Sunting';

  @override
  String announcementDetailPosted(String date) {
    return 'Dihantar $date · DOA Perlis';
  }

  @override
  String get announcementEditorErrorRequired =>
      'Tajuk dan keterangan diperlukan.';

  @override
  String get announcementEditorErrorSave =>
      'Gagal menyimpan perubahan. Sila cuba lagi.';

  @override
  String get announcementEditorErrorPost =>
      'Gagal menghantar pengumuman. Sila cuba lagi.';

  @override
  String get announcementEditorEditTitle => 'Sunting Pengumuman';

  @override
  String get announcementEditorAddBanner => 'Tambah gambar sepanduk (pilihan)';

  @override
  String get announcementEditorBannerLocked =>
      'Gambar sepanduk tidak boleh ditukar di sini — padam dan hantar semula untuk menukarnya.';

  @override
  String get announcementEditorTitleLabel => 'Tajuk';

  @override
  String get announcementEditorTitleHint =>
      'cth. Bengkel Cantuman Harumanis Percuma';

  @override
  String get announcementEditorDescriptionLabel => 'Keterangan';

  @override
  String get announcementEditorDescriptionHint =>
      'Butiran yang perlu diketahui pekebun';

  @override
  String get announcementEditorLocationLabel => 'Lokasi (pilihan)';

  @override
  String get announcementEditorLocationHint => 'cth. Pejabat DOA Perlis';

  @override
  String get announcementEditorEventDateLabel => 'Tarikh acara (pilihan)';

  @override
  String get announcementEditorNoDate => 'Tiada tarikh khusus — notis umum';

  @override
  String get announcementEditorSaveChanges => 'Simpan Perubahan';

  @override
  String doaReportErrorLoad(String detail) {
    return 'Gagal memuatkan laporan: $detail';
  }

  @override
  String doaReportErrorVerify(String detail) {
    return 'Gagal mengemas kini pengesahan: $detail';
  }

  @override
  String doaReportSeasonAllFarms(String year) {
    return 'Musim $year · Semua Ladang';
  }

  @override
  String get doaReportYieldByStage => 'Hasil mengikut Peringkat';

  @override
  String doaReportByFarm(int count) {
    return 'Mengikut Ladang ($count)';
  }

  @override
  String get doaReportSearchHint => 'Cari ladang, pemilik atau lokasi';

  @override
  String get doaReportNoFarms => 'Belum ada ladang didaftarkan.';

  @override
  String doaReportNoMatch(String query) {
    return 'Tiada ladang sepadan dengan \"$query\".';
  }

  @override
  String get doaReportStatFarms => 'Ladang';

  @override
  String get doaReportStatActiveFruits => 'Buah Aktif';

  @override
  String get doaReportStatLostAborted => 'Hilang/Gugur';

  @override
  String get doaReportNoActiveFruits =>
      'Tiada buah aktif direkodkan musim ini.';

  @override
  String get doaReportVerified => 'Disahkan';

  @override
  String get doaReportNotVerified => 'Belum Disahkan';

  @override
  String get doaReportStatLost => 'Hilang';

  @override
  String doaReportStageCount(String stage, int count) {
    return '$stage: $count';
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
  String get ordersErrorNoFarm => 'Tiada ladang dipautkan ke akaun anda.';

  @override
  String get ordersErrorLoad => 'Gagal memuatkan pesanan.';

  @override
  String get ordersEmpty => 'Belum ada pesanan';

  @override
  String ordersEmptyFiltered(String status) {
    return 'Tiada pesanan $status';
  }

  @override
  String get ordersEmptyBody =>
      'Pesanan daripada pembeli akan dipaparkan di sini.';

  @override
  String get ordersPaid => 'Dibayar';

  @override
  String get ordersUnpaid => 'Belum dibayar';

  @override
  String ordersOrderedOn(String date) {
    return 'Dipesan $date';
  }

  @override
  String orderDetailStatusUpdated(String status) {
    return 'Pesanan $status.';
  }

  @override
  String orderDetailErrorUpdate(String detail) {
    return 'Gagal mengemas kini: $detail';
  }

  @override
  String get orderDetailConfirmOrder => 'Sahkan Pesanan';

  @override
  String get orderDetailMarkHarvested => 'Tanda Dituai';

  @override
  String get orderDetailMarkDelivered => 'Tanda Dihantar';

  @override
  String get orderDetailCancelOrder => 'Batal Pesanan';

  @override
  String get orderDetailConfirmMsgConfirmed =>
      'Sahkan pesanan ini? Pembeli akan dimaklumkan untuk membuat bayaran.';

  @override
  String get orderDetailConfirmMsgHarvested =>
      'Tanda pesanan ini sebagai dituai? Ini bermakna mangga sudah sedia.';

  @override
  String get orderDetailConfirmMsgDelivered =>
      'Tanda sebagai dihantar? Pesanan ini akan ditutup.';

  @override
  String get orderDetailConfirmMsgCancelled =>
      'Batalkan pesanan ini? Tindakan ini tidak boleh dibatalkan.';

  @override
  String orderDetailConfirmMsgOther(String status) {
    return 'Kemas kini status pesanan kepada $status?';
  }

  @override
  String orderDetailTitle(String id) {
    return 'Pesanan #$id';
  }

  @override
  String get orderDetailStatus => 'Status';

  @override
  String get orderDetailBuyer => 'Pembeli';

  @override
  String get orderDetailDeliveryAddress => 'Alamat Penghantaran';

  @override
  String get orderDetailNoAddress =>
      'Tiada alamat diberikan — hubungi pembeli melalui WhatsApp.';

  @override
  String get orderDetailQuantity => 'Kuantiti';

  @override
  String get orderDetailPricePerKg => 'Harga sekilogram';

  @override
  String get orderDetailTotal => 'Jumlah';

  @override
  String get orderDetailPayment => 'Bayaran';

  @override
  String get orderDetailPaidTick => 'Dibayar ✓';

  @override
  String get orderDetailAwaitingPayment => 'Menunggu bayaran';

  @override
  String get orderDetailPaidAt => 'Dibayar pada';

  @override
  String get orderDetailTargetDate => 'Tarikh sasaran';

  @override
  String get orderDetailOrderedOn => 'Dipesan pada';

  @override
  String orderDetailNotes(String notes) {
    return 'Catatan: $notes';
  }

  @override
  String get orderDetailMarkAsHarvested => 'Tanda Sudah Dituai';

  @override
  String get orderDetailMarkAsDelivered => 'Tanda Sudah Dihantar';

  @override
  String get orderDetailCompleted => 'Pesanan selesai.';

  @override
  String get orderDetailCancelled => 'Pesanan dibatalkan.';

  @override
  String get farmPhotosAddCaption => 'Tambah kapsyen';

  @override
  String get farmPhotosCaptionHint => 'cth. Musim Harumanis 2025 (pilihan)';

  @override
  String get farmPhotosUpload => 'Muat naik';

  @override
  String get farmPhotosErrorUpload => 'Muat naik gagal. Sila cuba lagi.';

  @override
  String get farmPhotosDeleteTitle => 'Padam gambar?';

  @override
  String get farmPhotosDeleteBody => 'Gambar ini akan dipadam selama-lamanya.';

  @override
  String get farmPhotosAddTooltip => 'Tambah gambar';

  @override
  String get farmPhotosNoFarmTitle => 'Ladang belum ditetapkan';

  @override
  String get farmPhotosNoFarmBody => 'Lengkapkan profil ladang anda dahulu.';

  @override
  String farmPhotosCount(int count) {
    return '$count/5 gambar';
  }

  @override
  String get farmPhotosTapToAdd => 'Tekan + untuk menambah gambar';

  @override
  String get farmPhotosEmptyTitle => 'Belum ada gambar';

  @override
  String get farmPhotosEmptyBody =>
      'Tambah sehingga 5 gambar untuk menarik pembeli';

  @override
  String get farmPhotosAddButton => 'Tambah Gambar';

  @override
  String get qrTitle => 'Kod QR Pembeli';

  @override
  String get qrSubtitle =>
      'Tunjukkan kepada pembeli semasa menjual Harumanis anda';

  @override
  String get qrScanWithCamera => 'Imbas dengan mana-mana kamera';

  @override
  String get qrDaysUntilReady => 'Hari sehingga sedia dimakan';

  @override
  String get qrDaysHint => 'Pembeli akan diingatkan selepas bilangan hari ini';

  @override
  String get qrDaysUnit => 'hari';

  @override
  String get qrHowItWorks => 'Cara ia berfungsi';

  @override
  String get qrStep1 => 'Pembeli mengimbas QR ini dengan kamera telefon';

  @override
  String get qrStep2 =>
      'Satu halaman dibuka — mereka tekan \"Open in Beli Harumanis\" atau muat turun aplikasi dahulu';

  @override
  String qrStep3(int days) {
    return 'Mereka tekan \"Remind Me\" → aplikasi memaklumkan mereka dalam $days hari apabila buah sedia dimakan';
  }

  @override
  String get qrStep4 =>
      'Mereka juga boleh membuat pesanan akan datang terus dari halaman ladang anda';

  @override
  String get qrTip =>
      'Petua: Ambil tangkapan skrin dan cetak untuk dipamerkan di gerai anda';

  @override
  String get treeListTreeNumberHint => 'cth. T01';
}
