import 'package:flutter/material.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse_join/presentation/components/join_verse_widget.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';

class JoinVerse extends StatefulWidget {
  final InvitationEntity invitation;

  const JoinVerse({
    super.key,
    required this.invitation,
  });

  @override
  State<JoinVerse> createState() => _JoinVerseState();
}

class _JoinVerseState extends State<JoinVerse> {
  void _handleLanguageChanged() {
    // Force rebuild when language changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenSize.width > 500 ? 500 : screenSize.width * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 20.0),
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
              children: [
                JoinVerseComponent(invitation: widget.invitation),
                AppFooter(onLanguageChanged: _handleLanguageChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
