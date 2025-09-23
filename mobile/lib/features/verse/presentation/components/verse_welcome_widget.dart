import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/verse/domain/entities/verse.dart';
import 'package:mobile/features/verse/presentation/components/back_and_cancel_widget.dart';
import 'top_bar.dart';
import 'custom_outlined_button.dart';

class VerseWelcomeWidget extends StatelessWidget {
  const VerseWelcomeWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.name,
  });
  final PageController controller;
  final String name;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: screenSize.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top bar
          TopBar(),

          // BackAndCancelWidget(controller: controller),
          const SizedBox(height: 20),

          // Greeting
          Text(
            "verse_creation_page.greeting".tr() + "${name}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 50),

          // Almost done
          Text(
            "verse_creation_page.almost_done".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            "verse_creation_page.before_join".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),

          const SizedBox(height: 40),

          // Button
          CustomOutlinedButton(
            isEnabled: true,
            text: "verse_creation_page.create_verse".tr(),
            onPressed: () {
              controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }
}
