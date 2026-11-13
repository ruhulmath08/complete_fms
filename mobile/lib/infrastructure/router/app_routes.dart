abstract final class AppRoutes {
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const dashboard = '/dashboard';
  static const cows = '/cows';
  static const cowsNew = '/cows/new';
  static const poultry = '/poultry';
  static const poultryNew = '/poultry/new';
  static const crops = '/crops';
  static const cropNames = '/crops/names';
  static const cropNamesNew = '/crops/names/new';
  static const cropCyclesNew = '/crops/cycles/new';
  static const inventory = '/inventory';
  static const inventoryNew = '/inventory/new';
  static const ledger = '/ledger';
  static const ledgerNew = '/ledger/new';
  static const profile = '/profile';
  static const settings = '/settings';

  static const cowIdParam = 'cowId';
  static const groupIdParam = 'groupId';
  static const cropNameIdParam = 'cropNameId';
  static const cycleIdParam = 'cycleId';
  static const itemIdParam = 'itemId';
  static const entryIdParam = 'entryId';

  static const cowDetail = '/cows/:$cowIdParam';
  static const poultryDetail = '/poultry/:$groupIdParam';
  static const cropNameDetail = '/crops/names/:$cropNameIdParam';
  static const cropCycleDetail = '/crops/cycles/:$cycleIdParam';
  static const inventoryDetail = '/inventory/:$itemIdParam';
  static const ledgerDetail = '/ledger/:$entryIdParam';

  static String cow(String cowId) => '/cows/$cowId';
  static String poultryGroup(String groupId) => '/poultry/$groupId';
  static String cropName(String cropNameId) => '/crops/names/$cropNameId';
  static String cropCycle(String cycleId) => '/crops/cycles/$cycleId';
  static String inventoryItem(String itemId) => '/inventory/$itemId';
  static String ledgerEntry(String entryId) => '/ledger/$entryId';
}
