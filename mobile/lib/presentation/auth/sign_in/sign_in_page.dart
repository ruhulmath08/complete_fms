import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/infrastructure/router/app_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/auth/sign_in/bloc/sign_in_bloc.dart';
import 'package:mobile/presentation/auth/sign_in/widgets/password_input_field.dart';
import 'package:mobile/presentation/session/session_cubit.dart';
import 'package:mobile/presentation/shared/widgets/form_field_column.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignInBloc>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<SignInBloc, SignInState>(
      listenWhen: (previous, current) =>
          previous.statusEnum != current.statusEnum &&
          current.statusEnum == SignInStateEnum.success,
      listener: (context, state) {
        context.read<SessionCubit>().markSignedIn();
        context.go(AppRoutes.dashboard);
      },
      buildWhen: (previous, current) =>
          previous.statusEnum != current.statusEnum ||
          previous.errorMessage != current.errorMessage ||
          previous.errorCode != current.errorCode,
      builder: (context, state) {
        final busy = state.statusEnum == SignInStateEnum.loading;
        final errorMessage = state.statusEnum != SignInStateEnum.failed
            ? ''
            : switch (state.errorCode) {
                SignInErrorCode.emptyFields => l10n.fillAllFields,
                SignInErrorCode.invalidEmail => l10n.invalidEmail,
                SignInErrorCode.invalidCredentials => l10n.invalidCredentials,
                _ => state.errorMessage,
              };
        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.signIn,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(l10n.signInSubtitle),
                      if (errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FormFieldColumn(
                        children: [
                          TextField(
                            decoration: InputDecoration(labelText: l10n.email),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => context
                                .read<SignInBloc>()
                                .add(SignInUsernameChange(username: value)),
                          ),
                          PasswordInputField(
                            labelText: l10n.password,
                            onChanged: (value) => context
                                .read<SignInBloc>()
                                .add(SignInPasswordChange(password: value)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: busy
                            ? null
                            : () => context.read<SignInBloc>().add(
                                const SignInSubmitted(),
                              ),
                        child: Text(l10n.signIn),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.signUp),
                        child: Text(l10n.newHere),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
