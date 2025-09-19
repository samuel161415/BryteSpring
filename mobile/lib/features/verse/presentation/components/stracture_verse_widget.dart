import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/verse/presentation/components/custom_outlined_button.dart';
import 'top_bar.dart';
import '../../domain/entities/verse.dart';

class StractureVerseWidget extends StatefulWidget {
  const StractureVerseWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,

    // required this.onChanged,
  });
  final PageController controller;
  // final VoidCallback onChanged;
  final Verse verse;

  final Size screenSize;

  @override
  State<StractureVerseWidget> createState() => _StractureVerseWidgetState();
}

class _StractureVerseWidgetState extends State<StractureVerseWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: widget.screenSize.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top bar
          TopBar(),

          const SizedBox(height: 20),

          // Greeting
          Text(
            "verse_creation_page.structure_question".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            "verse_creation_page.structure_tip".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          TextButton(
            onPressed: null,
            child: Text(
              "verse_creation_page.start_directly".tr(),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(height: 10),

          // Confirm button
          CustomOutlinedButton(
            text: "verse_creation_page.find_structure".tr(),
            onPressed: () {
              widget.controller.nextPage(
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
