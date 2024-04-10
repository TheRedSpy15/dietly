import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsform/gs_form/model/data_model/spinner_data_model.dart';
import 'package:gsform/gs_form/widget/field.dart';
import 'package:gsform/gs_form/widget/form.dart';
import 'package:nafp/log.dart';
import 'package:nafp/screens/points/points.dart';

import '../../providers/providers.dart';

// ignore: must_be_immutable
class HealthDataForm extends ConsumerWidget {
  late GSForm form;

  HealthDataForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text("Enter your health data",
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "In order to calculate your daily point allowance, we need some information about you.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: form = GSForm.singleSection(
                        context,
                        fields: [
                          GSField.number(
                            tag: 'feet',
                            title: 'Height (feet)',
                            weight: 6,
                            maxLength: 1,
                            showCounter: false,
                            required: true,
                            prefixWidget: const Text('Feet'),
                          ),
                          GSField.number(
                            tag: 'inches',
                            title: 'Height (inches)',
                            weight: 6,
                            maxLength: 2,
                            showCounter: false,
                            required: true,
                            prefixWidget: const Text('Inches'),
                          ),
                          GSField.number(
                            tag: 'age',
                            title: 'Age (years)',
                            weight: 12,
                            maxLength: 2,
                            showCounter: false,
                            required: true,
                            prefixWidget: const Text('Years'),
                          ),
                          GSField.number(
                            tag: 'weight',
                            title: 'Weight (lbs)',
                            weight: 12,
                            maxLength: 5,
                            showCounter: false,
                            required: true,
                            prefixWidget: const Text('lbs'),
                          ),
                          GSField.number(
                            tag: 'goal',
                            title: 'Target Weight (lbs)',
                            weight: 12,
                            maxLength: 5,
                            showCounter: false,
                            required: true,
                            prefixWidget: const Text('lbs'),
                          ),
                          GSField.spinner(
                            tag: 'gender',
                            required: true,
                            weight: 12,
                            title: 'Gender',
                            items: [
                              SpinnerDataModel(
                                name: 'woman',
                                id: 1,
                                data: 1.0,
                                isSelected: true,
                              ),
                              SpinnerDataModel(name: 'man', id: 2, data: 2.0)
                            ],
                          ),
                          GSField.spinner(
                            tag: 'activity',
                            required: true,
                            weight: 12,
                            title: 'Activity Level',
                            items: [
                              SpinnerDataModel(
                                name: 'Sedentary',
                                id: 1,
                                isSelected: true,
                                data: 0.0,
                              ),
                              SpinnerDataModel(
                                name: 'Lightly Active',
                                id: 2,
                                data: 2.0,
                              ),
                              SpinnerDataModel(
                                name: 'Moderately Active',
                                id: 3,
                                data: 4.0,
                              ),
                              SpinnerDataModel(
                                name: 'Very Active',
                                id: 4,
                                data: 6.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ref.watch(healthProvider).when(
                        data: (healthData) {
                          return ElevatedButton(
                            onPressed: () async {
                              Map<String, dynamic> map = form.onSubmit();

                              if (form.isValid()) {
                                try {
                                  // gsform odd null bug, user doesn't interact with spinner
                                  map['activity'].data ??= 0.0;
                                  map['gender'].data ??= 1.0;

                                  // get height in cm
                                  double height =
                                      (double.parse(map['feet']) * 12 +
                                              double.parse(map['inches'])) *
                                          2.54;
                                  healthData.height = height;
                                  healthData.age = int.parse(map['age']);
                                  healthData.weight =
                                      double.parse(map['weight']);
                                  healthData.goal = int.parse(map['goal']);
                                  healthData.isFemale =
                                      map['gender'].data == 1.0;
                                  healthData.activity = map['activity'].data;
                                  healthData.dailyAllowance = calcAllowancePlus(
                                      healthData.weight,
                                      healthData.height,
                                      healthData.age,
                                      healthData.activity.toInt(),
                                      healthData.isFemale);
                                  healthData.points = healthData.dailyAllowance;

                                  logger.i(
                                      'HealthDataForm: ${healthData.toJson()}');

                                  healthData.saveHealth();
                                  ref.invalidate(healthProvider);
                                } catch (e) {
                                  logger.w(e.toString());
                                }
                              }
                            },
                            child: const Text('Create Point Plan'),
                          );
                        },
                        loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error: (error, stackTrace) {
                          logger.e(error.toString());
                          return Text('Error: $error');
                        })),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
