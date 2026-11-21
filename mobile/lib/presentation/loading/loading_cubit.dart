import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/data/network/api_activity.dart';

/// True while at least one tracked API write is in progress.
class LoadingCubit extends Cubit<bool> {
  LoadingCubit(ApiActivity activity) : super(activity.count > 0) {
    _subscription = activity.stream.listen((count) => emit(count > 0));
  }

  late final StreamSubscription<int> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
