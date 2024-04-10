import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassfy_flutter/glassfy_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nafp/log.dart';
import 'package:nafp/models/plan.dart';
import 'package:nafp/models/pocketbase/blogpost.dart';
import 'package:nafp/screens/dashboard.dart';
import 'package:nafp/screens/feed/post.dart';
import 'package:nafp/screens/meals/plan.dart';
import 'package:nafp/screens/settings/settings.dart';
import 'package:nafp/services/database.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Gemini.init(apiKey: const String.fromEnvironment('GEMINI_API_KEY'));

  await initDatabases();

  try {
    logger.i("Initializing Glassfy");
    await Glassfy.initialize('821feb96c6024f2b9db92964b6726cda',
        watcherMode: false);
    logger.i("Glassfy initialized");
  } catch (e) {
    logger.w("Glassfy failed to initialize: $e");
  }

  off.OpenFoodAPIConfiguration.userAgent = off.UserAgent(
      name: 'dietly-2.0.0-mobile', url: 'https://chancesoftwarellc.com');
  off.OpenFoodAPIConfiguration.globalCountry = off.OpenFoodFactsCountry.USA;
  off.OpenFoodAPIConfiguration.globalLanguages = <off.OpenFoodFactsLanguage>[
    off.OpenFoodFactsLanguage.ENGLISH
  ];

  runApp(const MyApp());
}

// GoRouter configuration
final _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const Dashboard(),
    ),
    GoRoute(
      name: "settings",
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      name: "post",
      path: "/post",
      builder: (context, state) => Post(
        post: state.extra as BlogPost,
      ),
    ),
    GoRoute(
      name: "plan",
      path: "/meals/plan",
      builder: (context, state) => PlanPage(
        plan: state.extra as Plan,
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        /* dark theme settings */
      ),
    ));
  }
}

extension DarkMode on BuildContext {
  /// is dark mode currently enabled?
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}
