import 'package:material_ui/material_ui.dart';
import 'package:mobile/app.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/presentation/session/session_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<SessionCubit>().bootstrap();
  runApp(FarmManagerApp());
}
