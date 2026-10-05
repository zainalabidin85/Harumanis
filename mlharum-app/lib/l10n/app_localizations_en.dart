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

  @override
  String get treeListErrorNoFarm =>
      'No farm found. Please set up your farm in Profile first.';

  @override
  String treeListErrorLoad(String detail) {
    return 'Failed to load trees: $detail';
  }

  @override
  String treeListGettingLocationAccuracy(String meters) {
    return 'Getting location… ±${meters}m';
  }

  @override
  String get treeListGettingLocation => 'Getting location…';

  @override
  String get treeListLocationUnavailable => 'Location unavailable';

  @override
  String get commonRetry => 'Retry';

  @override
  String get treeListAddTree => 'Add Tree';

  @override
  String get treeListTreeNumberLabel => 'Tree number *';

  @override
  String get treeListNotesLabel => 'Notes (optional)';

  @override
  String get treeListNotesHint => 'e.g. Near main road';

  @override
  String treeListAddedWithGps(String number) {
    return 'Tree $number added with GPS.';
  }

  @override
  String treeListAddedNoGps(String number) {
    return 'Tree $number added (no GPS).';
  }

  @override
  String treeListErrorAdd(String detail) {
    return 'Failed to add tree: $detail';
  }

  @override
  String get commonAdd => 'Add';

  @override
  String get treeListEmptyTitle => 'No trees registered yet';

  @override
  String get treeListEmptyBody => 'Add your mango trees to get started.';

  @override
  String get treeListAddFirstTree => 'Add First Tree';

  @override
  String treeDetailErrorLoadStatus(String status) {
    return 'Failed to load fruits (error $status).';
  }

  @override
  String treeDetailDeleteTitle(String number) {
    return 'Delete Tree $number?';
  }

  @override
  String get treeDetailDeleteBody =>
      'This will permanently delete this tree and all its scan history. This cannot be undone.';

  @override
  String get commonDelete => 'Delete';

  @override
  String get treeDetailErrorDelete => 'Failed to delete tree.';

  @override
  String treeDetailTitle(String number) {
    return 'Tree $number';
  }

  @override
  String get treeDetailDeleteTooltip => 'Delete tree';

  @override
  String get treeDetailAddFruit => '+ Add Fruit';

  @override
  String treeDetailActiveFruits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active fruits',
      one: '1 active fruit',
    );
    return '$_temp0';
  }

  @override
  String treeDetailEarliestHarvest(String date) {
    return 'Earliest harvest: $date';
  }

  @override
  String treeDetailStageCount(int stage, int count) {
    return 'S$stage: $count';
  }

  @override
  String get treeDetailReadyToHarvest => 'Ready to harvest';

  @override
  String treeDetailDaysToHarvest(int days) {
    return '$days days to harvest';
  }

  @override
  String treeDetailFruitSummary(String size, String stage, int days) {
    return '$size cm · $stage · $days days to harvest';
  }

  @override
  String commonFailedStatus(String status) {
    return 'Failed (error $status).';
  }

  @override
  String get treeDetailMarkHarvested => 'Mark as Harvested';

  @override
  String get treeDetailMarkAborted => 'Mark as Fallen / Aborted';

  @override
  String get treeDetailReasonLabel => 'Reason (optional)';

  @override
  String get treeDetailReasonHint =>
      'e.g. Fell from tree, pest damage, thinned';

  @override
  String get treeDetailConfirmAbort => 'Confirm Abort';

  @override
  String get commonClose => 'Close';

  @override
  String get treeDetailEmptyTitle => 'No active fruits';

  @override
  String get treeDetailEmptyBody =>
      'Scan this tree to detect and track mangoes.';

  @override
  String harvestBadgeLabel(String date, int days) {
    return '$date · $days d';
  }

  @override
  String get cameraErrorNoHand =>
      'No hand detected. Hold your open palm beside the fruit.';

  @override
  String get cameraErrorNoMango =>
      'No mangoes detected. Try again with better lighting.';

  @override
  String get cameraErrorTimeout =>
      'Connection timed out. Check your internet and try again.';

  @override
  String get cameraErrorNoConnection =>
      'Cannot reach server. Check your internet connection.';

  @override
  String get cameraInstruction =>
      'Point at ONE mango. Hold your open palm beside it, then tap Capture.';

  @override
  String get resultReadyForBagging => 'Ready for bagging';

  @override
  String resultAttachLabel(String label) {
    return 'Attach label $label to this fruit';
  }

  @override
  String get commonDone => 'Done';

  @override
  String get resultFlushColorTitle => 'Tag bagging color (optional)';

  @override
  String get resultFlushColorBody =>
      'Match the color you tie on the bagging paper for this flush';

  @override
  String get resultFruitRecorded => 'Fruit Recorded';

  @override
  String get resultStillDeveloping => 'Still Developing';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get resultBackToTree => 'Back to Tree';

  @override
  String get dashboardErrorNoFarm => 'No farm found.';

  @override
  String get dashboardErrorLoad => 'Failed to load dashboard.';

  @override
  String dashboardSeason(String year) {
    return 'Season $year';
  }

  @override
  String get dashboardStatTrees => 'Trees';

  @override
  String get dashboardStatActive => 'Active';

  @override
  String get dashboardStatHarvested => 'Harvested';

  @override
  String get dashboardStatAborted => 'Aborted';

  @override
  String get treeMarkerNoFruit => 'No fruit';

  @override
  String treeMarkerSnippet(int count, String harvest) {
    return '$count fruits · $harvest';
  }

  @override
  String get pulpErrorNoCamera => 'No camera found on this device.';

  @override
  String get pulpErrorCapture => 'Failed to capture. Try again.';

  @override
  String get pulpCameraTitle => 'Pulp Ripeness';

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
  String announcementsErrorLoad(String detail) {
    return 'Failed to load announcements: $detail';
  }

  @override
  String get announcementsFilterAll => 'All';

  @override
  String get announcementsFilterUpcoming => 'Upcoming';

  @override
  String get announcementsEmpty => 'No announcements yet.';

  @override
  String get announcementsPost => 'Post Announcement';

  @override
  String get announcementsPostSubtitle => 'Share news, workshops or notices';

  @override
  String get announcementDetailDeleteTitle => 'Delete announcement?';

  @override
  String get commonCantBeUndone => 'This can\'t be undone.';

  @override
  String get announcementDetailErrorDelete =>
      'Failed to delete. Please try again.';

  @override
  String get commonEdit => 'Edit';

  @override
  String announcementDetailPosted(String date) {
    return 'Posted $date · DOA Perlis';
  }

  @override
  String get announcementEditorErrorRequired =>
      'Title and description are required.';

  @override
  String get announcementEditorErrorSave =>
      'Failed to save changes. Please try again.';

  @override
  String get announcementEditorErrorPost =>
      'Failed to post announcement. Please try again.';

  @override
  String get announcementEditorEditTitle => 'Edit Announcement';

  @override
  String get announcementEditorAddBanner => 'Add banner image (optional)';

  @override
  String get announcementEditorBannerLocked =>
      'Banner image can\'t be changed here — delete and repost to change it.';

  @override
  String get announcementEditorTitleLabel => 'Title';

  @override
  String get announcementEditorTitleHint =>
      'e.g. Free Harumanis Grafting Workshop';

  @override
  String get announcementEditorDescriptionLabel => 'Description';

  @override
  String get announcementEditorDescriptionHint =>
      'Details farmers need to know';

  @override
  String get announcementEditorLocationLabel => 'Location (optional)';

  @override
  String get announcementEditorLocationHint => 'e.g. Pejabat DOA Perlis';

  @override
  String get announcementEditorEventDateLabel => 'Event date (optional)';

  @override
  String get announcementEditorNoDate => 'No specific date — general notice';

  @override
  String get announcementEditorSaveChanges => 'Save Changes';

  @override
  String doaReportErrorLoad(String detail) {
    return 'Failed to load report: $detail';
  }

  @override
  String doaReportErrorVerify(String detail) {
    return 'Failed to update verification: $detail';
  }

  @override
  String doaReportSeasonAllFarms(String year) {
    return 'Season $year · All Farms';
  }

  @override
  String get doaReportYieldByStage => 'Yield by Stage';

  @override
  String doaReportByFarm(int count) {
    return 'By Farm ($count)';
  }

  @override
  String get doaReportSearchHint => 'Search farm, owner, or location';

  @override
  String get doaReportNoFarms => 'No farms registered yet.';

  @override
  String doaReportNoMatch(String query) {
    return 'No farms match \"$query\".';
  }

  @override
  String get doaReportStatFarms => 'Farms';

  @override
  String get doaReportStatActiveFruits => 'Active Fruits';

  @override
  String get doaReportStatLostAborted => 'Lost/Aborted';

  @override
  String get doaReportNoActiveFruits =>
      'No active fruits recorded this season.';

  @override
  String get doaReportVerified => 'Verified';

  @override
  String get doaReportNotVerified => 'Not Verified';

  @override
  String get doaReportStatLost => 'Lost';

  @override
  String doaReportStageCount(String stage, int count) {
    return '$stage: $count';
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
  String get ordersErrorNoFarm => 'No farm linked to your account.';

  @override
  String get ordersErrorLoad => 'Failed to load orders.';

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String ordersEmptyFiltered(String status) {
    return 'No $status orders';
  }

  @override
  String get ordersEmptyBody => 'Orders from buyers will appear here.';

  @override
  String get ordersPaid => 'Paid';

  @override
  String get ordersUnpaid => 'Unpaid';

  @override
  String ordersOrderedOn(String date) {
    return 'Ordered $date';
  }

  @override
  String orderDetailStatusUpdated(String status) {
    return 'Order $status.';
  }

  @override
  String orderDetailErrorUpdate(String detail) {
    return 'Failed to update: $detail';
  }

  @override
  String get orderDetailConfirmOrder => 'Confirm Order';

  @override
  String get orderDetailMarkHarvested => 'Mark Harvested';

  @override
  String get orderDetailMarkDelivered => 'Mark Delivered';

  @override
  String get orderDetailCancelOrder => 'Cancel Order';

  @override
  String get orderDetailConfirmMsgConfirmed =>
      'Confirm this order? The buyer will be notified to proceed with payment.';

  @override
  String get orderDetailConfirmMsgHarvested =>
      'Mark this order as harvested? This means the mangoes are ready.';

  @override
  String get orderDetailConfirmMsgDelivered =>
      'Mark as delivered? This closes the order.';

  @override
  String get orderDetailConfirmMsgCancelled =>
      'Cancel this order? This cannot be undone.';

  @override
  String orderDetailConfirmMsgOther(String status) {
    return 'Update order status to $status?';
  }

  @override
  String orderDetailTitle(String id) {
    return 'Order #$id';
  }

  @override
  String get orderDetailStatus => 'Status';

  @override
  String get orderDetailBuyer => 'Buyer';

  @override
  String get orderDetailDeliveryAddress => 'Delivery Address';

  @override
  String get orderDetailNoAddress =>
      'No address provided — contact buyer via WhatsApp.';

  @override
  String get orderDetailQuantity => 'Quantity';

  @override
  String get orderDetailPricePerKg => 'Price per kg';

  @override
  String get orderDetailTotal => 'Total';

  @override
  String get orderDetailPayment => 'Payment';

  @override
  String get orderDetailPaidTick => 'Paid ✓';

  @override
  String get orderDetailAwaitingPayment => 'Awaiting payment';

  @override
  String get orderDetailPaidAt => 'Paid at';

  @override
  String get orderDetailTargetDate => 'Target date';

  @override
  String get orderDetailOrderedOn => 'Ordered on';

  @override
  String orderDetailNotes(String notes) {
    return 'Notes: $notes';
  }

  @override
  String get orderDetailMarkAsHarvested => 'Mark as Harvested';

  @override
  String get orderDetailMarkAsDelivered => 'Mark as Delivered';

  @override
  String get orderDetailCompleted => 'Order completed.';

  @override
  String get orderDetailCancelled => 'Order cancelled.';

  @override
  String get farmPhotosAddCaption => 'Add caption';

  @override
  String get farmPhotosCaptionHint => 'e.g. Harumanis Season 2025 (optional)';

  @override
  String get farmPhotosUpload => 'Upload';

  @override
  String get farmPhotosErrorUpload => 'Upload failed. Please try again.';

  @override
  String get farmPhotosDeleteTitle => 'Delete photo?';

  @override
  String get farmPhotosDeleteBody => 'This photo will be permanently removed.';

  @override
  String get farmPhotosAddTooltip => 'Add photo';

  @override
  String get farmPhotosNoFarmTitle => 'No farm set up yet';

  @override
  String get farmPhotosNoFarmBody => 'Create your farm profile first.';

  @override
  String farmPhotosCount(int count) {
    return '$count/5 photos';
  }

  @override
  String get farmPhotosTapToAdd => 'Tap + to add a photo';

  @override
  String get farmPhotosEmptyTitle => 'No photos yet';

  @override
  String get farmPhotosEmptyBody => 'Add up to 5 photos to attract buyers';

  @override
  String get farmPhotosAddButton => 'Add Photo';

  @override
  String get qrTitle => 'Buyer QR Code';

  @override
  String get qrSubtitle => 'Show this to buyers when selling your Harumanis';

  @override
  String get qrScanWithCamera => 'Scan with any camera';

  @override
  String get qrDaysUntilReady => 'Days until ready to eat';

  @override
  String get qrDaysHint => 'Buyers will be reminded after this many days';

  @override
  String get qrDaysUnit => 'days';

  @override
  String get qrHowItWorks => 'How it works';

  @override
  String get qrStep1 => 'Buyer scans this QR with their phone camera';

  @override
  String get qrStep2 =>
      'A page opens — they tap \"Open in Beli Harumanis\" or download the app first';

  @override
  String qrStep3(int days) {
    return 'They tap \"Remind Me\" → app notifies them in $days days when fruit is ready to eat';
  }

  @override
  String get qrStep4 =>
      'They can also place future orders directly from your farm page';

  @override
  String get qrTip =>
      'Tip: Take a screenshot and print this to display at your stall';

  @override
  String get treeListTreeNumberHint => 'e.g. T01';
}
