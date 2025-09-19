import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/routeLists.dart';

import '../../domain/entities/verse.dart';
import 'verse_welcome_widget.dart';
import 'top_bar.dart';
import 'custom_outlined_button.dart';

class VerseCompleteWidget extends StatefulWidget {
  const VerseCompleteWidget({
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
  State<VerseCompleteWidget> createState() => _VerseCompleteWidgetState();
}

class _VerseCompleteWidgetState extends State<VerseCompleteWidget> {
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
            "Herzlich willkommenin Deinem Verse, " + "${widget.name}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Tipp: Wir haben die Informationen zu Deiner Organisation oder Deinem Unternehmen genutzt, um Dein Verse farblich anzupassen. Dies kann Dir und Deinem Team helfen, eine gemeinsame Identifikation zu schaffen. Fahre fort, wenn Du einverstanden bist.Nein, lieber Standard-Layout beibehalten.",
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
            text: "Dankeschön, sieht toll aus!",
            onPressed: () {
              context.go('/${Routelists.dashboard}');

              // widget.verse.name = verseNameController.text;
              // if (verseNameController.text.isNotEmpty) {
              //   widget.controller.nextPage(
              //     duration: const Duration(milliseconds: 300),
              //     curve: Curves.easeInOut,
              //   );
              // }
            },
          ),
        ],
      ),
    );
  }
}
