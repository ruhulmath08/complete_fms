/// HTTP paths for the farm API. Fixed paths are constants. Paths that
/// include an id are built from those constants.
abstract final class ApiEndpoints {
  static const _root = '/api/v1';

  static const signUp = '$_root/auth/signup';
  static const signIn = '$_root/auth/signin';
  static const signOut = '$_root/auth/signout';
  static const refresh = '$_root/auth/refresh';

  static const me = '$_root/me';
  static const profileImage = '$_root/me/profile-image';
  static const farmSettings = '$_root/farm-settings';

  static const cows = '$_root/cows';
  static String cow(String cowId) => '$cows/$cowId';
  static String cowArchive(String cowId) => '${cow(cowId)}/archive';
  static String cowImage(String cowId) => '${cow(cowId)}/image';
  static String cowMilkProductions(String cowId) =>
      '${cow(cowId)}/milk-productions';
  static String cowMilkProduction(String cowId, String milkId) =>
      '${cowMilkProductions(cowId)}/$milkId';
  static String cowFeedings(String cowId) => '${cow(cowId)}/feedings';
  static String cowFeeding(String cowId, String feedingId) =>
      '${cowFeedings(cowId)}/$feedingId';

  static const poultryGroups = '$_root/poultry-groups';
  static String poultryGroup(String groupId) => '$poultryGroups/$groupId';
  static String poultryGroupArchive(String groupId) =>
      '${poultryGroup(groupId)}/archive';
  static String eggProductions(String groupId) =>
      '${poultryGroup(groupId)}/egg-productions';
  static String eggProduction(String groupId, String eggId) =>
      '${eggProductions(groupId)}/$eggId';
  static String poultryFeedings(String groupId) =>
      '${poultryGroup(groupId)}/feedings';
  static String poultryFeeding(String groupId, String feedingId) =>
      '${poultryFeedings(groupId)}/$feedingId';

  static const cropNames = '$_root/crop-names';
  static String cropName(String cropNameId) => '$cropNames/$cropNameId';
  static String cropNameArchive(String cropNameId) =>
      '${cropName(cropNameId)}/archive';

  static const cropCycles = '$_root/crop-cycles';
  static String cropCycle(String cycleId) => '$cropCycles/$cycleId';
  static String cropCycleArchive(String cycleId) =>
      '${cropCycle(cycleId)}/archive';
  static String cropCycleSummary(String cycleId) =>
      '${cropCycle(cycleId)}/summary';
  static String cropExpenses(String cycleId) =>
      '${cropCycle(cycleId)}/expenses';
  static String cropExpense(String cycleId, String expenseId) =>
      '${cropExpenses(cycleId)}/$expenseId';
  static String harvests(String cycleId) => '${cropCycle(cycleId)}/harvests';
  static String harvest(String cycleId, String harvestId) =>
      '${harvests(cycleId)}/$harvestId';

  static const inventoryItems = '$_root/inventory-items';
  static String inventoryItem(String itemId) => '$inventoryItems/$itemId';
  static String inventoryItemArchive(String itemId) =>
      '${inventoryItem(itemId)}/archive';
  static String itemStockUpdates(String itemId) =>
      '${inventoryItem(itemId)}/stock-updates';
  static const inventoryStockUpdates = '$_root/inventory-stock-updates';

  static const ledgerEntries = '$_root/ledger-entries';
  static String ledgerEntry(String entryId) => '$ledgerEntries/$entryId';
  static String ledgerEntryArchive(String entryId) =>
      '${ledgerEntry(entryId)}/archive';
  static const ledgerTotals = '$_root/ledger-entries/totals';
  static const ledgerSeries = '$_root/ledger-entries/series';

  static const dashboardAggregates = '$_root/dashboard/aggregates';
}
