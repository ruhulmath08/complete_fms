import 'package:get_it/get_it.dart';
import '../../data/datasources/api_client.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/datasources/cows_api.dart';
import '../../data/datasources/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cows_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cows_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/cows_usecases.dart';
import '../../presentation/locale/locale_cubit.dart';
import '../../presentation/session/session_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final tokenStore = TokenStore();
  final apiClient = ApiClient(tokenStore);
  final authApi = AuthApi(apiClient);
  final cowsApi = CowsApi(apiClient);
  final authRepo = AuthRepositoryImpl(authApi, tokenStore);
  final cowsRepo = CowsRepositoryImpl(cowsApi);

  getIt
    ..registerSingleton<TokenStore>(tokenStore)
    ..registerSingleton<ApiClient>(apiClient)
    ..registerSingleton<AuthApi>(authApi)
    ..registerSingleton<CowsApi>(cowsApi)
    ..registerSingleton<AuthRepository>(authRepo)
    ..registerSingleton<CowsRepository>(cowsRepo)
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
    ..registerLazySingleton(() => ListMilkProductions(cowsRepo))
    ..registerLazySingleton(() => AddMilkProduction(cowsRepo))
    ..registerLazySingleton(() => ListCowFeedings(cowsRepo))
    ..registerLazySingleton(() => AddCowFeeding(cowsRepo))
    ..registerLazySingleton(() => LocaleCubit())
    ..registerLazySingleton(
      () => SessionCubit(getIt<IsSignedIn>(), getIt<SignOut>()),
    );
}
