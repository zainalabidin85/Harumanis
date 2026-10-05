// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageRowTitle => 'Language';

  @override
  String get languageMalay => 'Bahasa Malaysia';

  @override
  String get languageEnglish => 'English';

  @override
  String get stageEarly => 'Early';

  @override
  String get stageBagging => 'Bagging';

  @override
  String get stagePreHarvest => 'Pre-harvest';

  @override
  String get stageUnknown => 'Unknown';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String updateRequiredBody(String version) {
    return 'Ai-Harumanis v$version is required. Download the latest APK to continue.';
  }

  @override
  String updateAvailableBody(String version) {
    return 'Ai-Harumanis v$version is available with new features and fixes.';
  }

  @override
  String get updateLater => 'Later';

  @override
  String get updateExit => 'Exit';

  @override
  String get updateOk => 'OK';

  @override
  String get updateDownload => 'Download';

  @override
  String get loginErrorBuyerAccount =>
      'This account is registered as a buyer. Please use the Beli Harumanis app.';

  @override
  String get loginErrorInvalidCredentials => 'Invalid email or password';

  @override
  String get loginErrorNoConnection =>
      'Cannot reach server. Check your connection.';

  @override
  String loginErrorFailed(String detail) {
    return 'Login failed ($detail)';
  }

  @override
  String commonErrorWithDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get loginTagline => 'Harumanis Farm Manager';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to your farm account';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get loginForgotPasswordLink => 'Forgot Password?';

  @override
  String get loginSignInButton => 'Sign In';

  @override
  String get loginNoAccountPrompt => 'Don\'t have an account? ';

  @override
  String get loginRegister => 'Register';

  @override
  String get loginErrorEnterEmail => 'Please enter your email.';

  @override
  String get loginErrorSendCodeFailed => 'Failed to send code. Try again.';

  @override
  String get loginErrorFillAllFields => 'Please fill in all fields.';

  @override
  String get loginPasswordResetDone =>
      'Password reset! Please log in with your new password.';

  @override
  String get loginErrorInvalidCode => 'Invalid or expired code.';

  @override
  String get loginEnterResetCodeTitle => 'Enter Reset Code';

  @override
  String get loginForgotPasswordTitle => 'Forgot Password';

  @override
  String get loginForgotPasswordBody =>
      'Enter your email and we will send you a 6-digit reset code.';

  @override
  String loginCodeSentTo(String email) {
    return 'A 6-digit code was sent to $email.';
  }

  @override
  String get loginSixDigitCodeLabel => '6-digit Code';

  @override
  String get loginNewPasswordLabel => 'New Password';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get loginResetPasswordButton => 'Reset Password';

  @override
  String get loginSendCodeButton => 'Send Code';

  @override
  String get loginCreateAccountTitle => 'Create Account';

  @override
  String get commonFullName => 'Full Name';

  @override
  String get loginPhoneOptionalLabel => 'Phone (optional)';

  @override
  String get loginErrorRegisterRequired =>
      'Name, email and password are required.';

  @override
  String get loginAccountCreated => 'Account created. Please log in.';

  @override
  String loginErrorRegisterFailed(String detail) {
    return 'Registration failed: $detail';
  }

  @override
  String get homeProfileTooltip => 'Profile';

  @override
  String get homeSignOutTooltip => 'Sign out';

  @override
  String get homePrompt => 'What would you like to do today?';

  @override
  String get homeMyTreesTitle => 'My Trees';

  @override
  String get homeMyTreesSubtitle => 'Scan fruit and manage trees';

  @override
  String get homeDashboardTitle => 'Farm Dashboard';

  @override
  String get homeDashboardSubtitle => 'Satellite map of your farm';

  @override
  String get homeSellSubtitle => 'Farm photos, orders & QR code';

  @override
  String homeNewBadge(int count) {
    return '$count new';
  }

  @override
  String get homeAnnouncementsTitle => 'Announcements';

  @override
  String get homeAnnouncementsSubtitle => 'Courses, workshops & DOA notices';

  @override
  String get homeDoaMonitorTitle => 'DOA Monitor';

  @override
  String get homeDoaMonitorSubtitle => 'Cross-farm yield by growth stage';

  @override
  String get homeFarmPhotosTitle => 'Farm Photos';

  @override
  String get homeFarmPhotosSubtitle => 'Add photos to attract buyers';

  @override
  String get homeIncomingOrdersTitle => 'Incoming Orders';

  @override
  String get homeIncomingOrdersSubtitle => 'Manage buyer orders from Harumanis';

  @override
  String get homePulpTitle => 'Check Pulp Ripeness';

  @override
  String get homePulpSubtitle => 'Predict Brix & sweetness from pulp colour';

  @override
  String get homeReminderQrTitle => 'Reminder QR';

  @override
  String get homeReminderQrSubtitle =>
      'Let street buyers set a ripeness reminder';

  @override
  String get commonMyFarm => 'My Farm';

  @override
  String get profileSessionExpiredRelogin =>
      'Session expired. Please log out and log in again.';

  @override
  String profileErrorLoadStatus(String status) {
    return 'Failed to load profile (error $status).';
  }

  @override
  String profileErrorLoad(String detail) {
    return 'Failed to load profile: $detail';
  }

  @override
  String get profileSessionExpired => 'Session expired. Please log in again.';

  @override
  String profileErrorUpdateStatus(String status) {
    return 'Failed to update (error $status).';
  }

  @override
  String profileErrorSavePriceStatus(String status) {
    return 'Failed to save price (error $status).';
  }

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String profileErrorSaveStatus(String status) {
    return 'Failed to save (error $status).';
  }

  @override
  String profileErrorSave(String detail) {
    return 'Failed to save: $detail';
  }

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileFarmerAccount => 'Farmer Account';

  @override
  String get profilePersonalInfo => 'Personal Info';

  @override
  String get profilePhoneLabel => 'Phone number';

  @override
  String get profilePhoneHint => 'e.g. 0123456789';

  @override
  String get profileWhatsappLabel => 'WhatsApp number';

  @override
  String get profileWhatsappHint => 'e.g. 60123456789';

  @override
  String get profileVisibleToBuyers => 'Visible to buyers';

  @override
  String get profileFarmInfo => 'Farm Info';

  @override
  String get profileNotSetUp => 'Not set up';

  @override
  String get profileFarmNameLabel => 'Farm Name';

  @override
  String get profileLocationLabel => 'Location';

  @override
  String get profileLocationHint => 'e.g. Perlis, Malaysia';

  @override
  String get profileListOnBeli => 'List on Beli Harumanis';

  @override
  String get profileListedPublic => 'Buyers can see and order your fruit';

  @override
  String get profileListedPrivate => 'Your farm is private';

  @override
  String get profilePricePerKgLabel => 'Price per kg (RM)';

  @override
  String get commonSave => 'Save';

  @override
  String get profileSetPriceHint =>
      'Set your price so buyers can place orders.';

  @override
  String get profileBankDetails => 'Bank Details';

  @override
  String get profileBankDetailsSubtitle =>
      'Used for receiving payouts from Harumanis sales.';

  @override
  String get profileBankNameLabel => 'Bank Name';

  @override
  String get profileBankNameHint => 'e.g. Maybank';

  @override
  String get profileAccountNumberLabel => 'Account Number';

  @override
  String get profileAccountNumberHint => 'e.g. 1234567890';

  @override
  String get profileAccountHolderLabel => 'Account Holder Name';

  @override
  String get profileAccountHolderHint => 'Name as on bank card';

  @override
  String get profileSaveButton => 'Save Profile';
}
