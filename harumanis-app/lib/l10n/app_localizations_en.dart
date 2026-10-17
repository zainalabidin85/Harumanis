// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageRowTitle => 'Bahasa / Language';

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
  String stageBadge(int stage, String label) {
    return 'Stage $stage · $label';
  }

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusHarvested => 'Harvested';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String updateRequiredBody(String version) {
    return 'Beli Harumanis v$version is required. Download the latest APK to continue.';
  }

  @override
  String updateAvailableBody(String version) {
    return 'Beli Harumanis v$version is available with new features and fixes.';
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
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonFullName => 'Full Name';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonNoConnection =>
      'Cannot reach server. Check your connection.';

  @override
  String get loginTagline => 'Fresh from the farm, direct to you';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to your buyer account';

  @override
  String get loginErrorFarmerAccount =>
      'This account is registered as a farmer. Please use the Ai-Harumanis app.';

  @override
  String get loginErrorInvalidCredentials => 'Invalid email or password';

  @override
  String get loginErrorFailed => 'Login failed. Please try again.';

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
  String get loginErrorSendCodeFailed => 'Failed to send code.';

  @override
  String get loginPasswordResetDone => 'Password reset! Please log in.';

  @override
  String get loginErrorInvalidCode => 'Invalid or expired code.';

  @override
  String get loginEnterResetCodeTitle => 'Enter Reset Code';

  @override
  String get loginForgotPasswordTitle => 'Forgot Password';

  @override
  String get loginForgotPasswordBody =>
      'Enter your email to receive a reset code.';

  @override
  String loginCodeSentTo(String email) {
    return 'Code sent to $email.';
  }

  @override
  String get loginSixDigitCodeLabel => '6-digit Code';

  @override
  String get loginNewPasswordLabel => 'New Password';

  @override
  String get loginResetPasswordButton => 'Reset Password';

  @override
  String get loginSendCodeButton => 'Send Code';

  @override
  String get loginCreateAccountTitle => 'Create Buyer Account';

  @override
  String get loginDeliveryAddressRequiredLabel => 'Delivery Address *';

  @override
  String get loginPhoneOptionalLabel => 'Phone (optional)';

  @override
  String get loginWhatsappOptionalLabel => 'WhatsApp number (optional)';

  @override
  String get loginErrorRegisterRequired =>
      'Name, email, address and password are required.';

  @override
  String get loginAccountCreated => 'Account created! Please log in.';

  @override
  String loginErrorRegisterFailed(String detail) {
    return 'Registration failed: $detail';
  }

  @override
  String get deliveryAddressHint => 'Full address for mango delivery';

  @override
  String get marketErrorLoad => 'Failed to load farms. Pull to refresh.';

  @override
  String get marketMyOrdersTooltip => 'My Orders';

  @override
  String get marketProfileTooltip => 'Profile';

  @override
  String get marketHeroSubtitle => 'Malaysia\'s finest mango';

  @override
  String get marketPillDirect => 'Direct from farm';

  @override
  String get marketPillAiTracked => 'AI-tracked harvest';

  @override
  String marketFarmsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count farms available',
      one: '1 farm available',
    );
    return '$_temp0';
  }

  @override
  String marketMangoCount(int count) {
    return '$count mangoes';
  }

  @override
  String marketReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '($count reviews)',
      one: '(1 review)',
    );
    return '$_temp0';
  }

  @override
  String get marketReadyToHarvest => 'Ready to harvest!';

  @override
  String marketHarvestIn(int days) {
    return 'Harvest in ${days}d';
  }

  @override
  String get marketGrowthStages => 'Growth stages';

  @override
  String marketLegendCount(String stage, int count) {
    return '$stage $count';
  }

  @override
  String get marketComingSoon => 'Coming Soon';

  @override
  String get marketComingSoonBody =>
      'Harumanis farms from Perlis & Kedah\nwill appear here once listed.';

  @override
  String get marketWhatIsHarumanis => 'What is Harumanis?';

  @override
  String get marketFact1 =>
      'Malaysia\'s most prized mango variety — grown only in Perlis & Kedah';

  @override
  String get marketFact2 =>
      'Exceptionally sweet, fiberless flesh with a distinct honey aroma';

  @override
  String get marketFact3 =>
      'Short season — harvested once a year, making it rare and highly sought after';

  @override
  String get marketFact4 =>
      'Order directly from the farm — fresh, traceable, no middlemen';

  @override
  String get marketPullToRefresh =>
      'Pull down to refresh once farms are listed.';

  @override
  String get farmErrorLoad => 'Failed to load farm details.';

  @override
  String get farmOwnerVerified => 'Verified Farm Owner';

  @override
  String get farmOwner => 'Farm Owner';

  @override
  String get farmAvailableFruit => 'Available Fruit';

  @override
  String get farmNearHarvest => 'Near harvest';

  @override
  String get farmFirstHarvest => 'First harvest';

  @override
  String get farmTreeBreakdown => 'Tree Breakdown';

  @override
  String farmTreeNumber(String number) {
    return 'Tree $number';
  }

  @override
  String farmEstHarvest(String date) {
    return 'Est. harvest: $date';
  }

  @override
  String farmFruitCount(int count) {
    return '$count fruits';
  }

  @override
  String get farmNoFruits => 'No fruits detected yet.';

  @override
  String get farmRemindMe => 'Remind Me';

  @override
  String get farmPlaceOrder => 'Place an Order';

  @override
  String get farmReviews => 'Reviews';

  @override
  String farmReviewCount(int count) {
    return '$count reviews';
  }

  @override
  String get farmNoReviews =>
      'No reviews yet. Be the first to share your experience!';

  @override
  String get ordersPaymentConfirmed =>
      'Payment confirmed! Your order is now active.';

  @override
  String get ordersErrorLoad => 'Failed to load orders.';

  @override
  String get ordersTitle => 'My Orders';

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String get ordersEmptyBody => 'Browse farms and place your first order!';

  @override
  String get ordersPaymentPending => 'Payment pending — tap to pay';

  @override
  String orderDetailPaymentFailed(String detail) {
    return 'Payment failed: $detail';
  }

  @override
  String orderDetailWhatsappMessage(int id, String quantity, String farm) {
    return 'Hi, I placed Order #$id for $quantity kg of Harumanis from $farm.';
  }

  @override
  String orderDetailTitle(int id) {
    return 'Order #$id';
  }

  @override
  String get orderDetailPlaced => 'Order placed!';

  @override
  String get orderDetailWaitingConfirm =>
      'Waiting for farmer to confirm your order.';

  @override
  String get orderDetailStatus => 'Status';

  @override
  String get orderDetailFarm => 'Farm';

  @override
  String get orderDetailQuantity => 'Quantity';

  @override
  String get orderDetailPricePerKg => 'Price per kg';

  @override
  String get orderDetailPayment => 'Payment';

  @override
  String get orderDetailPaidTick => 'Paid ✓';

  @override
  String get orderDetailPaymentPending => 'Pending';

  @override
  String get orderDetailTargetDate => 'Target date';

  @override
  String get orderDetailOrderedOn => 'Ordered on';

  @override
  String orderDetailNotes(String notes) {
    return 'Notes: $notes';
  }

  @override
  String get orderDetailPayNow => 'Pay Now';

  @override
  String get orderDetailEditReview => 'Edit Your Review';

  @override
  String get orderDetailLeaveReview => 'Leave a Review';

  @override
  String get orderDetailNoComment => 'No comment';

  @override
  String get orderDetailContactWhatsapp => 'Contact Farmer via WhatsApp';

  @override
  String get orderDetailNoWhatsapp =>
      'Farmer has not added a WhatsApp number yet.';

  @override
  String get orderTimelinePlaced => 'Order Placed';

  @override
  String get orderTimelineCancelled => 'Cancelled';

  @override
  String get orderTimelineConfirmed => 'Confirmed by Farmer';

  @override
  String get orderTimelinePaid => 'Payment Received';

  @override
  String get orderTimelineHarvested => 'Harvested';

  @override
  String get orderTimelineDelivered => 'Delivered';

  @override
  String get orderTimelineTitle => 'Order Progress';

  @override
  String get reviewErrorNoRating => 'Please select a star rating.';

  @override
  String get reviewErrorSubmit => 'Failed to submit review. Please try again.';

  @override
  String get reviewPrompt => 'How was your experience with this farm?';

  @override
  String get reviewCommentHint => 'Share your experience (optional)';

  @override
  String get reviewUpdate => 'Update Review';

  @override
  String get reviewSubmit => 'Submit Review';

  @override
  String get orderErrorQuantity => 'Please enter a valid quantity.';

  @override
  String get orderErrorNoPrice => 'This farm has not set a price yet.';

  @override
  String get orderErrorPlace => 'Failed to place order. Please try again.';

  @override
  String get orderTitle => 'Place Order';

  @override
  String orderFruitsAvailable(int count, String farmer) {
    return '$count fruits available · $farmer';
  }

  @override
  String get orderDetails => 'Order Details';

  @override
  String get orderQuantityLabel => 'Quantity (kg)';

  @override
  String get orderPlatformFee => 'incl. 2% platform fee';

  @override
  String get orderPriceNotSet => 'Not set';

  @override
  String orderTargetHarvest(String date) {
    return 'Target harvest: $date';
  }

  @override
  String get orderTargetHarvestOptional => 'Target harvest date (optional)';

  @override
  String get orderNotesLabel => 'Notes to farmer (optional)';

  @override
  String get orderTotalAmount => 'Total Amount';

  @override
  String get orderConfirm => 'Confirm Order';

  @override
  String get orderFootnote =>
      'Order is sent to the farmer for confirmation. Payment is done after farmer confirms.';

  @override
  String get profileSessionExpiredRelogin =>
      'Session expired. Please log out and sign in again.';

  @override
  String profileErrorLoadStatus(String status) {
    return 'Failed to load profile (error $status).';
  }

  @override
  String profileErrorLoad(String detail) {
    return 'Failed to load profile: $detail';
  }

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String profileErrorSaveStatus(String status) {
    return 'Failed to save (error $status).';
  }

  @override
  String profileErrorSaveStatusDetail(String status, String detail) {
    return 'Failed to save (error $status: $detail).';
  }

  @override
  String profileErrorSave(String detail) {
    return 'Failed to save: $detail';
  }

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileBuyerAccount => 'Buyer Account';

  @override
  String get profilePersonalInfo => 'Personal Info';

  @override
  String get profileDeliveryAddressLabel => 'Delivery Address';

  @override
  String get profilePhoneLabel => 'Phone number';

  @override
  String get profilePhoneHint => 'e.g. 0123456789';

  @override
  String get profileWhatsappHint => 'e.g. 60123456789';

  @override
  String get profileWhatsappLabel => 'WhatsApp number';

  @override
  String get profileWhatsappHelper =>
      'Farmers may contact you here about your order';

  @override
  String get profileSaveButton => 'Save Profile';

  @override
  String get profileAppVersion => 'App Version';

  @override
  String get profilePoweredBy => 'Powered by';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get pulpErrorNoCamera => 'No camera found on this device.';

  @override
  String get pulpErrorCameraUnavailable =>
      'Camera unavailable. Check permissions.';

  @override
  String get pulpErrorCapture => 'Failed to capture. Try again.';

  @override
  String get pulpCameraTitle => 'Pulp Ripeness';

  @override
  String get pulpSwipeBack => 'Swipe right to go back';

  @override
  String get pulpCameraInstruction =>
      'Cut mango in half · Place flat side up\nAlign pulp inside the box · Use natural daylight';

  @override
  String get pulpStage1 => 'Just harvested';

  @override
  String get pulpStage2 => 'Starting to ripen';

  @override
  String get pulpStage3 => 'Ripening';

  @override
  String get pulpStage4 => 'Ready to eat';

  @override
  String get pulpStage5 => 'Overripe';

  @override
  String get pulpErrorAnalysis => 'Analysis failed. Try again.';

  @override
  String get pulpResultTitle => 'Pulp Analysis';

  @override
  String get pulpAnalysing => 'Analysing pulp colour…';

  @override
  String get pulpRipenessStage => 'Ripeness Stage';

  @override
  String pulpStageOf(int stage, String label) {
    return 'Stage $stage of 5 — $label';
  }

  @override
  String get pulpBrixLabel => 'Brix (Sweetness)';

  @override
  String get pulpFirmnessLabel => 'Firmness';

  @override
  String get pulpReadyToEat => 'Ready to eat';

  @override
  String get pulpNotReady => 'Not ready yet';

  @override
  String pulpDaysToReady(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Approx. $days more days at room temperature',
      one: 'Approx. 1 more day at room temperature',
    );
    return '$_temp0';
  }

  @override
  String get pulpColourComparison => 'Pulp Colour Comparison';

  @override
  String get pulpDetected => 'Detected';

  @override
  String pulpStageReference(int stage) {
    return 'Stage $stage reference';
  }

  @override
  String pulpConfidence(String level) {
    return 'Confidence: $level';
  }

  @override
  String get pulpConfidenceHigh => 'high';

  @override
  String get pulpConfidenceMedium => 'medium';

  @override
  String get pulpConfidenceLow => 'low';

  @override
  String get pulpCitation =>
      'Based on Nasir et al. (2021) — Harumanis ripeness guide (UniMAP)';

  @override
  String get pulpScanAnother => 'Scan Another Mango';

  @override
  String get reminderChannelName => 'Ripeness Reminders';

  @override
  String get reminderChannelDescription =>
      'Notifies you when your Harumanis is ready to eat';

  @override
  String get reminderNotificationTitle => '🥭 Your Harumanis is ready to eat!';

  @override
  String reminderNotificationBody(String farm) {
    return 'The Harumanis from $farm you bought is now at its sweetest. Enjoy!';
  }

  @override
  String get reminderAllowNotifications =>
      'Please allow notifications to set a reminder.';

  @override
  String get reminderPickerHelp => 'When did you buy the fruit?';

  @override
  String reminderSet(String date) {
    return 'Reminder set! We\'ll notify you on $date at 9am.';
  }

  @override
  String reminderErrorSet(String detail) {
    return 'Could not set reminder: $detail';
  }

  @override
  String get reminderSheetTitle => 'Set Ripeness Reminder';

  @override
  String get reminderPurchaseQuestion => 'When did you buy this fruit?';

  @override
  String get reminderChange => 'Change';

  @override
  String reminderExplanation(String date, int days) {
    return 'We\'ll remind you on $date at 9am — $days days after purchase when Harumanis is sweetest.';
  }

  @override
  String get reminderSetting => 'Setting...';

  @override
  String get reminderSetButton => 'Set Reminder';
}
