import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Manager'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @profileImage.
  ///
  /// In en, this message translates to:
  /// **'Profile image'**
  String get profileImage;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @farmSettings.
  ///
  /// In en, this message translates to:
  /// **'Farm settings'**
  String get farmSettings;

  /// No description provided for @currencyCode.
  ///
  /// In en, this message translates to:
  /// **'Currency code'**
  String get currencyCode;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Manage cows, poultry, crops, inventory, income and expenses, profile, and farm settings on mobile.'**
  String get welcomeBody;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your farm records on this device.'**
  String get signInSubtitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register as the farm owner. You will sign in after signup.'**
  String get signUpSubtitle;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered? Sign in'**
  String get alreadyRegistered;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get newHere;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick image'**
  String get pickImage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'Bangla'**
  String get bangla;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get genericError;

  /// No description provided for @cowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cows'**
  String get cowsTitle;

  /// No description provided for @manageCows.
  ///
  /// In en, this message translates to:
  /// **'Manage cows'**
  String get manageCows;

  /// No description provided for @addCow.
  ///
  /// In en, this message translates to:
  /// **'Add cow'**
  String get addCow;

  /// No description provided for @createCow.
  ///
  /// In en, this message translates to:
  /// **'Create cow'**
  String get createCow;

  /// No description provided for @includeArchived.
  ///
  /// In en, this message translates to:
  /// **'Include archived'**
  String get includeArchived;

  /// No description provided for @noCows.
  ///
  /// In en, this message translates to:
  /// **'No cows yet.'**
  String get noCows;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @tagNumber.
  ///
  /// In en, this message translates to:
  /// **'Tag number'**
  String get tagNumber;

  /// No description provided for @cowName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cowName;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (YYYY-MM-DD)'**
  String get dateOfBirthHint;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'Age (years)'**
  String get ageYears;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @tagAutoGenerated.
  ///
  /// In en, this message translates to:
  /// **'Tag number is generated automatically after create.'**
  String get tagAutoGenerated;

  /// No description provided for @cowImage.
  ///
  /// In en, this message translates to:
  /// **'Cow image'**
  String get cowImage;

  /// No description provided for @pickCowImage.
  ///
  /// In en, this message translates to:
  /// **'Pick cow image'**
  String get pickCowImage;

  /// No description provided for @cowImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get cowImageUnavailable;

  /// No description provided for @imagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the photo library. You can still save without an image.'**
  String get imagePickFailed;

  /// No description provided for @nameBreedRequired.
  ///
  /// In en, this message translates to:
  /// **'Name and breed are required.'**
  String get nameBreedRequired;

  /// No description provided for @acquiredBy.
  ///
  /// In en, this message translates to:
  /// **'Acquired by'**
  String get acquiredBy;

  /// No description provided for @bornOnFarm.
  ///
  /// In en, this message translates to:
  /// **'Born on farm'**
  String get bornOnFarm;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @purchaseDateHint.
  ///
  /// In en, this message translates to:
  /// **'Purchase date (YYYY-MM-DD)'**
  String get purchaseDateHint;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get purchasePrice;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @archiveCow.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveCow;

  /// No description provided for @archiveCowConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive this cow? It will leave the active list.'**
  String get archiveCowConfirm;

  /// No description provided for @milkProduction.
  ///
  /// In en, this message translates to:
  /// **'Milk production'**
  String get milkProduction;

  /// No description provided for @milkNotForMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat-purpose cows do not record milk.'**
  String get milkNotForMeat;

  /// No description provided for @noMilkEntries.
  ///
  /// In en, this message translates to:
  /// **'No milk entries yet.'**
  String get noMilkEntries;

  /// No description provided for @addMilk.
  ///
  /// In en, this message translates to:
  /// **'Add milk entry'**
  String get addMilk;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @noFeedingEntries.
  ///
  /// In en, this message translates to:
  /// **'No feeding entries yet.'**
  String get noFeedingEntries;

  /// No description provided for @addFeeding.
  ///
  /// In en, this message translates to:
  /// **'Add feeding'**
  String get addFeeding;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @feedName.
  ///
  /// In en, this message translates to:
  /// **'Feed name'**
  String get feedName;

  /// No description provided for @archivedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This cow is archived and cannot be modified.'**
  String get archivedReadOnly;

  /// No description provided for @poultryTitle.
  ///
  /// In en, this message translates to:
  /// **'Poultry'**
  String get poultryTitle;

  /// No description provided for @managePoultry.
  ///
  /// In en, this message translates to:
  /// **'Manage poultry'**
  String get managePoultry;

  /// No description provided for @addPoultryGroup.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get addPoultryGroup;

  /// No description provided for @createPoultryGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createPoultryGroup;

  /// No description provided for @noPoultryGroups.
  ///
  /// In en, this message translates to:
  /// **'No poultry groups yet.'**
  String get noPoultryGroups;

  /// No description provided for @poultryGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get poultryGroupName;

  /// No description provided for @poultryType.
  ///
  /// In en, this message translates to:
  /// **'Poultry type'**
  String get poultryType;

  /// No description provided for @birdCount.
  ///
  /// In en, this message translates to:
  /// **'Bird count'**
  String get birdCount;

  /// No description provided for @birds.
  ///
  /// In en, this message translates to:
  /// **'birds'**
  String get birds;

  /// No description provided for @dateAcquiredHint.
  ///
  /// In en, this message translates to:
  /// **'Date acquired (YYYY-MM-DD)'**
  String get dateAcquiredHint;

  /// No description provided for @archivePoultryGroup.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archivePoultryGroup;

  /// No description provided for @archivePoultryGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive this poultry group? It will leave the active list.'**
  String get archivePoultryGroupConfirm;

  /// No description provided for @eggProduction.
  ///
  /// In en, this message translates to:
  /// **'Egg production'**
  String get eggProduction;

  /// No description provided for @eggsNotForBroiler.
  ///
  /// In en, this message translates to:
  /// **'Broiler groups do not record egg production.'**
  String get eggsNotForBroiler;

  /// No description provided for @noEggEntries.
  ///
  /// In en, this message translates to:
  /// **'No egg entries yet.'**
  String get noEggEntries;

  /// No description provided for @addEgg.
  ///
  /// In en, this message translates to:
  /// **'Add egg entry'**
  String get addEgg;

  /// No description provided for @poultryArchivedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This poultry group is archived and cannot be modified.'**
  String get poultryArchivedReadOnly;

  /// No description provided for @cropsTitle.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get cropsTitle;

  /// No description provided for @manageCrops.
  ///
  /// In en, this message translates to:
  /// **'Manage crops'**
  String get manageCrops;

  /// No description provided for @cropNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop names'**
  String get cropNamesTitle;

  /// No description provided for @addCropName.
  ///
  /// In en, this message translates to:
  /// **'Add crop name'**
  String get addCropName;

  /// No description provided for @createCropName.
  ///
  /// In en, this message translates to:
  /// **'Create crop name'**
  String get createCropName;

  /// No description provided for @noCropNames.
  ///
  /// In en, this message translates to:
  /// **'No crop names yet.'**
  String get noCropNames;

  /// No description provided for @noActiveCropNames.
  ///
  /// In en, this message translates to:
  /// **'No active crop names yet. Add a crop name first.'**
  String get noActiveCropNames;

  /// No description provided for @cropNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop name'**
  String get cropNameLabel;

  /// No description provided for @cropLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get cropLabel;

  /// No description provided for @archiveCropName.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveCropName;

  /// No description provided for @archiveCropNameConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive this crop name? It will leave the active catalog.'**
  String get archiveCropNameConfirm;

  /// No description provided for @cropNameArchivedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This crop name is archived and cannot be modified.'**
  String get cropNameArchivedReadOnly;

  /// No description provided for @addCropCycle.
  ///
  /// In en, this message translates to:
  /// **'Add cycle'**
  String get addCropCycle;

  /// No description provided for @createCropCycle.
  ///
  /// In en, this message translates to:
  /// **'Create cycle'**
  String get createCropCycle;

  /// No description provided for @noCropCycles.
  ///
  /// In en, this message translates to:
  /// **'No crop cycles yet.'**
  String get noCropCycles;

  /// No description provided for @plantedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Planted'**
  String get plantedPrefix;

  /// No description provided for @plantedAtHint.
  ///
  /// In en, this message translates to:
  /// **'Planted at (YYYY-MM-DD)'**
  String get plantedAtHint;

  /// No description provided for @expectedHarvestHint.
  ///
  /// In en, this message translates to:
  /// **'Expected harvest (YYYY-MM-DD)'**
  String get expectedHarvestHint;

  /// No description provided for @plotName.
  ///
  /// In en, this message translates to:
  /// **'Plot name'**
  String get plotName;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @archiveCropCycle.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveCropCycle;

  /// No description provided for @archiveCropCycleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive this crop cycle? It will leave the active list.'**
  String get archiveCropCycleConfirm;

  /// No description provided for @cropCycleArchivedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This crop cycle is archived and cannot be modified.'**
  String get cropCycleArchivedReadOnly;

  /// No description provided for @cycleSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get cycleSummary;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get totalExpenses;

  /// No description provided for @totalSaleIncome.
  ///
  /// In en, this message translates to:
  /// **'Sale income'**
  String get totalSaleIncome;

  /// No description provided for @cycleResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get cycleResult;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet.'**
  String get noExpenses;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @spentAtHint.
  ///
  /// In en, this message translates to:
  /// **'Spent at (YYYY-MM-DD)'**
  String get spentAtHint;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @expenseLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get expenseLabour;

  /// No description provided for @expenseFertilizers.
  ///
  /// In en, this message translates to:
  /// **'Fertilizers'**
  String get expenseFertilizers;

  /// No description provided for @expensePesticides.
  ///
  /// In en, this message translates to:
  /// **'Pesticides and chemicals'**
  String get expensePesticides;

  /// No description provided for @expenseSeeds.
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get expenseSeeds;

  /// No description provided for @expenseIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get expenseIrrigation;

  /// No description provided for @expenseEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get expenseEquipment;

  /// No description provided for @expenseOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseOther;

  /// No description provided for @harvests.
  ///
  /// In en, this message translates to:
  /// **'Harvests'**
  String get harvests;

  /// No description provided for @noHarvests.
  ///
  /// In en, this message translates to:
  /// **'No harvests yet.'**
  String get noHarvests;

  /// No description provided for @addHarvest.
  ///
  /// In en, this message translates to:
  /// **'Add harvest'**
  String get addHarvest;

  /// No description provided for @harvestedAtHint.
  ///
  /// In en, this message translates to:
  /// **'Harvested at (YYYY-MM-DD)'**
  String get harvestedAtHint;

  /// No description provided for @saleAmount.
  ///
  /// In en, this message translates to:
  /// **'sale'**
  String get saleAmount;

  /// No description provided for @saleAmountOptional.
  ///
  /// In en, this message translates to:
  /// **'Sale amount (optional)'**
  String get saleAmountOptional;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTitle;

  /// No description provided for @manageInventory.
  ///
  /// In en, this message translates to:
  /// **'Manage inventory'**
  String get manageInventory;

  /// No description provided for @addInventoryItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addInventoryItem;

  /// No description provided for @createInventoryItem.
  ///
  /// In en, this message translates to:
  /// **'Create item'**
  String get createInventoryItem;

  /// No description provided for @noInventoryItems.
  ///
  /// In en, this message translates to:
  /// **'No inventory items yet.'**
  String get noInventoryItems;

  /// No description provided for @inventoryItemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get inventoryItemName;

  /// No description provided for @inventoryCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get inventoryCategory;

  /// No description provided for @inventoryFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get inventoryFeed;

  /// No description provided for @inventoryFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get inventoryFertilizer;

  /// No description provided for @inventoryPesticide.
  ///
  /// In en, this message translates to:
  /// **'Pesticide'**
  String get inventoryPesticide;

  /// No description provided for @inventorySeed.
  ///
  /// In en, this message translates to:
  /// **'Seed'**
  String get inventorySeed;

  /// No description provided for @inventoryMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get inventoryMedicine;

  /// No description provided for @inventoryEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get inventoryEquipment;

  /// No description provided for @inventoryFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get inventoryFuel;

  /// No description provided for @inventoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get inventoryOther;

  /// No description provided for @archiveInventoryItem.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveInventoryItem;

  /// No description provided for @archiveInventoryItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive this inventory item? It will leave the active list.'**
  String get archiveInventoryItemConfirm;

  /// No description provided for @inventoryArchivedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This inventory item is archived and cannot be modified.'**
  String get inventoryArchivedReadOnly;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get totalPrice;

  /// No description provided for @stockUpdates.
  ///
  /// In en, this message translates to:
  /// **'Stock updates'**
  String get stockUpdates;

  /// No description provided for @noStockUpdates.
  ///
  /// In en, this message translates to:
  /// **'No stock updates yet.'**
  String get noStockUpdates;

  /// No description provided for @addStockUpdate.
  ///
  /// In en, this message translates to:
  /// **'Add stock update'**
  String get addStockUpdate;

  /// No description provided for @occurredAtHint.
  ///
  /// In en, this message translates to:
  /// **'Occurred at (YYYY-MM-DD)'**
  String get occurredAtHint;

  /// No description provided for @stockChangeType.
  ///
  /// In en, this message translates to:
  /// **'Change type'**
  String get stockChangeType;

  /// No description provided for @stockAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get stockAdd;

  /// No description provided for @stockUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get stockUse;

  /// No description provided for @quantityChange.
  ///
  /// In en, this message translates to:
  /// **'Quantity change'**
  String get quantityChange;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Income & expenses'**
  String get ledgerTitle;

  /// No description provided for @manageLedger.
  ///
  /// In en, this message translates to:
  /// **'Manage income & expenses'**
  String get manageLedger;

  /// No description provided for @addLedgerEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addLedgerEntry;

  /// No description provided for @createLedgerEntry.
  ///
  /// In en, this message translates to:
  /// **'Create entry'**
  String get createLedgerEntry;

  /// No description provided for @noLedgerEntries.
  ///
  /// In en, this message translates to:
  /// **'No ledger entries in this range.'**
  String get noLedgerEntries;

  /// No description provided for @ledgerEntryType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get ledgerEntryType;

  /// No description provided for @ledgerIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get ledgerIncome;

  /// No description provided for @ledgerExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get ledgerExpense;

  /// No description provided for @ledgerCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ledgerCategory;

  /// No description provided for @ledgerLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get ledgerLabour;

  /// No description provided for @ledgerFeedOrSupplies.
  ///
  /// In en, this message translates to:
  /// **'Feed or supplies'**
  String get ledgerFeedOrSupplies;

  /// No description provided for @ledgerUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get ledgerUtilities;

  /// No description provided for @ledgerTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get ledgerTransport;

  /// No description provided for @ledgerEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get ledgerEquipment;

  /// No description provided for @ledgerLivestockSale.
  ///
  /// In en, this message translates to:
  /// **'Livestock sale'**
  String get ledgerLivestockSale;

  /// No description provided for @ledgerProductSale.
  ///
  /// In en, this message translates to:
  /// **'Product sale'**
  String get ledgerProductSale;

  /// No description provided for @ledgerSubsidy.
  ///
  /// In en, this message translates to:
  /// **'Subsidy'**
  String get ledgerSubsidy;

  /// No description provided for @ledgerOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ledgerOther;

  /// No description provided for @unitOptional.
  ///
  /// In en, this message translates to:
  /// **'Unit (optional)'**
  String get unitOptional;

  /// No description provided for @archiveLedgerEntry.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveLedgerEntry;

  /// No description provided for @archiveLedgerEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive this ledger entry? It will leave the active list and totals.'**
  String get archiveLedgerEntryConfirm;

  /// No description provided for @ledgerArchivedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This ledger entry is archived and cannot be modified.'**
  String get ledgerArchivedReadOnly;

  /// No description provided for @ledgerCropGuidance.
  ///
  /// In en, this message translates to:
  /// **'Crop-cycle costs belong in Crops, not this general ledger.'**
  String get ledgerCropGuidance;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'From (YYYY-MM-DD)'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'To (YYYY-MM-DD)'**
  String get dateTo;

  /// No description provided for @applyDateRange.
  ///
  /// In en, this message translates to:
  /// **'Apply date range'**
  String get applyDateRange;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get totalIncome;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
