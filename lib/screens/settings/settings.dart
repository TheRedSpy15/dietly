import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/main.dart';
import 'package:nafp/screens/settings/settingsGroup.dart';
import 'package:nafp/screens/settings/settingsItem.dart';
import 'package:nafp/screens/settings/settingsWidgetUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../providers/providers.dart';
import '../../services/notifications.dart';

final geminiApiKeyProvider = StateProvider<String>((ref) => '');
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
              CustomSettingsGroup(
                items: [
                  CustomSettingsItem(
                    onTap: () async {
                      ref.read(proteinFocusProvider.notifier).state =
                          !proteinFocus;
                      final SharedPreferences buttonPrefs =
                          await SharedPreferences.getInstance();
                      await buttonPrefs.setBool(
                          'defaultProteinFocus', !proteinFocus);
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
                        ref.read(proteinFocusProvider.notifier).state = value;
                        final SharedPreferences buttonPrefs =
                            await SharedPreferences.getInstance();
                        await buttonPrefs.setBool('defaultProteinFocus', value);
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
                  CustomSettingsItem(
                    onTap: () async {
                      // open dialog with text field to set shared preference geminiApiKey
                      final TextEditingController controller =
                          TextEditingController(
                              text: ref.read(geminiApiKeyProvider));
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Set Gemini API Key'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'API Key',
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('CANCEL'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text('SAVE'),
                                onPressed: () {
                                  final String apiKey = controller.text;
                                  ref
                                      .read(geminiApiKeyProvider.notifier)
                                      .state = apiKey;
                                  SharedPreferences.getInstance().then(
                                      (prefs) => prefs.setString(
                                          'geminiApiKey', apiKey));
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icons: Icons.lightbulb,
                    iconStyle: IconStyle(
                      iconsColor: Colors.white,
                      withBackground: true,
                      backgroundColor: Colors.green,
                    ),
                    title: 'Set Gemini API Key',
                    subtitle:
                        "Use your own Google Gemini API key to enable AI food generation. Will need to restart the app to take effect.",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
