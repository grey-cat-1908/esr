import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:esr_app/pages/home_page.dart';
import 'package:esr_app/pages/auth_page.dart';

final goRouterProvider = Provider(
  (ref) => GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, __) => MaterialPage(child: HomePage(key: UniqueKey())),
        // pageBuilder: (_, __) => MaterialPage(child: HomePage(key: UniqueKey())),
      ),
        GoRoute(
          path: '/login',
          pageBuilder: (_, __) => MaterialPage(child: AuthPage(key: UniqueKey())),
          // pageBuilder: (_, __) => MaterialPage(child: HomePage(key: UniqueKey())),
        ),
    ],
    redirect: (context, state) {
      final Box boxLogin = Hive.box("login");

      if (!boxLogin.containsKey("save_time") || (boxLogin.get("save_time").add(const Duration(days: 3))).isBefore(DateTime.now())) {
        if (state.path != '/login') return '/login';
      } else {
        if (state.path == '/login') return '/';
      }
      return null;
    }
  ),
);