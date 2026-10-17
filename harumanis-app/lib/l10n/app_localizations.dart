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
  /// **'Bahasa / Language'**
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

  /// No description provided for @stageBadge.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage} · {label}'**
  String stageBadge(int stage, String label);

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
  /// **'Beli Harumanis v{version} is required. Download the latest APK to continue.'**
  String updateRequiredBody(String version);

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Beli Harumanis v{version} is available with new features and fixes.'**
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

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get commonFullName;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach server. Check your connection.'**
  String get commonNoConnection;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Fresh from the farm, direct to you'**
  String get loginTagline;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your buyer account'**
  String get loginSubtitle;

  /// No description provided for @loginErrorFarmerAccount.
  ///
  /// In en, this message translates to:
  /// **'This account is registered as a farmer. Please use the Ai-Harumanis app.'**
  String get loginErrorFarmerAccount;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginErrorFailed;

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
  /// **'Failed to send code.'**
  String get loginErrorSendCodeFailed;

  /// No description provided for @loginPasswordResetDone.
  ///
  /// In en, this message translates to:
  /// **'Password reset! Please log in.'**
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
  /// **'Enter your email to receive a reset code.'**
  String get loginForgotPasswordBody;

  /// No description provided for @loginCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {email}.'**
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
  /// **'Create Buyer Account'**
  String get loginCreateAccountTitle;

  /// No description provided for @loginDeliveryAddressRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address *'**
  String get loginDeliveryAddressRequiredLabel;

  /// No description provided for @loginPhoneOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get loginPhoneOptionalLabel;

  /// No description provided for @loginWhatsappOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number (optional)'**
  String get loginWhatsappOptionalLabel;

  /// No description provided for @loginErrorRegisterRequired.
  ///
  /// In en, this message translates to:
  /// **'Name, email, address and password are required.'**
  String get loginErrorRegisterRequired;

  /// No description provided for @loginAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please log in.'**
  String get loginAccountCreated;

  /// No description provided for @loginErrorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {detail}'**
  String loginErrorRegisterFailed(String detail);

  /// No description provided for @deliveryAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Full address for mango delivery'**
  String get deliveryAddressHint;

  /// No description provided for @marketErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load farms. Pull to refresh.'**
  String get marketErrorLoad;

  /// No description provided for @marketMyOrdersTooltip.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get marketMyOrdersTooltip;

  /// No description provided for @marketProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get marketProfileTooltip;

  /// No description provided for @marketHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Malaysia\'s finest mango'**
  String get marketHeroSubtitle;

  /// No description provided for @marketPillDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct from farm'**
  String get marketPillDirect;

  /// No description provided for @marketPillAiTracked.
  ///
  /// In en, this message translates to:
  /// **'AI-tracked harvest'**
  String get marketPillAiTracked;

  /// No description provided for @marketFarmsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 farm available} other{{count} farms available}}'**
  String marketFarmsAvailable(int count);

  /// No description provided for @marketMangoCount.
  ///
  /// In en, this message translates to:
  /// **'{count} mangoes'**
  String marketMangoCount(int count);

  /// No description provided for @marketReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{(1 review)} other{({count} reviews)}}'**
  String marketReviewCount(int count);

  /// No description provided for @marketReadyToHarvest.
  ///
  /// In en, this message translates to:
  /// **'Ready to harvest!'**
  String get marketReadyToHarvest;

  /// No description provided for @marketHarvestIn.
  ///
  /// In en, this message translates to:
  /// **'Harvest in {days}d'**
  String marketHarvestIn(int days);

  /// No description provided for @marketGrowthStages.
  ///
  /// In en, this message translates to:
  /// **'Growth stages'**
  String get marketGrowthStages;

  /// No description provided for @marketLegendCount.
  ///
  /// In en, this message translates to:
  /// **'{stage} {count}'**
  String marketLegendCount(String stage, int count);

  /// No description provided for @marketComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get marketComingSoon;

  /// No description provided for @marketComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Harumanis farms from Perlis & Kedah\nwill appear here once listed.'**
  String get marketComingSoonBody;

  /// No description provided for @marketWhatIsHarumanis.
  ///
  /// In en, this message translates to:
  /// **'What is Harumanis?'**
  String get marketWhatIsHarumanis;

  /// No description provided for @marketFact1.
  ///
  /// In en, this message translates to:
  /// **'Malaysia\'s most prized mango variety — grown only in Perlis & Kedah'**
  String get marketFact1;

  /// No description provided for @marketFact2.
  ///
  /// In en, this message translates to:
  /// **'Exceptionally sweet, fiberless flesh with a distinct honey aroma'**
  String get marketFact2;

  /// No description provided for @marketFact3.
  ///
  /// In en, this message translates to:
  /// **'Short season — harvested once a year, making it rare and highly sought after'**
  String get marketFact3;

  /// No description provided for @marketFact4.
  ///
  /// In en, this message translates to:
  /// **'Order directly from the farm — fresh, traceable, no middlemen'**
  String get marketFact4;

  /// No description provided for @marketPullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh once farms are listed.'**
  String get marketPullToRefresh;

  /// No description provided for @farmErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load farm details.'**
  String get farmErrorLoad;

  /// No description provided for @farmOwnerVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified Farm Owner'**
  String get farmOwnerVerified;

  /// No description provided for @farmOwner.
  ///
  /// In en, this message translates to:
  /// **'Farm Owner'**
  String get farmOwner;

  /// No description provided for @farmAvailableFruit.
  ///
  /// In en, this message translates to:
  /// **'Available Fruit'**
  String get farmAvailableFruit;

  /// No description provided for @farmNearHarvest.
  ///
  /// In en, this message translates to:
  /// **'Near harvest'**
  String get farmNearHarvest;

  /// No description provided for @farmFirstHarvest.
  ///
  /// In en, this message translates to:
  /// **'First harvest'**
  String get farmFirstHarvest;

  /// No description provided for @farmTreeBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Tree Breakdown'**
  String get farmTreeBreakdown;

  /// No description provided for @farmTreeNumber.
  ///
  /// In en, this message translates to:
  /// **'Tree {number}'**
  String farmTreeNumber(String number);

  /// No description provided for @farmEstHarvest.
  ///
  /// In en, this message translates to:
  /// **'Est. harvest: {date}'**
  String farmEstHarvest(String date);

  /// No description provided for @farmFruitCount.
  ///
  /// In en, this message translates to:
  /// **'{count} fruits'**
  String farmFruitCount(int count);

  /// No description provided for @farmNoFruits.
  ///
  /// In en, this message translates to:
  /// **'No fruits detected yet.'**
  String get farmNoFruits;

  /// No description provided for @farmRemindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get farmRemindMe;

  /// No description provided for @farmPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place an Order'**
  String get farmPlaceOrder;

  /// No description provided for @farmReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get farmReviews;

  /// No description provided for @farmReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String farmReviewCount(int count);

  /// No description provided for @farmNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first to share your experience!'**
  String get farmNoReviews;

  /// No description provided for @ordersPaymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed! Your order is now active.'**
  String get ordersPaymentConfirmed;

  /// No description provided for @ordersErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders.'**
  String get ordersErrorLoad;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Browse farms and place your first order!'**
  String get ordersEmptyBody;

  /// No description provided for @ordersPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending — tap to pay'**
  String get ordersPaymentPending;

  /// No description provided for @orderDetailPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {detail}'**
  String orderDetailPaymentFailed(String detail);

  /// No description provided for @orderDetailWhatsappMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, I placed Order #{id} for {quantity} kg of Harumanis from {farm}.'**
  String orderDetailWhatsappMessage(int id, String quantity, String farm);

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderDetailTitle(int id);

  /// No description provided for @orderDetailPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get orderDetailPlaced;

  /// No description provided for @orderDetailWaitingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for farmer to confirm your order.'**
  String get orderDetailWaitingConfirm;

  /// No description provided for @orderDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderDetailStatus;

  /// No description provided for @orderDetailFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get orderDetailFarm;

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

  /// No description provided for @orderDetailPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderDetailPaymentPending;

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

  /// No description provided for @orderDetailPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get orderDetailPayNow;

  /// No description provided for @orderDetailEditReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Your Review'**
  String get orderDetailEditReview;

  /// No description provided for @orderDetailLeaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a Review'**
  String get orderDetailLeaveReview;

  /// No description provided for @orderDetailNoComment.
  ///
  /// In en, this message translates to:
  /// **'No comment'**
  String get orderDetailNoComment;

  /// No description provided for @orderDetailContactWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Contact Farmer via WhatsApp'**
  String get orderDetailContactWhatsapp;

  /// No description provided for @orderDetailNoWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Farmer has not added a WhatsApp number yet.'**
  String get orderDetailNoWhatsapp;

  /// No description provided for @orderTimelinePlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderTimelinePlaced;

  /// No description provided for @orderTimelineCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderTimelineCancelled;

  /// No description provided for @orderTimelineConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by Farmer'**
  String get orderTimelineConfirmed;

  /// No description provided for @orderTimelinePaid.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get orderTimelinePaid;

  /// No description provided for @orderTimelineHarvested.
  ///
  /// In en, this message translates to:
  /// **'Harvested'**
  String get orderTimelineHarvested;

  /// No description provided for @orderTimelineDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderTimelineDelivered;

  /// No description provided for @orderTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Progress'**
  String get orderTimelineTitle;

  /// No description provided for @reviewErrorNoRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a star rating.'**
  String get reviewErrorNoRating;

  /// No description provided for @reviewErrorSubmit.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review. Please try again.'**
  String get reviewErrorSubmit;

  /// No description provided for @reviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with this farm?'**
  String get reviewPrompt;

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience (optional)'**
  String get reviewCommentHint;

  /// No description provided for @reviewUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Review'**
  String get reviewUpdate;

  /// No description provided for @reviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviewSubmit;

  /// No description provided for @orderErrorQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity.'**
  String get orderErrorQuantity;

  /// No description provided for @orderErrorNoPrice.
  ///
  /// In en, this message translates to:
  /// **'This farm has not set a price yet.'**
  String get orderErrorNoPrice;

  /// No description provided for @orderErrorPlace.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order. Please try again.'**
  String get orderErrorPlace;

  /// No description provided for @orderTitle.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get orderTitle;

  /// No description provided for @orderFruitsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} fruits available · {farmer}'**
  String orderFruitsAvailable(int count, String farmer);

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity (kg)'**
  String get orderQuantityLabel;

  /// No description provided for @orderPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'incl. 2% platform fee'**
  String get orderPlatformFee;

  /// No description provided for @orderPriceNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get orderPriceNotSet;

  /// No description provided for @orderTargetHarvest.
  ///
  /// In en, this message translates to:
  /// **'Target harvest: {date}'**
  String orderTargetHarvest(String date);

  /// No description provided for @orderTargetHarvestOptional.
  ///
  /// In en, this message translates to:
  /// **'Target harvest date (optional)'**
  String get orderTargetHarvestOptional;

  /// No description provided for @orderNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes to farmer (optional)'**
  String get orderNotesLabel;

  /// No description provided for @orderTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get orderTotalAmount;

  /// No description provided for @orderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get orderConfirm;

  /// No description provided for @orderFootnote.
  ///
  /// In en, this message translates to:
  /// **'Order is sent to the farmer for confirmation. Payment is done after farmer confirms.'**
  String get orderFootnote;

  /// No description provided for @profileSessionExpiredRelogin.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log out and sign in again.'**
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

  /// No description provided for @profileErrorSaveStatusDetail.
  ///
  /// In en, this message translates to:
  /// **'Failed to save (error {status}: {detail}).'**
  String profileErrorSaveStatusDetail(String status, String detail);

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

  /// No description provided for @profileBuyerAccount.
  ///
  /// In en, this message translates to:
  /// **'Buyer Account'**
  String get profileBuyerAccount;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get profilePersonalInfo;

  /// No description provided for @profileDeliveryAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get profileDeliveryAddressLabel;

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

  /// No description provided for @profileWhatsappHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 60123456789'**
  String get profileWhatsappHint;

  /// No description provided for @profileWhatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get profileWhatsappLabel;

  /// No description provided for @profileWhatsappHelper.
  ///
  /// In en, this message translates to:
  /// **'Farmers may contact you here about your order'**
  String get profileWhatsappHelper;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileSaveButton;

  /// No description provided for @profileAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get profileAppVersion;

  /// No description provided for @profilePoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get profilePoweredBy;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @pulpErrorNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get pulpErrorNoCamera;

  /// No description provided for @pulpErrorCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Check permissions.'**
  String get pulpErrorCameraUnavailable;

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

  /// No description provided for @pulpSwipeBack.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to go back'**
  String get pulpSwipeBack;

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

  /// No description provided for @pulpReadyToEat.
  ///
  /// In en, this message translates to:
  /// **'Ready to eat'**
  String get pulpReadyToEat;

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

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Ripeness Reminders'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifies you when your Harumanis is ready to eat'**
  String get reminderChannelDescription;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'🥭 Your Harumanis is ready to eat!'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'The Harumanis from {farm} you bought is now at its sweetest. Enjoy!'**
  String reminderNotificationBody(String farm);

  /// No description provided for @reminderAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please allow notifications to set a reminder.'**
  String get reminderAllowNotifications;

  /// No description provided for @reminderPickerHelp.
  ///
  /// In en, this message translates to:
  /// **'When did you buy the fruit?'**
  String get reminderPickerHelp;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set! We\'ll notify you on {date} at 9am.'**
  String reminderSet(String date);

  /// No description provided for @reminderErrorSet.
  ///
  /// In en, this message translates to:
  /// **'Could not set reminder: {detail}'**
  String reminderErrorSet(String detail);

  /// No description provided for @reminderSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Ripeness Reminder'**
  String get reminderSheetTitle;

  /// No description provided for @reminderPurchaseQuestion.
  ///
  /// In en, this message translates to:
  /// **'When did you buy this fruit?'**
  String get reminderPurchaseQuestion;

  /// No description provided for @reminderChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get reminderChange;

  /// No description provided for @reminderExplanation.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you on {date} at 9am — {days} days after purchase when Harumanis is sweetest.'**
  String reminderExplanation(String date, int days);

  /// No description provided for @reminderSetting.
  ///
  /// In en, this message translates to:
  /// **'Setting...'**
  String get reminderSetting;

  /// No description provided for @reminderSetButton.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get reminderSetButton;
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
