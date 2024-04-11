import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassfy_flutter/glassfy_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:nafp/log.dart';

import '../../providers/providers.dart';

final loadingPurchaseProvider = StateProvider.autoDispose<bool>((ref) => false);

class Paywall extends ConsumerWidget {
  final String lottieAsset;
  const Paywall({super.key, this.lottieAsset = ""});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(premiumOfferingsProvider);

    return offerings.when(
      data: (data) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("Dietly Pro",
                    style:
                        TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const Text("📊 Unlock all premium features"),
                const Text("💪 Protein Prioritization"),
                const Text("📈 Macro Tracking"),
                const Text("📉 Point History"),
                const Text("🤖 AI Enhanced Data"),
                if (lottieAsset.isNotEmpty)
                  Lottie.asset("assets/lottie/stats.json"),
                OutlinedButton(
                    onPressed: () async {
                      try {
                        final transaction = await Glassfy.purchaseSku(
                            data!.all!.first.skus!.first);
                        var p = transaction.permissions?.all?.singleWhere(
                            (permission) =>
                                permission.permissionId == 'premium');
                        if (p?.isValid == true) {
                          ref.read(premiumProvider.notifier).state = true;
                        } else {
                          ref.read(loadingPurchaseProvider.notifier).state =
                              false;
                        }
                      } catch (e) {
                        logger.w("Glassfy failed to purchase: $e");
                        ref.read(loadingPurchaseProvider.notifier).state =
                            false;
                      }
                    },
                    child: ref.watch(loadingPurchaseProvider)
                        ? const CircularProgressIndicator()
                        : Text(
                            "Subscribe \$${data?.all?.first.skus?.first.product?.price?.toStringAsFixed(2)} / month"))
              ],
            ),
          ),
        );
      },
      error: (e, s) => Text("Error: $e"),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
