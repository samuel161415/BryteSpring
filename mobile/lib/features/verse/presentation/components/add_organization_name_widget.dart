import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'top_bar.dart';
import '../../domain/entities/verse.dart';

import 'verse_welcome_widget.dart';
import 'custom_outlined_button.dart';

class AddOrganizationNameWidget extends StatefulWidget {
  const AddOrganizationNameWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,
  });
  final PageController controller;
  final Verse verse;

  final Size screenSize;

  @override
  State<AddOrganizationNameWidget> createState() =>
      _AddOrganizationNameWidgetState();
}

class _AddOrganizationNameWidgetState extends State<AddOrganizationNameWidget> {
  TextEditingController verseNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.screenSize.height * 0.65,
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
            "verse_creation_page.verse_owner_question".tr(),
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
              hintText: "verse_creation_page.organization_name_question".tr(),
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
              "verse_creation_page.organization_name_tip".tr(),
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
            text: "verse_creation_page.confirm_org_name".tr(),
            onPressed: () {
              if (verseNameController.text.isNotEmpty) {
                widget.verse.organizationName = verseNameController.text;

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
