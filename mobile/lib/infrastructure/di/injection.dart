import 'package:get_it/get_it.dart';
import 'package:mobile/data/datasources/auth/auth_local_datasource.dart';
import 'package:mobile/data/datasources/auth/auth_local_datasource_impl.dart';
import 'package:mobile/data/datasources/auth/auth_remote_datasource.dart';
import 'package:mobile/data/datasources/auth/auth_remote_datasource_impl.dart';
import 'package:mobile/data/datasources/common/api_client.dart';
import 'package:mobile/data/datasources/cow/cows_datasource.dart';
import 'package:mobile/data/datasources/cow/cows_datasource_impl.dart';
import 'package:mobile/data/datasources/dashboard/dashboard_datasource.dart';
import 'package:mobile/data/datasources/dashboard/dashboard_datasource_impl.dart';
import 'package:mobile/data/datasources/crop/crops_datasource.dart';
import 'package:mobile/data/datasources/crop/crops_datasource_impl.dart';
import 'package:mobile/data/datasources/inventory/inventory_datasource.dart';
import 'package:mobile/data/datasources/inventory/inventory_datasource_impl.dart';
import 'package:mobile/data/datasources/ledger/ledger_datasource.dart';
import 'package:mobile/data/datasources/ledger/ledger_datasource_impl.dart';
import 'package:mobile/data/datasources/poultry/poultry_datasource.dart';
import 'package:mobile/data/datasources/poultry/poultry_datasource_impl.dart';
import 'package:mobile/data/repositories/auth/auth_repository_impl.dart';
import 'package:mobile/data/repositories/cow/cows_repository_impl.dart';
import 'package:mobile/data/repositories/dashboard/dashboard_repository_impl.dart';
import 'package:mobile/data/repositories/crop/crops_repository_impl.dart';
import 'package:mobile/data/repositories/inventory/inventory_repository_impl.dart';
import 'package:mobile/data/repositories/ledger/ledger_repository_impl.dart';
import 'package:mobile/data/repositories/poultry/poultry_repository_impl.dart';
import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/domain/repositories/cow/cows_repository.dart';
import 'package:mobile/domain/repositories/dashboard/dashboard_repository.dart';
import 'package:mobile/domain/repositories/crop/crops_repository.dart';
import 'package:mobile/domain/repositories/inventory/inventory_repository.dart';
import 'package:mobile/domain/repositories/ledger/ledger_repository.dart';
import 'package:mobile/domain/repositories/poultry/poultry_repository.dart';
import 'package:mobile/domain/usecases/auth/auth_usecases.dart';
import 'package:mobile/domain/usecases/cow/cows_usecases.dart';
import 'package:mobile/domain/usecases/dashboard/dashboard_usecases.dart';
import 'package:mobile/domain/usecases/crop/crops_usecases.dart';
import 'package:mobile/domain/usecases/inventory/inventory_usecases.dart';
import 'package:mobile/domain/usecases/ledger/ledger_usecases.dart';
import 'package:mobile/domain/usecases/poultry/poultry_usecases.dart';
import 'package:mobile/presentation/locale/locale_cubit.dart';
import 'package:mobile/presentation/session/session_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final authLocalDatasource = AuthLocalDatasourceImpl();
  final apiClient = ApiClient(authLocalDatasource);
  final authRemoteDatasource = AuthRemoteDatasourceImpl(apiClient);
  final cowsDatasource = CowsDatasourceImpl(apiClient);
  final poultryDatasource = PoultryDatasourceImpl(apiClient);
  final cropsDatasource = CropsDatasourceImpl(apiClient);
  final inventoryDatasource = InventoryDatasourceImpl(apiClient);
  final ledgerDatasource = LedgerDatasourceImpl(apiClient);
  final dashboardDatasource = DashboardDatasourceImpl(apiClient);
  final authRepo = AuthRepositoryImpl(authRemoteDatasource, authLocalDatasource);
  final cowsRepo = CowsRepositoryImpl(cowsDatasource);
  final poultryRepo = PoultryRepositoryImpl(poultryDatasource);
  final cropsRepo = CropsRepositoryImpl(cropsDatasource);
  final inventoryRepo = InventoryRepositoryImpl(inventoryDatasource);
  final ledgerRepo = LedgerRepositoryImpl(ledgerDatasource);
  final dashboardRepo = DashboardRepositoryImpl(dashboardDatasource);

  getIt
    ..registerSingleton<AuthLocalDatasource>(authLocalDatasource)
    ..registerSingleton<ApiClient>(apiClient)
    ..registerSingleton<AuthRemoteDatasource>(authRemoteDatasource)
    ..registerSingleton<CowsDatasource>(cowsDatasource)
    ..registerSingleton<PoultryDatasource>(poultryDatasource)
    ..registerSingleton<CropsDatasource>(cropsDatasource)
    ..registerSingleton<InventoryDatasource>(inventoryDatasource)
    ..registerSingleton<LedgerDatasource>(ledgerDatasource)
    ..registerSingleton<DashboardDatasource>(dashboardDatasource)
    ..registerSingleton<AuthRepository>(authRepo)
    ..registerSingleton<CowsRepository>(cowsRepo)
    ..registerSingleton<PoultryRepository>(poultryRepo)
    ..registerSingleton<CropsRepository>(cropsRepo)
    ..registerSingleton<InventoryRepository>(inventoryRepo)
    ..registerSingleton<LedgerRepository>(ledgerRepo)
    ..registerSingleton<DashboardRepository>(dashboardRepo)
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
    ..registerLazySingleton(() => UpdateEggProduction(poultryRepo))
    ..registerLazySingleton(() => DeleteEggProduction(poultryRepo))
    ..registerLazySingleton(() => ListPoultryFeedings(poultryRepo))
    ..registerLazySingleton(() => AddPoultryFeeding(poultryRepo))
    ..registerLazySingleton(() => UpdatePoultryFeeding(poultryRepo))
    ..registerLazySingleton(() => DeletePoultryFeeding(poultryRepo))
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
    ..registerLazySingleton(() => UpdateCropExpense(cropsRepo))
    ..registerLazySingleton(() => DeleteCropExpense(cropsRepo))
    ..registerLazySingleton(() => UpdateHarvest(cropsRepo))
    ..registerLazySingleton(() => DeleteHarvest(cropsRepo))
    ..registerLazySingleton(() => ListInventoryItems(inventoryRepo))
    ..registerLazySingleton(() => GetInventoryItem(inventoryRepo))
    ..registerLazySingleton(() => CreateInventoryItem(inventoryRepo))
    ..registerLazySingleton(() => UpdateInventoryItem(inventoryRepo))
    ..registerLazySingleton(() => ArchiveInventoryItem(inventoryRepo))
    ..registerLazySingleton(() => ListStockUpdates(inventoryRepo))
    ..registerLazySingleton(() => AddStockUpdate(inventoryRepo))
    ..registerLazySingleton(() => ListFertilizerStockUpdates(inventoryRepo))
    ..registerLazySingleton(() => ListLedgerEntries(ledgerRepo))
    ..registerLazySingleton(() => GetLedgerEntry(ledgerRepo))
    ..registerLazySingleton(() => CreateLedgerEntry(ledgerRepo))
    ..registerLazySingleton(() => UpdateLedgerEntry(ledgerRepo))
    ..registerLazySingleton(() => ArchiveLedgerEntry(ledgerRepo))
    ..registerLazySingleton(() => GetPeriodTotals(ledgerRepo))
    ..registerLazySingleton(() => GetLedgerSeries(ledgerRepo))
    ..registerLazySingleton(() => GetDashboardAggregates(dashboardRepo))
    ..registerLazySingleton(() => LocaleCubit())
    ..registerLazySingleton(
      () => SessionCubit(getIt<IsSignedIn>(), getIt<SignOut>()),
    );
}
