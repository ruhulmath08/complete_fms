import 'package:mobile/data/datasources/token_store.dart';
import 'package:mobile/data/sign_in/data_source/sign_in_data_source.dart';
import 'package:mobile/data/sign_in/mapper/sign_in_mapper.dart';
import 'package:mobile/domain/sign_in/entities/sign_in_entity.dart';
import 'package:mobile/domain/sign_in/repository/sign_in_repository.dart';

class SignInRepositoryImpl implements SignInRepository {
  SignInRepositoryImpl({
    required this.dataSource,
    required this.tokenStore,
  });

  final SignInDataSource dataSource;
  final TokenStore tokenStore;

  @override
  Future<SignInEntity> signIn({
    required String email,
    required String password,
  }) async {
    final model = await dataSource.signIn(email, password);
    await tokenStore.save(
      access: model.accessToken,
      refresh: model.refreshToken,
    );
    return SignInMapper.mapModelToEntity(model);
  }
}
