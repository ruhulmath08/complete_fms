import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/domain/usecases/auth_usecases.dart';
import 'package:mobile/presentation/session/session_cubit.dart';

class _MockIsSignedIn extends Mock implements IsSignedIn {}

class _MockSignOut extends Mock implements SignOut {}

void main() {
  late _MockIsSignedIn isSignedIn;
  late _MockSignOut signOut;

  setUp(() {
    isSignedIn = _MockIsSignedIn();
    signOut = _MockSignOut();
  });

  blocTest<SessionCubit, bool>(
    'bootstrap emits signed-in when repository reports session',
    build: () {
      when(() => isSignedIn()).thenAnswer((_) async => true);
      return SessionCubit(isSignedIn, signOut);
    },
    act: (cubit) => cubit.bootstrap(),
    expect: () => [true],
  );

  blocTest<SessionCubit, bool>(
    'signOut clears session state',
    build: () {
      when(() => signOut()).thenAnswer((_) async {});
      return SessionCubit(isSignedIn, signOut)..markSignedIn();
    },
    act: (cubit) => cubit.signOut(),
    expect: () => [false],
    verify: (_) {
      verify(() => signOut()).called(1);
    },
  );
}
