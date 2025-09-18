import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';

class JoinVerseComponent extends StatefulWidget {
  final InvitationEntity invitation;

  const JoinVerseComponent({super.key, required this.invitation});

  @override
  State<JoinVerseComponent> createState() => _JoinVerseComponentState();
}

class _JoinVerseComponentState extends State<JoinVerseComponent> {
  VerseJoinEntity? verseData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final verseJoinUseCase = sl<VerseJoinUseCase>();

      // Get verse data using invitation's verseId
      final verseResult = await verseJoinUseCase.getVerse(
        widget.invitation.verseId,
      );
      verseResult.fold(
        (failure) => null,
        (verse) => setState(() => verseData = verse),
      );
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _getGreeting() {
    final firstName = widget.invitation.firstName;
    if (firstName.isNotEmpty) {
      return 'join_verse.greeting_name'.tr(
        namedArgs: {'name': firstName},
      );
    }
    return 'join_verse.greeting_name'.tr(namedArgs: {'name': 'there'});
  }

  String _getInvitedDesc() {
    final verseName = verseData?.name ?? 'Verse';
    final lastName = widget.invitation.lastName;
    final firstName = widget.invitation.firstName;
    final inviterName = '$firstName $lastName'.trim();
    
    return 'join_verse.invited_desc'.tr(namedArgs: {
      'inviterName': inviterName.isNotEmpty ? inviterName : 'Administrator',
      'verseName': verseName,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopHeader(),

              SizedBox(height: 24),
              Text(
                _getGreeting(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 36),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Icon(Icons.close)],
              ),
              SizedBox(height: 24),
              // Use verse logo if available, otherwise use default
              verseData?.branding.logoUrl != null
                  ? Image.network(
                      verseData!.branding.logoUrl!,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultImage(),
                    )
                  : _buildDefaultImage(),
              Text(
                'join_verse.invited_title'.tr(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              Text(
                _getInvitedDesc(),
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              SizedBox(height: 36),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    Routelists.getToKnowRole,
                    extra: widget.invitation,
                  );
                },
                child: Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Center(child: Text('join_verse.join_button'.tr())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.business, size: 40, color: Colors.grey[600]),
    );
  }
}
