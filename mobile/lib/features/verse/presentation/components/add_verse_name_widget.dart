import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/verse.dart';
import 'verse_welcome_widget.dart';
import 'top_bar.dart';
import 'custom_outlined_button.dart';

class AddVerseNameWidget extends StatefulWidget {
  const AddVerseNameWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,
    required this.name,
  });
  final PageController controller;
  final Verse verse;
  final Size screenSize;
  final String name;

  @override
  State<AddVerseNameWidget> createState() => _AddVerseNameWidgetState();
}

class _AddVerseNameWidgetState extends State<AddVerseNameWidget> {
  TextEditingController verseNameController = TextEditingController();
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
            "${widget.name}" + "verse_creation_page.which_verse".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          // Title textfield
          TextField(
            controller: verseNameController,
            decoration: InputDecoration(
              hintText: "verse_creation_page.verse_name_question".tr(),
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
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "verse_creation_page.verse_tip".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 40),
          // Button
          CustomOutlinedButton(
            text: "Ja, so soll es heißen!",
            onPressed: () {
              widget.verse.name = verseNameController.text;
              if (verseNameController.text.isNotEmpty) {
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
