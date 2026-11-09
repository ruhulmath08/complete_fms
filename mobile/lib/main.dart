import 'package:flutter/material.dart';
import 'app.dart';
import 'infrastructure/di/injection.dart';
import 'presentation/session/session_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<SessionCubit>().bootstrap();
  runApp(FarmManagerApp());
}
