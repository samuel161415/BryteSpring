import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/verse/presentation/components/top_bar.dart';

import '../../../../core/constant.dart';
import '../../domain/entities/verse.dart';

class VerseLoadingCompleted extends StatelessWidget {
  VerseLoadingCompleted({
    super.key,
    this.isLoading,
    required this.screenSize,
    required this.controller,
    required this.verse,
    required this.name,
  });
  bool? isLoading = false;
  final PageController controller;
  final Verse verse;
  final Size screenSize;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TopBar(),
          const SizedBox(height: 40),

          Image.asset("assets/images/successImage1.png", height: 80),
          const SizedBox(height: 20),

          Text(
            "Prima, " + name + "!Dein Verse läuft gerade vom Stapel.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            margin: EdgeInsets.only(bottom: 4, right: 4),
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => VerseCreationPage(),
                //   ),
                // );
                controller.nextPage(
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
                "Jetzt zu meinem Verse",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
