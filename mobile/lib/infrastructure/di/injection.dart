import 'package:get_it/get_it.dart';
import '../../data/datasources/api_client.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/datasources/cows_api.dart';
import '../../data/datasources/crops_api.dart';
import '../../data/datasources/inventory_api.dart';
import '../../data/datasources/ledger_api.dart';
import '../../data/datasources/poultry_api.dart';
import '../../data/datasources/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cows_repository_impl.dart';
import '../../data/repositories/crops_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/ledger_repository_impl.dart';
import '../../data/repositories/poultry_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cows_repository.dart';
import '../../domain/repositories/crops_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../../domain/repositories/poultry_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/cows_usecases.dart';
import '../../domain/usecases/crops_usecases.dart';
import '../../domain/usecases/inventory_usecases.dart';
import '../../domain/usecases/ledger_usecases.dart';
import '../../domain/usecases/poultry_usecases.dart';
import '../../presentation/locale/locale_cubit.dart';
import '../../presentation/session/session_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final tokenStore = TokenStore();
  final apiClient = ApiClient(tokenStore);
  final authApi = AuthApi(apiClient);
  final cowsApi = CowsApi(apiClient);
  final poultryApi = PoultryApi(apiClient);
  final cropsApi = CropsApi(apiClient);
  final inventoryApi = InventoryApi(apiClient);
  final ledgerApi = LedgerApi(apiClient);
  final authRepo = AuthRepositoryImpl(authApi, tokenStore);
  final cowsRepo = CowsRepositoryImpl(cowsApi);
  final poultryRepo = PoultryRepositoryImpl(poultryApi);
  final cropsRepo = CropsRepositoryImpl(cropsApi);
  final inventoryRepo = InventoryRepositoryImpl(inventoryApi);
  final ledgerRepo = LedgerRepositoryImpl(ledgerApi);

  getIt
    ..registerSingleton<TokenStore>(tokenStore)
    ..registerSingleton<ApiClient>(apiClient)
    ..registerSingleton<AuthApi>(authApi)
    ..registerSingleton<CowsApi>(cowsApi)
    ..registerSingleton<PoultryApi>(poultryApi)
    ..registerSingleton<CropsApi>(cropsApi)
    ..registerSingleton<InventoryApi>(inventoryApi)
    ..registerSingleton<LedgerApi>(ledgerApi)
    ..registerSingleton<AuthRepository>(authRepo)
    ..registerSingleton<CowsRepository>(cowsRepo)
    ..registerSingleton<PoultryRepository>(poultryRepo)
    ..registerSingleton<CropsRepository>(cropsRepo)
    ..registerSingleton<InventoryRepository>(inventoryRepo)
    ..registerSingleton<LedgerRepository>(ledgerRepo)
    ..registerLazySingleton(() => SignUp(authRepo))
    ..registerLazySingleton(() => SignIn(authRepo))
    ..registerLazySingleton(() => SignOut(authRepo))
    ..registerLazySingleton(() => GetProfile(authRepo))
    ..registerLazySingleton(() => UpdateProfile(authRepo))
    ..registerLazySingleton(() => GetFarmSettings(authRepo))
    ..registerLazySingleton(() => UpdateFarmSettings(authRepo))
    ..registerLazySingleton(() => IsSignedIn(authRepo))
    ..registerLazySingleton(() => ListCows(cowsRepo))
    ..registerLazySingleton(() => GetCow(cowsRepo))
    ..registerLazySingleton(() => CreateCow(cowsRepo))
    ..registerLazySingleton(() => UpdateCow(cowsRepo))
    ..registerLazySingleton(() => ArchiveCow(cowsRepo))
    ..registerLazySingleton(() => UploadCowImage(cowsRepo))
    ..registerLazySingleton(() => GetCowImageBytes(cowsRepo))
    ..registerLazySingleton(() => ListMilkProductions(cowsRepo))
    ..registerLazySingleton(() => AddMilkProduction(cowsRepo))
    ..registerLazySingleton(() => UpdateMilkProduction(cowsRepo))
    ..registerLazySingleton(() => DeleteMilkProduction(cowsRepo))
    ..registerLazySingleton(() => ListCowFeedings(cowsRepo))
    ..registerLazySingleton(() => AddCowFeeding(cowsRepo))
    ..registerLazySingleton(() => UpdateCowFeeding(cowsRepo))
    ..registerLazySingleton(() => DeleteCowFeeding(cowsRepo))
    ..registerLazySingleton(() => ListPoultryGroups(poultryRepo))
    ..registerLazySingleton(() => GetPoultryGroup(poultryRepo))
    ..registerLazySingleton(() => CreatePoultryGroup(poultryRepo))
    ..registerLazySingleton(() => UpdatePoultryGroup(poultryRepo))
    ..registerLazySingleton(() => ArchivePoultryGroup(poultryRepo))
    ..registerLazySingleton(() => ListEggProductions(poultryRepo))
    ..registerLazySingleton(() => AddEggProduction(poultryRepo))
    ..registerLazySingleton(() => ListPoultryFeedings(poultryRepo))
    ..registerLazySingleton(() => AddPoultryFeeding(poultryRepo))
    ..registerLazySingleton(() => ListCropNames(cropsRepo))
    ..registerLazySingleton(() => GetCropName(cropsRepo))
    ..registerLazySingleton(() => CreateCropName(cropsRepo))
    ..registerLazySingleton(() => UpdateCropName(cropsRepo))
    ..registerLazySingleton(() => ArchiveCropName(cropsRepo))
    ..registerLazySingleton(() => ListCropCycles(cropsRepo))
    ..registerLazySingleton(() => GetCropCycle(cropsRepo))
    ..registerLazySingleton(() => CreateCropCycle(cropsRepo))
    ..registerLazySingleton(() => UpdateCropCycle(cropsRepo))
    ..registerLazySingleton(() => ArchiveCropCycle(cropsRepo))
    ..registerLazySingleton(() => GetCropCycleSummary(cropsRepo))
    ..registerLazySingleton(() => ListCropExpenses(cropsRepo))
    ..registerLazySingleton(() => AddCropExpense(cropsRepo))
    ..registerLazySingleton(() => ListHarvests(cropsRepo))
    ..registerLazySingleton(() => AddHarvest(cropsRepo))
    ..registerLazySingleton(() => ListInventoryItems(inventoryRepo))
    ..registerLazySingleton(() => GetInventoryItem(inventoryRepo))
    ..registerLazySingleton(() => CreateInventoryItem(inventoryRepo))
    ..registerLazySingleton(() => UpdateInventoryItem(inventoryRepo))
    ..registerLazySingleton(() => ArchiveInventoryItem(inventoryRepo))
    ..registerLazySingleton(() => ListStockUpdates(inventoryRepo))
    ..registerLazySingleton(() => AddStockUpdate(inventoryRepo))
    ..registerLazySingleton(() => ListLedgerEntries(ledgerRepo))
    ..registerLazySingleton(() => GetLedgerEntry(ledgerRepo))
    ..registerLazySingleton(() => CreateLedgerEntry(ledgerRepo))
    ..registerLazySingleton(() => UpdateLedgerEntry(ledgerRepo))
    ..registerLazySingleton(() => ArchiveLedgerEntry(ledgerRepo))
    ..registerLazySingleton(() => GetPeriodTotals(ledgerRepo))
    ..registerLazySingleton(() => LocaleCubit())
    ..registerLazySingleton(
      () => SessionCubit(getIt<IsSignedIn>(), getIt<SignOut>()),
    );
}
