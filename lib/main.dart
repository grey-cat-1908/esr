import 'package:flutter/material.dart';
import 'package:esr_app/utils/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await _initHive();
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ЕСР',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A3763),
            brightness: Brightness.light
        ),
        useMaterial3: true
      ),
      routeInformationParser:
        ref.read(goRouterProvider).routeInformationParser,
      routerDelegate: ref.read(goRouterProvider).routerDelegate,
      routeInformationProvider:
        ref.read(goRouterProvider).routeInformationProvider,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResponsiveWrapper.builder(
        ClampingScrollWrapper.builder(context, child!),
        breakpoints: const [
          ResponsiveBreakpoint.resize(350, name: MOBILE),
          ResponsiveBreakpoint.resize(600, name: TABLET),
          ResponsiveBreakpoint.resize(1700, name: 'XL'),
        ],
        background: Container(color: Theme.of(context).colorScheme.surface),
      ),
      // home: const MyHomePage(title: 'ЕСР'),
    );
  }
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  await Hive.openBox("login");
}