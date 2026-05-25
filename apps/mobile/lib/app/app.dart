import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/app/providers.dart';
import 'package:mquiz/app/router.dart';
import 'package:mquiz/core/theme/app_theme.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';

class MquizApp extends StatelessWidget {
  const MquizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: _RouterScope(),
    );
  }
}

/// Separate widget so GoRouter can read the auth state from context.
class _RouterScope extends StatefulWidget {
  @override
  State<_RouterScope> createState() => _RouterScopeState();
}

class _RouterScopeState extends State<_RouterScope> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Trigger initial auth check
    context.read<AuthCubit>().checkAuth();
    _router = AppRouter.create(context.read<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild router on auth state changes so redirects fire.
    return BlocListener<AuthCubit, AuthState>(
      listener: (ctx, state) => _router.refresh(),
      child: MaterialApp.router(
        title: 'mQuiz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
