import 'package:mobile/domain/failures.dart';
import 'package:mobile/domain/result.dart';

/// Runs an API/local async call and converts thrown [Failure]s into [Result].
Future<Result<T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return Success(await call());
  } on Failure catch (failure) {
    return Err(failure);
  } catch (_) {
    return Err(
      Failure(
        code: 'UNEXPECTED_ERROR',
        message: 'Something went wrong, try again later.',
      ),
    );
  }
}
