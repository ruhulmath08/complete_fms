import 'package:get_it/get_it.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/datasources/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../presentation/locale/locale_cubit.dart';
import '../../presentation/session/session_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final tokenStore = TokenStore();
  final api = AuthApi(tokenStore);
  final repo = AuthRepositoryImpl(api, tokenStore);

  getIt
    ..registerSingleton<TokenStore>(tokenStore)
    ..registerSingleton<AuthApi>(api)
    ..registerSingleton<AuthRepository>(repo)
    ..registerLazySingleton(() => SignUp(repo))
    ..registerLazySingleton(() => SignIn(repo))
    ..registerLazySingleton(() => SignOut(repo))
    ..registerLazySingleton(() => GetProfile(repo))
    ..registerLazySingleton(() => UpdateProfile(repo))
    ..registerLazySingleton(() => GetFarmSettings(repo))
    ..registerLazySingleton(() => UpdateFarmSettings(repo))
    ..registerLazySingleton(() => IsSignedIn(repo))
    ..registerLazySingleton(() => LocaleCubit())
    ..registerLazySingleton(
      () => SessionCubit(getIt<IsSignedIn>(), getIt<SignOut>()),
    );
}
