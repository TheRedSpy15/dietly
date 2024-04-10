import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/log.dart';
import 'package:nafp/providers/providers.dart';
import 'package:nafp/screens/charts/charts.dart';
import 'package:nafp/screens/feed/feed.dart';
import 'package:nafp/screens/meals/meals.dart';
import 'package:nafp/screens/points/points.dart';
import 'package:nafp/screens/settings/settings.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ratings.dart';

final currentPageIndex = StateProvider<int>((ref) => 0);
final didInitRateApp = StateProvider<bool>((ref) => false);

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ratingCheck(context, ref.read(didInitRateApp));

      // load settings
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

  void ratingCheck(BuildContext context, bool didInitRateMyApp) {
    if (!didInitRateMyApp) {
      rateMyApp.init().then((_) {
        logger.i('Initialized rate my app');
        if (rateMyApp.shouldOpenDialog) {
          // Or if you prefer to show a star rating bar (powered by `flutter_rating_bar`) :
          rateMyApp.showStarRateDialog(
            context,
            title: 'Leave a review', // The dialog title.
            message:
                'Enjoying Dietly? Then take a little bit of your time to leave a rating', // The dialog message.
            // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
            actionsBuilder: (context, stars) {
              // Triggered when the user updates the star rating.
              return [
                // Return a list of actions (that will be shown at the bottom of the dialog).
                OutlinedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    logger.i(
                        'Thanks for the ${stars == null ? '0' : stars.round().toString()} star(s) !');
                    // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
                    // This allows to mimic the behavior of the default "Rate" button. See "Advanced > Broadcasting events" for more information :
                    if (stars != null) {
                      if (stars >= 4) {
                        rateMyApp.launchStore();
                      }
                    }

                    rateMyApp
                        .callEvent(RateMyAppEventType.rateButtonPressed)
                        .then((value) => {
                              Navigator.pop<RateMyAppDialogButton>(
                                  context, RateMyAppDialogButton.rate)
                            });
                  },
                ),
              ];
            },
            ignoreNativeDialog: Platform
                .isAndroid, // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
            dialogStyle: const DialogStyle(
              // Custom dialog styles.
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 20),
            ),
            starRatingOptions:
                const StarRatingOptions(), // Custom star bar rating options.
            onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
                .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
          );
        }
        didInitRateMyApp = true;
      });
    }
  }
}
