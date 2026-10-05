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

  /// No description provided for @treeListErrorNoFarm.
  ///
  /// In en, this message translates to:
  /// **'No farm found. Please set up your farm in Profile first.'**
  String get treeListErrorNoFarm;

  /// No description provided for @treeListErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load trees: {detail}'**
  String treeListErrorLoad(String detail);

  /// No description provided for @treeListGettingLocationAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Getting location… ±{meters}m'**
  String treeListGettingLocationAccuracy(String meters);

  /// No description provided for @treeListGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location…'**
  String get treeListGettingLocation;

  /// No description provided for @treeListLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get treeListLocationUnavailable;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @treeListAddTree.
  ///
  /// In en, this message translates to:
  /// **'Add Tree'**
  String get treeListAddTree;

  /// No description provided for @treeListTreeNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Tree number *'**
  String get treeListTreeNumberLabel;

  /// No description provided for @treeListNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get treeListNotesLabel;

  /// No description provided for @treeListNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Near main road'**
  String get treeListNotesHint;

  /// No description provided for @treeListAddedWithGps.
  ///
  /// In en, this message translates to:
  /// **'Tree {number} added with GPS.'**
  String treeListAddedWithGps(String number);

  /// No description provided for @treeListAddedNoGps.
  ///
  /// In en, this message translates to:
  /// **'Tree {number} added (no GPS).'**
  String treeListAddedNoGps(String number);

  /// No description provided for @treeListErrorAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add tree: {detail}'**
  String treeListErrorAdd(String detail);

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @treeListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No trees registered yet'**
  String get treeListEmptyTitle;

  /// No description provided for @treeListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your mango trees to get started.'**
  String get treeListEmptyBody;

  /// No description provided for @treeListAddFirstTree.
  ///
  /// In en, this message translates to:
  /// **'Add First Tree'**
  String get treeListAddFirstTree;

  /// No description provided for @treeDetailErrorLoadStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to load fruits (error {status}).'**
  String treeDetailErrorLoadStatus(String status);

  /// No description provided for @treeDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Tree {number}?'**
  String treeDetailDeleteTitle(String number);

  /// No description provided for @treeDetailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this tree and all its scan history. This cannot be undone.'**
  String get treeDetailDeleteBody;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @treeDetailErrorDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete tree.'**
  String get treeDetailErrorDelete;

  /// No description provided for @treeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Tree {number}'**
  String treeDetailTitle(String number);

  /// No description provided for @treeDetailDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete tree'**
  String get treeDetailDeleteTooltip;

  /// No description provided for @treeDetailAddFruit.
  ///
  /// In en, this message translates to:
  /// **'+ Add Fruit'**
  String get treeDetailAddFruit;

  /// No description provided for @treeDetailActiveFruits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active fruit} other{{count} active fruits}}'**
  String treeDetailActiveFruits(int count);

  /// No description provided for @treeDetailEarliestHarvest.
  ///
  /// In en, this message translates to:
  /// **'Earliest harvest: {date}'**
  String treeDetailEarliestHarvest(String date);

  /// No description provided for @treeDetailStageCount.
  ///
  /// In en, this message translates to:
  /// **'S{stage}: {count}'**
  String treeDetailStageCount(int stage, int count);

  /// No description provided for @treeDetailReadyToHarvest.
  ///
  /// In en, this message translates to:
  /// **'Ready to harvest'**
  String get treeDetailReadyToHarvest;

  /// No description provided for @treeDetailDaysToHarvest.
  ///
  /// In en, this message translates to:
  /// **'{days} days to harvest'**
  String treeDetailDaysToHarvest(int days);

  /// No description provided for @treeDetailFruitSummary.
  ///
  /// In en, this message translates to:
  /// **'{size} cm · {stage} · {days} days to harvest'**
  String treeDetailFruitSummary(String size, String stage, int days);

  /// No description provided for @commonFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed (error {status}).'**
  String commonFailedStatus(String status);

  /// No description provided for @treeDetailMarkHarvested.
  ///
  /// In en, this message translates to:
  /// **'Mark as Harvested'**
  String get treeDetailMarkHarvested;

  /// No description provided for @treeDetailMarkAborted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Fallen / Aborted'**
  String get treeDetailMarkAborted;

  /// No description provided for @treeDetailReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get treeDetailReasonLabel;

  /// No description provided for @treeDetailReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Fell from tree, pest damage, thinned'**
  String get treeDetailReasonHint;

  /// No description provided for @treeDetailConfirmAbort.
  ///
  /// In en, this message translates to:
  /// **'Confirm Abort'**
  String get treeDetailConfirmAbort;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @treeDetailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active fruits'**
  String get treeDetailEmptyTitle;

  /// No description provided for @treeDetailEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan this tree to detect and track mangoes.'**
  String get treeDetailEmptyBody;

  /// No description provided for @harvestBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'{date} · {days} d'**
  String harvestBadgeLabel(String date, int days);

  /// No description provided for @cameraErrorNoHand.
  ///
  /// In en, this message translates to:
  /// **'No hand detected. Hold your open palm beside the fruit.'**
  String get cameraErrorNoHand;

  /// No description provided for @cameraErrorNoMango.
  ///
  /// In en, this message translates to:
  /// **'No mangoes detected. Try again with better lighting.'**
  String get cameraErrorNoMango;

  /// No description provided for @cameraErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check your internet and try again.'**
  String get cameraErrorTimeout;

  /// No description provided for @cameraErrorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach server. Check your internet connection.'**
  String get cameraErrorNoConnection;

  /// No description provided for @cameraInstruction.
  ///
  /// In en, this message translates to:
  /// **'Point at ONE mango. Hold your open palm beside it, then tap Capture.'**
  String get cameraInstruction;

  /// No description provided for @resultReadyForBagging.
  ///
  /// In en, this message translates to:
  /// **'Ready for bagging'**
  String get resultReadyForBagging;

  /// No description provided for @resultAttachLabel.
  ///
  /// In en, this message translates to:
  /// **'Attach label {label} to this fruit'**
  String resultAttachLabel(String label);

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @resultFlushColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag bagging color (optional)'**
  String get resultFlushColorTitle;

  /// No description provided for @resultFlushColorBody.
  ///
  /// In en, this message translates to:
  /// **'Match the color you tie on the bagging paper for this flush'**
  String get resultFlushColorBody;

  /// No description provided for @resultFruitRecorded.
  ///
  /// In en, this message translates to:
  /// **'Fruit Recorded'**
  String get resultFruitRecorded;

  /// No description provided for @resultStillDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Still Developing'**
  String get resultStillDeveloping;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @resultBackToTree.
  ///
  /// In en, this message translates to:
  /// **'Back to Tree'**
  String get resultBackToTree;

  /// No description provided for @dashboardErrorNoFarm.
  ///
  /// In en, this message translates to:
  /// **'No farm found.'**
  String get dashboardErrorNoFarm;

  /// No description provided for @dashboardErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard.'**
  String get dashboardErrorLoad;

  /// No description provided for @dashboardSeason.
  ///
  /// In en, this message translates to:
  /// **'Season {year}'**
  String dashboardSeason(String year);

  /// No description provided for @dashboardStatTrees.
  ///
  /// In en, this message translates to:
  /// **'Trees'**
  String get dashboardStatTrees;

  /// No description provided for @dashboardStatActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get dashboardStatActive;

  /// No description provided for @dashboardStatHarvested.
  ///
  /// In en, this message translates to:
  /// **'Harvested'**
  String get dashboardStatHarvested;

  /// No description provided for @dashboardStatAborted.
  ///
  /// In en, this message translates to:
  /// **'Aborted'**
  String get dashboardStatAborted;

  /// No description provided for @treeMarkerNoFruit.
  ///
  /// In en, this message translates to:
  /// **'No fruit'**
  String get treeMarkerNoFruit;

  /// No description provided for @treeMarkerSnippet.
  ///
  /// In en, this message translates to:
  /// **'{count} fruits · {harvest}'**
  String treeMarkerSnippet(int count, String harvest);

  /// No description provided for @pulpErrorNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get pulpErrorNoCamera;

  /// No description provided for @pulpErrorCapture.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture. Try again.'**
  String get pulpErrorCapture;

  /// No description provided for @pulpCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Pulp Ripeness'**
  String get pulpCameraTitle;

  /// No description provided for @pulpCameraInstruction.
  ///
  /// In en, this message translates to:
  /// **'Cut mango in half · Place flat side up\nAlign pulp inside the box · Use natural daylight'**
  String get pulpCameraInstruction;

  /// No description provided for @pulpStage1.
  ///
  /// In en, this message translates to:
  /// **'Just harvested'**
  String get pulpStage1;

  /// No description provided for @pulpStage2.
  ///
  /// In en, this message translates to:
  /// **'Starting to ripen'**
  String get pulpStage2;

  /// No description provided for @pulpStage3.
  ///
  /// In en, this message translates to:
  /// **'Ripening'**
  String get pulpStage3;

  /// No description provided for @pulpStage4.
  ///
  /// In en, this message translates to:
  /// **'Ready to eat'**
  String get pulpStage4;

  /// No description provided for @pulpStage5.
  ///
  /// In en, this message translates to:
  /// **'Overripe'**
  String get pulpStage5;

  /// No description provided for @pulpErrorAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed. Try again.'**
  String get pulpErrorAnalysis;

  /// No description provided for @pulpResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Pulp Analysis'**
  String get pulpResultTitle;

  /// No description provided for @pulpAnalysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing pulp colour…'**
  String get pulpAnalysing;

  /// No description provided for @pulpRipenessStage.
  ///
  /// In en, this message translates to:
  /// **'Ripeness Stage'**
  String get pulpRipenessStage;

  /// No description provided for @pulpStageOf.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage} of 5 — {label}'**
  String pulpStageOf(int stage, String label);

  /// No description provided for @pulpBrixLabel.
  ///
  /// In en, this message translates to:
  /// **'Brix (Sweetness)'**
  String get pulpBrixLabel;

  /// No description provided for @pulpFirmnessLabel.
  ///
  /// In en, this message translates to:
  /// **'Firmness'**
  String get pulpFirmnessLabel;

  /// No description provided for @pulpNotReady.
  ///
  /// In en, this message translates to:
  /// **'Not ready yet'**
  String get pulpNotReady;

  /// No description provided for @pulpDaysToReady.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Approx. 1 more day at room temperature} other{Approx. {days} more days at room temperature}}'**
  String pulpDaysToReady(int days);

  /// No description provided for @pulpColourComparison.
  ///
  /// In en, this message translates to:
  /// **'Pulp Colour Comparison'**
  String get pulpColourComparison;

  /// No description provided for @pulpDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get pulpDetected;

  /// No description provided for @pulpStageReference.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage} reference'**
  String pulpStageReference(int stage);

  /// No description provided for @pulpConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {level}'**
  String pulpConfidence(String level);

  /// No description provided for @pulpConfidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get pulpConfidenceHigh;

  /// No description provided for @pulpConfidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get pulpConfidenceMedium;

  /// No description provided for @pulpConfidenceLow.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get pulpConfidenceLow;

  /// No description provided for @pulpCitation.
  ///
  /// In en, this message translates to:
  /// **'Based on Nasir et al. (2021) — Harumanis ripeness guide (UniMAP)'**
  String get pulpCitation;

  /// No description provided for @pulpScanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Mango'**
  String get pulpScanAnother;

  /// No description provided for @announcementsErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load announcements: {detail}'**
  String announcementsErrorLoad(String detail);

  /// No description provided for @announcementsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get announcementsFilterAll;

  /// No description provided for @announcementsFilterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get announcementsFilterUpcoming;

  /// No description provided for @announcementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet.'**
  String get announcementsEmpty;

  /// No description provided for @announcementsPost.
  ///
  /// In en, this message translates to:
  /// **'Post Announcement'**
  String get announcementsPost;

  /// No description provided for @announcementsPostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share news, workshops or notices'**
  String get announcementsPostSubtitle;

  /// No description provided for @announcementDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete announcement?'**
  String get announcementDetailDeleteTitle;

  /// No description provided for @commonCantBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get commonCantBeUndone;

  /// No description provided for @announcementDetailErrorDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete. Please try again.'**
  String get announcementDetailErrorDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @announcementDetailPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted {date} · DOA Perlis'**
  String announcementDetailPosted(String date);

  /// No description provided for @announcementEditorErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Title and description are required.'**
  String get announcementEditorErrorRequired;

  /// No description provided for @announcementEditorErrorSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes. Please try again.'**
  String get announcementEditorErrorSave;

  /// No description provided for @announcementEditorErrorPost.
  ///
  /// In en, this message translates to:
  /// **'Failed to post announcement. Please try again.'**
  String get announcementEditorErrorPost;

  /// No description provided for @announcementEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Announcement'**
  String get announcementEditorEditTitle;

  /// No description provided for @announcementEditorAddBanner.
  ///
  /// In en, this message translates to:
  /// **'Add banner image (optional)'**
  String get announcementEditorAddBanner;

  /// No description provided for @announcementEditorBannerLocked.
  ///
  /// In en, this message translates to:
  /// **'Banner image can\'t be changed here — delete and repost to change it.'**
  String get announcementEditorBannerLocked;

  /// No description provided for @announcementEditorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get announcementEditorTitleLabel;

  /// No description provided for @announcementEditorTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Free Harumanis Grafting Workshop'**
  String get announcementEditorTitleHint;

  /// No description provided for @announcementEditorDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get announcementEditorDescriptionLabel;

  /// No description provided for @announcementEditorDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Details farmers need to know'**
  String get announcementEditorDescriptionHint;

  /// No description provided for @announcementEditorLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get announcementEditorLocationLabel;

  /// No description provided for @announcementEditorLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pejabat DOA Perlis'**
  String get announcementEditorLocationHint;

  /// No description provided for @announcementEditorEventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Event date (optional)'**
  String get announcementEditorEventDateLabel;

  /// No description provided for @announcementEditorNoDate.
  ///
  /// In en, this message translates to:
  /// **'No specific date — general notice'**
  String get announcementEditorNoDate;

  /// No description provided for @announcementEditorSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get announcementEditorSaveChanges;

  /// No description provided for @doaReportErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load report: {detail}'**
  String doaReportErrorLoad(String detail);

  /// No description provided for @doaReportErrorVerify.
  ///
  /// In en, this message translates to:
  /// **'Failed to update verification: {detail}'**
  String doaReportErrorVerify(String detail);

  /// No description provided for @doaReportSeasonAllFarms.
  ///
  /// In en, this message translates to:
  /// **'Season {year} · All Farms'**
  String doaReportSeasonAllFarms(String year);

  /// No description provided for @doaReportYieldByStage.
  ///
  /// In en, this message translates to:
  /// **'Yield by Stage'**
  String get doaReportYieldByStage;

  /// No description provided for @doaReportByFarm.
  ///
  /// In en, this message translates to:
  /// **'By Farm ({count})'**
  String doaReportByFarm(int count);

  /// No description provided for @doaReportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search farm, owner, or location'**
  String get doaReportSearchHint;

  /// No description provided for @doaReportNoFarms.
  ///
  /// In en, this message translates to:
  /// **'No farms registered yet.'**
  String get doaReportNoFarms;

  /// No description provided for @doaReportNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No farms match \"{query}\".'**
  String doaReportNoMatch(String query);

  /// No description provided for @doaReportStatFarms.
  ///
  /// In en, this message translates to:
  /// **'Farms'**
  String get doaReportStatFarms;

  /// No description provided for @doaReportStatActiveFruits.
  ///
  /// In en, this message translates to:
  /// **'Active Fruits'**
  String get doaReportStatActiveFruits;

  /// No description provided for @doaReportStatLostAborted.
  ///
  /// In en, this message translates to:
  /// **'Lost/Aborted'**
  String get doaReportStatLostAborted;

  /// No description provided for @doaReportNoActiveFruits.
  ///
  /// In en, this message translates to:
  /// **'No active fruits recorded this season.'**
  String get doaReportNoActiveFruits;

  /// No description provided for @doaReportVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get doaReportVerified;

  /// No description provided for @doaReportNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get doaReportNotVerified;

  /// No description provided for @doaReportStatLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get doaReportStatLost;

  /// No description provided for @doaReportStageCount.
  ///
  /// In en, this message translates to:
  /// **'{stage}: {count}'**
  String doaReportStageCount(String stage, int count);

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusHarvested.
  ///
  /// In en, this message translates to:
  /// **'Harvested'**
  String get orderStatusHarvested;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @ordersErrorNoFarm.
  ///
  /// In en, this message translates to:
  /// **'No farm linked to your account.'**
  String get ordersErrorNoFarm;

  /// No description provided for @ordersErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders.'**
  String get ordersErrorLoad;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No {status} orders'**
  String ordersEmptyFiltered(String status);

  /// No description provided for @ordersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Orders from buyers will appear here.'**
  String get ordersEmptyBody;

  /// No description provided for @ordersPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get ordersPaid;

  /// No description provided for @ordersUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get ordersUnpaid;

  /// No description provided for @ordersOrderedOn.
  ///
  /// In en, this message translates to:
  /// **'Ordered {date}'**
  String ordersOrderedOn(String date);

  /// No description provided for @orderDetailStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order {status}.'**
  String orderDetailStatusUpdated(String status);

  /// No description provided for @orderDetailErrorUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update: {detail}'**
  String orderDetailErrorUpdate(String detail);

  /// No description provided for @orderDetailConfirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get orderDetailConfirmOrder;

  /// No description provided for @orderDetailMarkHarvested.
  ///
  /// In en, this message translates to:
  /// **'Mark Harvested'**
  String get orderDetailMarkHarvested;

  /// No description provided for @orderDetailMarkDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark Delivered'**
  String get orderDetailMarkDelivered;

  /// No description provided for @orderDetailCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get orderDetailCancelOrder;

  /// No description provided for @orderDetailConfirmMsgConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm this order? The buyer will be notified to proceed with payment.'**
  String get orderDetailConfirmMsgConfirmed;

  /// No description provided for @orderDetailConfirmMsgHarvested.
  ///
  /// In en, this message translates to:
  /// **'Mark this order as harvested? This means the mangoes are ready.'**
  String get orderDetailConfirmMsgHarvested;

  /// No description provided for @orderDetailConfirmMsgDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as delivered? This closes the order.'**
  String get orderDetailConfirmMsgDelivered;

  /// No description provided for @orderDetailConfirmMsgCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order? This cannot be undone.'**
  String get orderDetailConfirmMsgCancelled;

  /// No description provided for @orderDetailConfirmMsgOther.
  ///
  /// In en, this message translates to:
  /// **'Update order status to {status}?'**
  String orderDetailConfirmMsgOther(String status);

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderDetailTitle(String id);

  /// No description provided for @orderDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderDetailStatus;

  /// No description provided for @orderDetailBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get orderDetailBuyer;

  /// No description provided for @orderDetailDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get orderDetailDeliveryAddress;

  /// No description provided for @orderDetailNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address provided — contact buyer via WhatsApp.'**
  String get orderDetailNoAddress;

  /// No description provided for @orderDetailQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get orderDetailQuantity;

  /// No description provided for @orderDetailPricePerKg.
  ///
  /// In en, this message translates to:
  /// **'Price per kg'**
  String get orderDetailPricePerKg;

  /// No description provided for @orderDetailTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderDetailTotal;

  /// No description provided for @orderDetailPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get orderDetailPayment;

  /// No description provided for @orderDetailPaidTick.
  ///
  /// In en, this message translates to:
  /// **'Paid ✓'**
  String get orderDetailPaidTick;

  /// No description provided for @orderDetailAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get orderDetailAwaitingPayment;

  /// No description provided for @orderDetailPaidAt.
  ///
  /// In en, this message translates to:
  /// **'Paid at'**
  String get orderDetailPaidAt;

  /// No description provided for @orderDetailTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get orderDetailTargetDate;

  /// No description provided for @orderDetailOrderedOn.
  ///
  /// In en, this message translates to:
  /// **'Ordered on'**
  String get orderDetailOrderedOn;

  /// No description provided for @orderDetailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes: {notes}'**
  String orderDetailNotes(String notes);

  /// No description provided for @orderDetailMarkAsHarvested.
  ///
  /// In en, this message translates to:
  /// **'Mark as Harvested'**
  String get orderDetailMarkAsHarvested;

  /// No description provided for @orderDetailMarkAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get orderDetailMarkAsDelivered;

  /// No description provided for @orderDetailCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order completed.'**
  String get orderDetailCompleted;

  /// No description provided for @orderDetailCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled.'**
  String get orderDetailCancelled;

  /// No description provided for @farmPhotosAddCaption.
  ///
  /// In en, this message translates to:
  /// **'Add caption'**
  String get farmPhotosAddCaption;

  /// No description provided for @farmPhotosCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Harumanis Season 2025 (optional)'**
  String get farmPhotosCaptionHint;

  /// No description provided for @farmPhotosUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get farmPhotosUpload;

  /// No description provided for @farmPhotosErrorUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get farmPhotosErrorUpload;

  /// No description provided for @farmPhotosDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete photo?'**
  String get farmPhotosDeleteTitle;

  /// No description provided for @farmPhotosDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This photo will be permanently removed.'**
  String get farmPhotosDeleteBody;

  /// No description provided for @farmPhotosAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get farmPhotosAddTooltip;

  /// No description provided for @farmPhotosNoFarmTitle.
  ///
  /// In en, this message translates to:
  /// **'No farm set up yet'**
  String get farmPhotosNoFarmTitle;

  /// No description provided for @farmPhotosNoFarmBody.
  ///
  /// In en, this message translates to:
  /// **'Create your farm profile first.'**
  String get farmPhotosNoFarmBody;

  /// No description provided for @farmPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/5 photos'**
  String farmPhotosCount(int count);

  /// No description provided for @farmPhotosTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a photo'**
  String get farmPhotosTapToAdd;

  /// No description provided for @farmPhotosEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get farmPhotosEmptyTitle;

  /// No description provided for @farmPhotosEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add up to 5 photos to attract buyers'**
  String get farmPhotosEmptyBody;

  /// No description provided for @farmPhotosAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get farmPhotosAddButton;

  /// No description provided for @qrTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer QR Code'**
  String get qrTitle;

  /// No description provided for @qrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show this to buyers when selling your Harumanis'**
  String get qrSubtitle;

  /// No description provided for @qrScanWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with any camera'**
  String get qrScanWithCamera;

  /// No description provided for @qrDaysUntilReady.
  ///
  /// In en, this message translates to:
  /// **'Days until ready to eat'**
  String get qrDaysUntilReady;

  /// No description provided for @qrDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Buyers will be reminded after this many days'**
  String get qrDaysHint;

  /// No description provided for @qrDaysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get qrDaysUnit;

  /// No description provided for @qrHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get qrHowItWorks;

  /// No description provided for @qrStep1.
  ///
  /// In en, this message translates to:
  /// **'Buyer scans this QR with their phone camera'**
  String get qrStep1;

  /// No description provided for @qrStep2.
  ///
  /// In en, this message translates to:
  /// **'A page opens — they tap \"Open in Beli Harumanis\" or download the app first'**
  String get qrStep2;

  /// No description provided for @qrStep3.
  ///
  /// In en, this message translates to:
  /// **'They tap \"Remind Me\" → app notifies them in {days} days when fruit is ready to eat'**
  String qrStep3(int days);

  /// No description provided for @qrStep4.
  ///
  /// In en, this message translates to:
  /// **'They can also place future orders directly from your farm page'**
  String get qrStep4;

  /// No description provided for @qrTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Take a screenshot and print this to display at your stall'**
  String get qrTip;

  /// No description provided for @treeListTreeNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. T01'**
  String get treeListTreeNumberHint;
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
