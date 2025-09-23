import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/features/verse/presentation/components/back_and_cancel_widget.dart';
import '../../domain/entities/verse.dart';
import 'top_bar.dart';
import 'custom_outlined_button.dart';

class AddVerseDomainWidget extends StatefulWidget {
  AddVerseDomainWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,
    required this.name,
    this.verseSubDomain,
  });
  final PageController controller;
  final Verse verse;
  final String name;
  String? verseSubDomain;

  final Size screenSize;

  @override
  State<AddVerseDomainWidget> createState() => _AddVerseDomainWidgetState();
}

class _AddVerseDomainWidgetState extends State<AddVerseDomainWidget> {
  TextEditingController verseNameController = TextEditingController();
  bool changeName = false;
  String toValidSubdomain(String input) {
    // Convert to lowercase
    String result = input.toLowerCase();

    // Replace any invalid characters with a hyphen
    result = result.replaceAll(RegExp(r'[^a-z0-9-]'), '-');

    // Remove leading or trailing hyphens
    result = result.replaceAll(RegExp(r'^-+|-+$'), '');

    // Collapse multiple consecutive hyphens into one
    result = result.replaceAll(RegExp(r'-+'), '-');

    return result;
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
            "${widget.name.isNotEmpty ? widget.name : "Hello"}" +
                "verse_creation_page.verse_name_info".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 16),
          changeName == false
              ? ElevatedButton(
                  onPressed: () {
                    widget.controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    "${toValidSubdomain(widget.verse.name)}.bryteverse",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              :
                // Title textfield
                TextField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  controller: verseNameController,
                  decoration: InputDecoration(
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
              "verse_creation_page.verse_name_tip".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Change name link
          GestureDetector(
            onTap: () {
              // Handle change name
              setState(() {
                changeName = true;
              });
            },
            child: Text(
              "verse_creation_page.change_name".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Button
          CustomOutlinedButton(
            isEnabled:
                verseNameController.text.isNotEmpty || changeName == false,

            text: "verse_creation_page.confirm_name_final".tr(),
            onPressed: () {
              if (verseNameController.text.isNotEmpty) {
                widget.verse.subdomain = toValidSubdomain(
                  verseNameController.text,
                );
                widget.controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (changeName == false) {
                widget.verse.subdomain = toValidSubdomain(widget.verse.name);
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
