import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';

class JoinVerseAlmostComponent extends StatefulWidget {
  final InvitationEntity invitation;
  const JoinVerseAlmostComponent({super.key, required this.invitation});

  @override
  State<JoinVerseAlmostComponent> createState() =>
      _JoinVerseAlmostComponentState();
}

class _JoinVerseAlmostComponentState extends State<JoinVerseAlmostComponent> {
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
              Text(
                'join_verse.almost_done_title'.tr(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              Text(
                'join_verse.almost_done_desc'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              SizedBox(height: 36),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    Routelists.joinVerse,
                    extra: widget.invitation,
                  );
                },
                child: Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Center(
                    child: Text('join_verse.create_verse_button'.tr()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
