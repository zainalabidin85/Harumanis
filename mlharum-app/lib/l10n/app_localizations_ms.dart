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
}
