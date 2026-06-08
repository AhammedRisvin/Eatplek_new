import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/service_type.dart';
import '../../controller/offer_controller.dart';

class OfferPreferenceRow extends StatelessWidget {
  const OfferPreferenceRow({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OfferController>(
      id: OfferController.preferencesId,
      builder: (controller) {
        final visibleServices =
            controller.availableServices
                .where((service) => service.trim().isNotEmpty)
                .toList();

        if (visibleServices.isEmpty) {
          return const SizedBox(height: 66);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: visibleServices.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _PreferenceChip(
                  label: visibleServices[index],
                  selected: _samePreference(
                    visibleServices[index],
                    controller.selectedPreference,
                  ),
                  onTap:
                      () => controller.onPreferenceSelected(
                        visibleServices[index],
                      ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  bool _samePreference(String a, String b) {
    return ServiceType.same(a, b);
  }
}

class _PreferenceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PreferenceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? AppColor.appPrimary : AppColor.white,
            border: Border.all(color: AppColor.black.withOpacity(0.06)),
          ),
          child: Center(
            child: text(
              text: label,
              size: 14,
              fontWeight: FontWeight.w500,
              color:
                  selected
                      ? AppColor.white
                      : const Color(0xff474747).withOpacity(0.65),
            ),
          ),
        ),
      ),
    );
  }
}
