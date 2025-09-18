import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/core/constant.dart';
import '../../domain/entities/verse.dart';
import 'top_bar.dart';
import 'custom_outlined_button.dart';

class AddVerseDomainWidget extends StatefulWidget {
  const AddVerseDomainWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,
  });
  final PageController controller;
  final Verse verse;

  final Size screenSize;

  @override
  State<AddVerseDomainWidget> createState() => _AddVerseDomainWidgetState();
}

class _AddVerseDomainWidgetState extends State<AddVerseDomainWidget> {
  TextEditingController verseNameController = TextEditingController();
  bool changeName = false;
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
            "verse_creation_page.verse_name_info".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
                    "${widget.verse.name.toLowerCase()}.bryteverse",
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
            text: "verse_creation_page.confirm_name_final".tr(),
            onPressed: () {
              if (verseNameController.text.isNotEmpty) {
                widget.verse.subdomain = verseNameController.text;
                widget.controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (changeName == false) {
                widget.verse.subdomain = widget.verse.name;
                widget.controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }

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
