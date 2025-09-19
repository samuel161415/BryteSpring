import 'package:flutter/material.dart';
import 'custom_outlined_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'top_bar.dart';
import '../../domain/entities/verse.dart';

class AddVerseColorNameWidget extends StatefulWidget {
  const AddVerseColorNameWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,
  });
  final PageController controller;
  final Verse verse;

  final Size screenSize;

  @override
  State<AddVerseColorNameWidget> createState() =>
      _AddVerseColorNameWidgetState();
}

class _AddVerseColorNameWidgetState extends State<AddVerseColorNameWidget> {
  TextEditingController colorNameController = TextEditingController();
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
            "verse_creation_page.color_name_question".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              widget.verse.color ?? "Color Code",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Color name input
          TextField(
            controller: colorNameController,
            decoration: InputDecoration(
              hintText: "verse_creation_page.turquoise".tr(),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ), // Red border
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "verse_creation_page.color_name_tip".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Confirm button
          CustomOutlinedButton(
            text: "verse_creation_page.confirm_color_name".tr(),
            onPressed: () {
              if (colorNameController.text.isNotEmpty) {
                widget.verse.colorName = colorNameController.text;
                widget.controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
