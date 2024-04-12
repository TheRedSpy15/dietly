import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/providers/providers.dart';
import 'package:nafp/screens/charts/charts.dart';
import 'package:nafp/screens/feed/feed.dart';
import 'package:nafp/screens/meals/meals.dart';
import 'package:nafp/screens/points/points.dart';
import 'package:nafp/screens/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentPageIndex = StateProvider<int>((ref) => 0);
final didInitRateApp = StateProvider<bool>((ref) => false);

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharedPreferences.getInstance().then((prefs) => {
            ref.read(proteinFocusProvider.notifier).state =
                prefs.getBool('defaultProteinFocus') ?? false,
            ref.read(hourlyWaterProvider.notifier).state =
                prefs.getBool('hourlyWater') ?? false,
          });
    });

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          ref.read(currentPageIndex.notifier).state = index;
        },
        selectedIndex: ref.watch(currentPageIndex),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(CupertinoIcons.news_solid),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.barcode_viewfinder),
            label: 'Points',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.archivebox_fill),
            label: 'Pantry',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.chart_bar_square_fill),
            label: 'Charts',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.settings_solid),
            label: 'Settings',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          alignment: Alignment.center,
          child: const Feed(),
        ),
        Container(
          alignment: Alignment.center,
          child: const Points(),
        ),
        Container(
          alignment: Alignment.center,
          child: const Meals(),
        ),
        Container(
          alignment: Alignment.center,
          child: const Charts(),
        ),
        Container(
          alignment: Alignment.center,
          child: const SettingsScreen(),
        ),
      ][ref.watch(currentPageIndex)],
    );
  }
}
