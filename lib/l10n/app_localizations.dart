import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('vi'),
  ];

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Small spends. Clear perspective.'**
  String get greeting;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'A little clarity for your everyday spending.'**
  String get subtitle;

  /// No description provided for @monthSpend.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get monthSpend;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get receipts;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recent;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get viewAll;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scan;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get manual;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Capture receipt'**
  String get camera;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @gear.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get gear;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first receipt starts here'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan a receipt or add an expense to see where your money goes.'**
  String get emptyBody;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get noResults;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search merchants, notes…'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clear;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (VND)'**
  String get amount;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Transaction date'**
  String get date;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get saved;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense and its receipt image?'**
  String get confirmDelete;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review receipt'**
  String get review;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Check the recognized details before saving.'**
  String get reviewHint;

  /// No description provided for @rawText.
  ///
  /// In en, this message translates to:
  /// **'Recognized text'**
  String get rawText;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 1 to 999,999,999,999'**
  String get invalidAmount;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Reading your receipt…'**
  String get processing;

  /// No description provided for @processingHint.
  ///
  /// In en, this message translates to:
  /// **'Processed right on your device'**
  String get processingHint;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop & rotate receipt'**
  String get crop;

  /// No description provided for @captureHint.
  ///
  /// In en, this message translates to:
  /// **'Fit the receipt in the frame. Tap to focus.'**
  String get captureHint;

  /// No description provided for @flash.
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get flash;

  /// No description provided for @shutter.
  ///
  /// In en, this message translates to:
  /// **'Take picture'**
  String get shutter;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Check camera permission in your phone settings, then retry.'**
  String get cameraError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @ocrError.
  ///
  /// In en, this message translates to:
  /// **'Could not read this image. Try another image or enter manually.'**
  String get ocrError;

  /// No description provided for @missingAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount not found'**
  String get missingAmount;

  /// No description provided for @ambiguousAmount.
  ///
  /// In en, this message translates to:
  /// **'Please verify the total amount'**
  String get ambiguousAmount;

  /// No description provided for @missingDate.
  ///
  /// In en, this message translates to:
  /// **'Valid date not found'**
  String get missingDate;

  /// No description provided for @ambiguousDate.
  ///
  /// In en, this message translates to:
  /// **'Multiple dates found'**
  String get ambiguousDate;

  /// No description provided for @missingMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant name not found'**
  String get missingMerchant;

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get distribution;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'Weekly spending'**
  String get thisWeek;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get next;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total spending'**
  String get total;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get export;

  /// No description provided for @exportHint.
  ///
  /// In en, this message translates to:
  /// **'Export the currently displayed transactions'**
  String get exportHint;

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'Demo data'**
  String get demo;

  /// No description provided for @demoHint.
  ///
  /// In en, this message translates to:
  /// **'Kept separate from your personal expenses'**
  String get demoHint;

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'DEMO MODE'**
  String get demoBanner;

  /// No description provided for @demoStart.
  ///
  /// In en, this message translates to:
  /// **'Explore sample data'**
  String get demoStart;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get privacy;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Receipts and expenses are stored locally. Recognition needs no account or internet connection.'**
  String get privacyBody;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About ReceiptFlow'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Mini-project 3 · Flutter & Google ML Kit\nOffline receipt scanning and expense tracking.'**
  String get aboutBody;

  /// No description provided for @noReceipt.
  ///
  /// In en, this message translates to:
  /// **'Manually entered expense'**
  String get noReceipt;

  /// No description provided for @receiptImage.
  ///
  /// In en, this message translates to:
  /// **'Receipt image'**
  String get receiptImage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discard;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get discardBody;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get leave;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get chooseDate;

  /// No description provided for @sampleReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan sample receipt'**
  String get sampleReceipt;

  /// No description provided for @sampleHint.
  ///
  /// In en, this message translates to:
  /// **'The sample image is read by real on-device OCR'**
  String get sampleHint;

  /// No description provided for @exportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expenses to export'**
  String get exportEmpty;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get deleted;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get offline;

  /// No description provided for @insightHint.
  ///
  /// In en, this message translates to:
  /// **'Understand your habits. Spend with intention.'**
  String get insightHint;

  /// No description provided for @noChart.
  ///
  /// In en, this message translates to:
  /// **'No spending in this period'**
  String get noChart;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keep;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open local data. Try restarting the app.'**
  String get startupError;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
