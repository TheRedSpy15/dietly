import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassfy_flutter/glassfy_flutter.dart';
import 'package:nafp/log.dart';
import 'package:nafp/main.dart';
import 'package:nafp/screens/glassfy/paywallContent.dart';
import 'package:nafp/screens/settings/settingsGroup.dart';
import 'package:nafp/screens/settings/settingsItem.dart';
import 'package:nafp/screens/settings/settingsWidgetUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../providers/providers.dart';
import '../../services/PurchaseApi.dart';
import '../../services/notifications.dart';

final nameProvider = StateProvider<String>((ref) => '');
final pfpProvider = StateProvider<String>((ref) => '');
final targetWeightProvider = StateProvider<String>((ref) => '');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proteinFocus = ref.watch(proteinFocusProvider);
    final hourlyWater = ref.watch(hourlyWaterProvider);
    SharedPreferences.getInstance().then((prefs) => {
          ref.read(proteinFocusProvider.notifier).state =
              prefs.getBool('defaultProteinFocus') ?? false,
          ref.read(hourlyWaterProvider.notifier).state =
              prefs.getBool('hourlyWater') ?? false,
        });
    final isPremium = ref.watch(premiumProvider);

    checkSubscription(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      backgroundColor: context.isDarkMode ? Colors.black : Colors.blueGrey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPremium)
                CustomSettingsGroup(
                  items: [
                    CustomSettingsItem(
                      onTap: () {
                        final ChromeSafariBrowser browser =
                            ChromeSafariBrowser();
                        if (Platform.isAndroid) {
                          // open link
                          browser.open(
                              url: WebUri(
                                  'https://play.google.com/store/account/subscriptions?sku=dietly_pro&package=com.chancesoftwarellc.nafp'));
                        } else if (Platform.isIOS) {
                          browser.open(
                              url: WebUri(
                                  'itms-apps://itunes.apple.com/app/id6449180534'));
                        }
                      },
                      icons: Icons.workspace_premium,
                      iconStyle: IconStyle(
                        iconsColor: Colors.white,
                        withBackground: true,
                        backgroundColor: Colors.orange,
                      ),
                      trailing: const Icon(Icons.open_in_new),
                      title: 'Manage Subscription',
                      subtitle: "View or cancel in store",
                    ),
                  ],
                ),
              CustomSettingsGroup(
                items: [
                  CustomSettingsItem(
                    onTap: () async {
                      if (isPremium) {
                        ref.read(proteinFocusProvider.notifier).state =
                            !proteinFocus;
                        final SharedPreferences buttonPrefs =
                            await SharedPreferences.getInstance();
                        await buttonPrefs.setBool(
                            'defaultProteinFocus', !proteinFocus);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const Center(
                              child: AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Paywall(),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                    icons: Icons.food_bank,
                    iconStyle: IconStyle(
                      iconsColor: Colors.white,
                      withBackground: true,
                      backgroundColor: Colors.green,
                    ),
                    title: 'Protein Focus',
                    subtitle: "Foods high in protein cost less points",
                    trailing: Switch.adaptive(
                      value: proteinFocus,
                      onChanged: (value) async {
                        if (isPremium) {
                          ref.read(proteinFocusProvider.notifier).state = value;
                          final SharedPreferences buttonPrefs =
                              await SharedPreferences.getInstance();
                          await buttonPrefs.setBool(
                              'defaultProteinFocus', value);
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const Center(
                                child: AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Paywall(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  CustomSettingsItem(
                    onTap: () async {
                      ref.read(hourlyWaterProvider.notifier).state =
                          !hourlyWater;
                      final SharedPreferences buttonPrefs =
                          await SharedPreferences.getInstance();
                      await buttonPrefs.setBool('hourlyWater', !hourlyWater);

                      if (hourlyWater) {
                        NotificationService().scheduleNotification(
                          title: 'Water Reminder',
                          body: 'It\'s time to drink water!',
                          interval: RepeatInterval.hourly,
                        );
                      } else {
                        NotificationService().notificationsPlugin.cancel(0);
                      }
                    },
                    icons: Icons.water_drop,
                    iconStyle: IconStyle(
                      iconsColor: Colors.white,
                      withBackground: true,
                      backgroundColor: Colors.blue,
                    ),
                    title: 'Hourly Water Reminder',
                    subtitle: "Remind yourself to drink water every hour",
                    trailing: Switch.adaptive(
                      value: hourlyWater,
                      onChanged: (value) async {
                        ref.read(hourlyWaterProvider.notifier).state = value;
                        final SharedPreferences buttonPrefs =
                            await SharedPreferences.getInstance();
                        await buttonPrefs.setBool('hourlyWater', value);
                      },
                    ),
                  ),
                  CustomSettingsItem(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Reset health data'),
                            content: const Text(
                                'Are you sure you want to reset your health data?'),
                            actions: [
                              TextButton(
                                child: const Text('CANCEL'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text('RESET'),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      ).then((value) {
                        if (value != null) {
                          // send target weight to pocketbase
                          try {
                            pb.collection('userHealth').update(
                              pb.authStore.model.id,
                              body: {
                                'weight': 0,
                              },
                            ).then((value) => ref.invalidate(healthProvider));

                            // snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Health data reset'),
                              ),
                            );
                          } catch (e) {
                            // show snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to reset health data'),
                              ),
                            );
                          }
                        }
                      });
                    },
                    icons: CupertinoIcons.heart_slash,
                    iconStyle: IconStyle(
                      iconsColor: Colors.white,
                      withBackground: true,
                      backgroundColor: Colors.purple,
                    ),
                    title: 'Reset Health',
                    subtitle: "Recalculate your point allowance",
                  ),
                ],
              ),
              CustomSettingsGroup(
                items: [
                  CustomSettingsItem(
                      onTap: () {
                        // open terms of service
                        final ChromeSafariBrowser browser =
                            ChromeSafariBrowser();

                        String url =
                            'https://theredspy15.github.io/dietly-privacy-polcy/tos.html';
                        if (Platform.isIOS) {
                          url =
                              'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
                        }

                        browser.open(url: WebUri(url));
                      },
                      icons: Icons.feed,
                      title: "Terms of Service (EULA)",
                      trailing: const Icon(Icons.open_in_new)),
                  CustomSettingsItem(
                    onTap: () {
                      // open privacy policy
                      final ChromeSafariBrowser browser = ChromeSafariBrowser();
                      browser.open(
                          url: WebUri(
                              'https://theredspy15.github.io/dietly-privacy-polcy/dietly-privacy.html'));
                    },
                    icons: Icons.feed,
                    title: "Privacy Policy",
                    trailing: const Icon(Icons.open_in_new),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkSubscription(WidgetRef ref) {
    PurchaseApi.fetchOffers().then((value) async {
      try {
        var permission = await Glassfy.permissions();
        permission.all?.forEach((p) {
          logger.i("Permission: ${p.toJson()}");
          if (p.permissionId == "premium" && p.isValid == true) {
            ref.read(premiumProvider.notifier).state = true;
          }
        });
      } catch (e) {
        logger.w("Glassfy failed to fetch permissions: $e");
      }
    });
  }
}
