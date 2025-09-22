import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/verse/presentation/components/top_bar.dart';

import '../../../../core/constant.dart';
import '../../../../core/routing/routeLists.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../verse/presentation/components/custom_outlined_button.dart';

class InviteCompletePage extends StatefulWidget {
  const InviteCompletePage({super.key});

  @override
  State<InviteCompletePage> createState() => _InviteCompletePageState();
}

class _InviteCompletePageState extends State<InviteCompletePage> {
  TextEditingController verseNameController = TextEditingController();
  bool isAdmin = false;
  bool isUser = false;
  bool isExpert = false;
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    void _handleLanguageChanged() {
      // Force rebuild when language changes
      setState(() {});
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenSize.width > 500 ? 500 : screenSize.width * 0.98,
              // margin: const EdgeInsets.symmetric(vertical: 20.0),
              // height: screenSize.height,
              decoration: BoxDecoration(
                color: AppTheme.surface,
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
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // height: widget.screenSize.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top bar
                        TopBar(),

                        const SizedBox(height: 30),

                        // Greeting
                        Text(
                          "Lieber Dirk, Stephan Tomat hatDeine Einladung erhalten.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            "Du wirst informiert, sobald er diese angenommen hat. ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const SizedBox(height: 40),
                        // Button
                        CustomOutlinedButton(
                          text: "zum Dashboard",
                          onPressed: () {
                            context.goNamed(Routelists.dashboard);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    // height: screenSize.height * 0.75,
                    child: AppFooter(onLanguageChanged: _handleLanguageChanged),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
