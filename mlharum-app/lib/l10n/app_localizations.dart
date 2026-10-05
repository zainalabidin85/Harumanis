import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms')
  ];

  /// No description provided for @languageRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageRowTitle;

  /// No description provided for @languageMalay.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Malaysia'**
  String get languageMalay;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @stageEarly.
  ///
  /// In en, this message translates to:
  /// **'Early'**
  String get stageEarly;

  /// No description provided for @stageBagging.
  ///
  /// In en, this message translates to:
  /// **'Bagging'**
  String get stageBagging;

  /// No description provided for @stagePreHarvest.
  ///
  /// In en, this message translates to:
  /// **'Pre-harvest'**
  String get stagePreHarvest;

  /// No description provided for @stageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get stageUnknown;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailableTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Ai-Harumanis v{version} is required. Download the latest APK to continue.'**
  String updateRequiredBody(String version);

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Ai-Harumanis v{version} is available with new features and fixes.'**
  String updateAvailableBody(String version);

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get updateExit;

  /// No description provided for @updateOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get updateOk;

  /// No description provided for @updateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownload;

  /// No description provided for @loginErrorBuyerAccount.
  ///
  /// In en, this message translates to:
  /// **'This account is registered as a buyer. Please use the Beli Harumanis app.'**
  String get loginErrorBuyerAccount;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach server. Check your connection.'**
  String get loginErrorNoConnection;

  /// No description provided for @loginErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed ({detail})'**
  String loginErrorFailed(String detail);

  /// No description provided for @commonErrorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String commonErrorWithDetail(String detail);

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Harumanis Farm Manager'**
  String get loginTagline;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your farm account'**
  String get loginSubtitle;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @loginForgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPasswordLink;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignInButton;

  /// No description provided for @loginNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccountPrompt;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginRegister;

  /// No description provided for @loginErrorEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get loginErrorEnterEmail;

  /// No description provided for @loginErrorSendCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code. Try again.'**
  String get loginErrorSendCodeFailed;

  /// No description provided for @loginErrorFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get loginErrorFillAllFields;

  /// No description provided for @loginPasswordResetDone.
  ///
  /// In en, this message translates to:
  /// **'Password reset! Please log in with your new password.'**
  String get loginPasswordResetDone;

  /// No description provided for @loginErrorInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code.'**
  String get loginErrorInvalidCode;

  /// No description provided for @loginEnterResetCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Reset Code'**
  String get loginEnterResetCodeTitle;

  /// No description provided for @loginForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get loginForgotPasswordTitle;

  /// No description provided for @loginForgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a 6-digit reset code.'**
  String get loginForgotPasswordBody;

  /// No description provided for @loginCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code was sent to {email}.'**
  String loginCodeSentTo(String email);

  /// No description provided for @loginSixDigitCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit Code'**
  String get loginSixDigitCodeLabel;

  /// No description provided for @loginNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get loginNewPasswordLabel;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @loginResetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get loginResetPasswordButton;

  /// No description provided for @loginSendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get loginSendCodeButton;

  /// No description provided for @loginCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginCreateAccountTitle;

  /// No description provided for @commonFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get commonFullName;

  /// No description provided for @loginPhoneOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get loginPhoneOptionalLabel;

  /// No description provided for @loginErrorRegisterRequired.
  ///
  /// In en, this message translates to:
  /// **'Name, email and password are required.'**
  String get loginErrorRegisterRequired;

  /// No description provided for @loginAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created. Please log in.'**
  String get loginAccountCreated;

  /// No description provided for @loginErrorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {detail}'**
  String loginErrorRegisterFailed(String detail);

  /// No description provided for @homeProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfileTooltip;

  /// No description provided for @homeSignOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeSignOutTooltip;

  /// No description provided for @homePrompt.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do today?'**
  String get homePrompt;

  /// No description provided for @homeMyTreesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Trees'**
  String get homeMyTreesTitle;

  /// No description provided for @homeMyTreesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan fruit and manage trees'**
  String get homeMyTreesSubtitle;

  /// No description provided for @homeDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Dashboard'**
  String get homeDashboardTitle;

  /// No description provided for @homeDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Satellite map of your farm'**
  String get homeDashboardSubtitle;

  /// No description provided for @homeSellSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Farm photos, orders & QR code'**
  String get homeSellSubtitle;

  /// No description provided for @homeNewBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String homeNewBadge(int count);

  /// No description provided for @homeAnnouncementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get homeAnnouncementsTitle;

  /// No description provided for @homeAnnouncementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Courses, workshops & DOA notices'**
  String get homeAnnouncementsSubtitle;

  /// No description provided for @homeDoaMonitorTitle.
  ///
  /// In en, this message translates to:
  /// **'DOA Monitor'**
  String get homeDoaMonitorTitle;

  /// No description provided for @homeDoaMonitorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cross-farm yield by growth stage'**
  String get homeDoaMonitorSubtitle;

  /// No description provided for @homeFarmPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Photos'**
  String get homeFarmPhotosTitle;

  /// No description provided for @homeFarmPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add photos to attract buyers'**
  String get homeFarmPhotosSubtitle;

  /// No description provided for @homeIncomingOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming Orders'**
  String get homeIncomingOrdersTitle;

  /// No description provided for @homeIncomingOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage buyer orders from Harumanis'**
  String get homeIncomingOrdersSubtitle;

  /// No description provided for @homePulpTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Pulp Ripeness'**
  String get homePulpTitle;

  /// No description provided for @homePulpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Predict Brix & sweetness from pulp colour'**
  String get homePulpSubtitle;

  /// No description provided for @homeReminderQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder QR'**
  String get homeReminderQrTitle;

  /// No description provided for @homeReminderQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let street buyers set a ripeness reminder'**
  String get homeReminderQrSubtitle;

  /// No description provided for @commonMyFarm.
  ///
  /// In en, this message translates to:
  /// **'My Farm'**
  String get commonMyFarm;

  /// No description provided for @profileSessionExpiredRelogin.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log out and log in again.'**
  String get profileSessionExpiredRelogin;

  /// No description provided for @profileErrorLoadStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile (error {status}).'**
  String profileErrorLoadStatus(String status);

  /// No description provided for @profileErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {detail}'**
  String profileErrorLoad(String detail);

  /// No description provided for @profileSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get profileSessionExpired;

  /// No description provided for @profileErrorUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update (error {status}).'**
  String profileErrorUpdateStatus(String status);

  /// No description provided for @profileErrorSavePriceStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to save price (error {status}).'**
  String profileErrorSavePriceStatus(String status);

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @profileErrorSaveStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to save (error {status}).'**
  String profileErrorSaveStatus(String status);

  /// No description provided for @profileErrorSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {detail}'**
  String profileErrorSave(String detail);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileFarmerAccount.
  ///
  /// In en, this message translates to:
  /// **'Farmer Account'**
  String get profileFarmerAccount;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get profilePersonalInfo;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profilePhoneLabel;

  /// No description provided for @profilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0123456789'**
  String get profilePhoneHint;

  /// No description provided for @profileWhatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get profileWhatsappLabel;

  /// No description provided for @profileWhatsappHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 60123456789'**
  String get profileWhatsappHint;

  /// No description provided for @profileVisibleToBuyers.
  ///
  /// In en, this message translates to:
  /// **'Visible to buyers'**
  String get profileVisibleToBuyers;

  /// No description provided for @profileFarmInfo.
  ///
  /// In en, this message translates to:
  /// **'Farm Info'**
  String get profileFarmInfo;

  /// No description provided for @profileNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get profileNotSetUp;

  /// No description provided for @profileFarmNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get profileFarmNameLabel;

  /// No description provided for @profileLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get profileLocationLabel;

  /// No description provided for @profileLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Perlis, Malaysia'**
  String get profileLocationHint;

  /// No description provided for @profileListOnBeli.
  ///
  /// In en, this message translates to:
  /// **'List on Beli Harumanis'**
  String get profileListOnBeli;

  /// No description provided for @profileListedPublic.
  ///
  /// In en, this message translates to:
  /// **'Buyers can see and order your fruit'**
  String get profileListedPublic;

  /// No description provided for @profileListedPrivate.
  ///
  /// In en, this message translates to:
  /// **'Your farm is private'**
  String get profileListedPrivate;

  /// No description provided for @profilePricePerKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per kg (RM)'**
  String get profilePricePerKgLabel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @profileSetPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Set your price so buyers can place orders.'**
  String get profileSetPriceHint;

  /// No description provided for @profileBankDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Details'**
  String get profileBankDetails;

  /// No description provided for @profileBankDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used for receiving payouts from Harumanis sales.'**
  String get profileBankDetailsSubtitle;

  /// No description provided for @profileBankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get profileBankNameLabel;

  /// No description provided for @profileBankNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Maybank'**
  String get profileBankNameHint;

  /// No description provided for @profileAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get profileAccountNumberLabel;

  /// No description provided for @profileAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1234567890'**
  String get profileAccountNumberHint;

  /// No description provided for @profileAccountHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get profileAccountHolderLabel;

  /// No description provided for @profileAccountHolderHint.
  ///
  /// In en, this message translates to:
  /// **'Name as on bank card'**
  String get profileAccountHolderHint;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileSaveButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
