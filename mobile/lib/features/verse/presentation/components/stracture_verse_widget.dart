import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/verse/presentation/components/back_and_cancel_widget.dart';
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
  Future<bool> _showCancelEditDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap a button
      builder: (context) => AlertDialog(
        title: const Text("Cancel Creating Verse"),
        content: const Text("Are you sure you want to erase your changes?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // stay
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.controller.jumpToPage(0);
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: widget.screenSize.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top bar
          TopBar(),
          BackAndCancelWidget(controller: widget.controller),

          const SizedBox(height: 20),

          // Greeting
          Text(
            "verse_creation_page.structure_question".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900,
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
            isEnabled: true,

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
